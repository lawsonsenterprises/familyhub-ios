//
//  PDFService.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import PDFKit
import UIKit
import Vision

/// Service for handling PDF import and processing
struct PDFService {
    /// Import PDF from a file URL
    /// - Parameter url: URL of the PDF file
    /// - Returns: PDF data
    /// - Throws: Error if import fails
    static func importPDF(from url: URL) async throws -> Data {
        // Ensure we can access the URL
        guard url.startAccessingSecurityScopedResource() else {
            throw PDFError.accessDenied
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        // Read the data
        guard let data = try? Data(contentsOf: url) else {
            throw PDFError.invalidData
        }

        // Verify it's a valid PDF
        guard let _ = PDFDocument(data: data) else {
            throw PDFError.invalidPDF
        }

        return data
    }

    /// Generate a thumbnail image from PDF data
    /// - Parameters:
    ///   - data: PDF data
    ///   - size: Desired thumbnail size (default 200x200)
    /// - Returns: Thumbnail image, or nil if generation fails
    static func renderPDFThumbnail(data: Data, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let document = PDFDocument(data: data),
              let page = document.page(at: 0) else {
            return nil
        }

        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: size)

        let thumbnail = renderer.image { context in
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: size))

            context.cgContext.translateBy(x: 0, y: size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)

            let scaleFactor = min(size.width / pageRect.width, size.height / pageRect.height)
            context.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)

            page.draw(with: .mediaBox, to: context.cgContext)
        }

        return thumbnail
    }

    /// Extract schedule data from PDF using OCR (for scanned documents)
    /// - Parameter pdfData: PDF data to parse
    /// - Returns: Array of schedule entries extracted from the PDF
    static func extractScheduleData(from pdfData: Data) -> [ScheduleEntry] {
        guard let document = PDFDocument(data: pdfData) else {
            print("❌ Failed to create PDFDocument from data")
            return []
        }

        print("📄 PDF has \(document.pageCount) page(s)")

        var entries: [ScheduleEntry] = []

        // Extract text from all pages
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else {
                print("⚠️ Could not get page \(pageIndex + 1)")
                continue
            }

            // Try standard text extraction first
            if let pageContent = page.string, !pageContent.isEmpty {
                print("✅ Using text extraction for page \(pageIndex + 1)")
                print("\n📄 ===== PAGE \(pageIndex + 1) TEXT =====")
                print(pageContent)
                print("===== END PAGE \(pageIndex + 1) =====\n")

                let pageEntries = parseTimetableText(pageContent)
                print("✅ Extracted \(pageEntries.count) entries from page \(pageIndex + 1)")
                entries.append(contentsOf: pageEntries)
            } else {
                // Use OCR for scanned documents
                print("⚠️ No text found, using OCR for page \(pageIndex + 1)")
                if let observations = performOCRWithPositions(on: page) {
                    let pageEntries = parseTimetableFromOCRPositions(observations)
                    print("✅ Extracted \(pageEntries.count) entries from OCR on page \(pageIndex + 1)")
                    entries.append(contentsOf: pageEntries)
                }
            }
        }

        return entries
    }

    /// Perform OCR on a PDF page using Vision framework with positional data
    /// - Parameter page: PDF page to process
    /// - Returns: Array of text observations with bounding boxes
    private static func performOCRWithPositions(on page: PDFPage) -> [VNRecognizedTextObservation]? {
        // Render page as image
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)

        let image = renderer.image { context in
            UIColor.white.set()
            context.fill(pageRect)
            context.cgContext.translateBy(x: 0, y: pageRect.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            page.draw(with: .mediaBox, to: context.cgContext)
        }

        guard let cgImage = image.cgImage else {
            print("❌ Failed to create CGImage from page")
            return nil
        }

        // Perform OCR
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            return request.results
        } catch {
            print("❌ OCR failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Perform OCR on a PDF page using Vision framework
    /// - Parameter page: PDF page to process
    /// - Returns: Recognized text or nil if OCR fails
    private static func performOCR(on page: PDFPage) -> String? {
        guard let observations = performOCRWithPositions(on: page) else {
            return nil
        }

        // Combine all recognized text
        let recognizedText = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }.joined(separator: "\n")

        return recognizedText.isEmpty ? nil : recognizedText
    }

    /// Parse timetable from OCR observations using positional data
    /// - Parameter observations: Vision OCR observations with bounding boxes
    /// - Returns: Array of schedule entries
    private static func parseTimetableFromOCRPositions(_ observations: [VNRecognizedTextObservation]) -> [ScheduleEntry] {
        var entries: [ScheduleEntry] = []

        // Group observations by text content
        struct TextItem {
            let text: String
            let bounds: CGRect
        }

        let textItems = observations.compactMap { observation -> TextItem? in
            guard let text = observation.topCandidates(1).first?.string else { return nil }
            return TextItem(text: text, bounds: observation.boundingBox)
        }

        print("🔍 Processing \(textItems.count) text items with positions...")

        // The timetable layout is: ROWS = Days (vertical), COLUMNS = Periods (horizontal)
        // Day headers like "1 Mon", "1 Tue" appear as row labels
        // Each row contains: Day header, then cells with Subject/Teacher/Room for each period

        // Find day headers (format: "1 Mon", "2 Tue", etc.)
        let dayPattern = #"^([12])\s*(Mon|Tue|Wed|Thu|Fri)"#
        var dayRows: [(week: WeekType, day: DayOfWeek, y: CGFloat)] = []

        for item in textItems {
            if item.text.range(of: dayPattern, options: .regularExpression) != nil {
                let weekNum = String(item.text.prefix(1))
                let dayAbbr = item.text.replacingOccurrences(of: weekNum, with: "")
                    .trimmingCharacters(in: .whitespaces)

                let week: WeekType = weekNum == "1" ? .week1 : .week2
                if let day = parseDayAbbreviation(dayAbbr) {
                    dayRows.append((week: week, day: day, y: item.bounds.midY))
                    print("📌 Found row: \(week.rawValue) \(day.rawValue) at y=\(item.bounds.midY)")
                }
            }
        }

        // Sort rows by Y position (top to bottom in Vision coordinates: higher Y = higher on page)
        dayRows.sort { $0.y > $1.y }

        print("🔍 Found \(dayRows.count) day rows")

        // For each day row, find all text items on that row and parse periods
        for (rowIndex, dayRow) in dayRows.enumerated() {
            // Define row boundaries (Y range)
            let rowMaxY = rowIndex == 0 ? 1.0 : (dayRows[rowIndex - 1].y + dayRow.y) / 2
            let rowMinY = rowIndex == dayRows.count - 1 ? 0.0 : (dayRow.y + dayRows[rowIndex + 1].y) / 2

            // Get all text items in this row, sorted left to right
            var rowItems = textItems.filter { item in
                item.bounds.midY < rowMaxY && item.bounds.midY >= rowMinY
            }.sorted { $0.bounds.midX < $1.bounds.midX }

            // Remove the day header itself
            rowItems.removeAll { $0.text.range(of: dayPattern, options: .regularExpression) != nil }

            print("📋 Row \(dayRow.week.rawValue) \(dayRow.day.rawValue): \(rowItems.count) items")

            // Group items by X position into period columns (each period has 3 items: subject, teacher, room)
            // Items within the same period cell have very similar X positions (vertically stacked)

            // Debug: Print some X positions
            if rowItems.count > 0 {
                let xPositions = rowItems.prefix(min(15, rowItems.count)).map { String(format: "%.3f", $0.bounds.midX) }
                print("  📊 Sample X positions: \(xPositions.joined(separator: ", "))")
            }

            // Sort by X position
            let sortedByX = rowItems.sorted { $0.bounds.midX < $1.bounds.midX }

            // Group items by detecting LARGE gaps between periods (not small intra-period variations)
            // Items within a period vary by ~0.02-0.08, gaps between periods are ~0.06-0.10
            var periods: [[TextItem]] = []
            var currentPeriod: [TextItem] = []
            var lastX: CGFloat = -1.0

            for item in sortedByX {
                if lastX < 0 {
                    // First item
                    currentPeriod.append(item)
                    lastX = item.bounds.midX
                } else {
                    // Check GAP between this item and previous item
                    let gap = item.bounds.midX - lastX

                    // Large gap (>0.065) means new period, small gap means same period
                    if gap > 0.065 {
                        // Start new period
                        if !currentPeriod.isEmpty {
                            periods.append(currentPeriod)
                        }
                        currentPeriod = [item]
                    } else {
                        // Same period
                        currentPeriod.append(item)
                    }
                    lastX = item.bounds.midX
                }
            }
            if !currentPeriod.isEmpty {
                periods.append(currentPeriod)
            }

            print("  🔹 Found \(periods.count) periods in this row")

            // Parse each period
            for (periodIndex, periodItems) in periods.enumerated() {
                // Sort items vertically within the period cell (top to bottom)
                let sortedItems = periodItems.sorted { $0.bounds.midY > $1.bounds.midY }

                guard sortedItems.count >= 3 else {
                    print("  ⚠️ Period \(periodIndex) has only \(sortedItems.count) items, skipping")
                    continue
                }

                let subjectText = sortedItems[0].text
                let teacherText = sortedItems[1].text
                let roomText = sortedItems[2].text

                // Validate this is an entry (teacher = 3-4 caps, room starts with "Room")
                let teacherPattern = #"^[A-Z]{3,4}$"#
                let roomPattern = #"^Room\s+\d+"#

                if teacherText.range(of: teacherPattern, options: .regularExpression) != nil &&
                   roomText.range(of: roomPattern, options: .regularExpression) != nil {

                    let room = roomText.replacingOccurrences(of: "Room", with: "", options: .caseInsensitive)
                        .trimmingCharacters(in: .whitespaces)

                    var subject = subjectText
                    var period = periodIndex

                    // Handle registration
                    if subjectText.contains("Registration") {
                        subject = "Registration"
                        period = subjectText.contains("AM") ? 0 : periodIndex
                    } else {
                        // Regular periods start at 1
                        period = periodIndex == 0 ? 1 : periodIndex
                    }

                    let entry = ScheduleEntry(
                        dayOfWeek: dayRow.day,
                        period: period,
                        subject: subject,
                        room: room,
                        week: dayRow.week,
                        teacher: teacherText
                    )

                    print("  ✅ P\(period): \(subject) (\(teacherText), Room \(room))")
                    entries.append(entry)
                }
            }
        }

        return entries
    }

    /// Parse timetable from OCR text (multi-line cell format)
    /// - Parameter text: OCR text from scanned timetable
    /// - Returns: Array of schedule entries
    private static func parseTimetableFromOCR(_ text: String) -> [ScheduleEntry] {
        var entries: [ScheduleEntry] = []
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }

        print("🔍 Parsing OCR text with \(lines.count) lines...")

        // The timetable format from OCR is:
        // Day line: "1Mon" or "1 Mon" (week number + day abbreviation)
        // Then groups of 3 lines per period:
        //   - Subject name (or "AM Registration"/"PM Registration")
        //   - Teacher code (3 letters)
        //   - Room (format "Room ###")

        var currentWeek: WeekType?
        var currentDay: DayOfWeek?
        var currentPeriod = 0
        var lineIndex = 0

        while lineIndex < lines.count {
            let line = lines[lineIndex]

            // Skip empty lines
            if line.isEmpty {
                lineIndex += 1
                continue
            }

            // Try to match day pattern (e.g., "1Mon", "1 Mon", "2Fri")
            if let match = line.range(of: #"^([12])\s*(Mon|Tue|Wed|Thu|Fri)"#, options: .regularExpression) {
                let matchedText = String(line[match])

                // Extract week number (first character)
                let weekNum = String(matchedText.prefix(1))

                // Extract day abbreviation (after week number and optional space)
                let dayAbbr = matchedText.replacingOccurrences(of: weekNum, with: "")
                    .trimmingCharacters(in: .whitespaces)

                currentWeek = weekNum == "1" ? .week1 : .week2
                currentDay = parseDayAbbreviation(dayAbbr)

                print("📌 Line \(lineIndex + 1): Found day: \(currentWeek?.rawValue ?? "") \(currentDay?.rawValue ?? "")")

                // Reset period counter for new day (starts with Tut/Registration, then periods 1-5)
                currentPeriod = 0
                lineIndex += 1
                continue
            }

            // If we have a current day, try to parse period entries
            if let week = currentWeek, let day = currentDay {
                // Check if we have at least 3 lines remaining for a complete entry
                guard lineIndex + 2 < lines.count else {
                    lineIndex += 1
                    continue
                }

                let subjectLine = lines[lineIndex]
                let teacherLine = lines[lineIndex + 1]
                let roomLine = lines[lineIndex + 2]

                // Skip if any line is empty
                if subjectLine.isEmpty || teacherLine.isEmpty || roomLine.isEmpty {
                    lineIndex += 1
                    continue
                }

                // Check if this looks like a valid entry
                // Teacher should be 3-4 capital letters, Room should contain "Room"
                let teacherPattern = #"^[A-Z]{3,4}$"#
                let roomPattern = #"^Room\s+\d+"#

                if teacherLine.range(of: teacherPattern, options: .regularExpression) != nil &&
                   roomLine.range(of: roomPattern, options: .regularExpression) != nil {

                    // Extract room number
                    let room = roomLine.replacingOccurrences(of: "Room", with: "", options: .caseInsensitive)
                        .trimmingCharacters(in: .whitespaces)

                    // Handle registration periods vs regular periods
                    var subject = subjectLine
                    var period = currentPeriod

                    // Map registration to period 0 (AM) or special period (PM)
                    if subjectLine.contains("Registration") {
                        subject = "Registration"
                        if subjectLine.contains("AM") {
                            period = 0  // AM Registration = Period 0
                        } else if subjectLine.contains("PM") {
                            currentPeriod += 1
                            period = currentPeriod  // PM Registration gets next period number
                        } else {
                            period = 0  // Default to period 0 if no AM/PM specified
                        }
                    } else {
                        // Regular period - increment counter
                        currentPeriod += 1
                        period = currentPeriod
                    }

                    let entry = ScheduleEntry(
                        dayOfWeek: day,
                        period: period,
                        subject: subject,
                        room: room,
                        week: week,
                        teacher: teacherLine
                    )

                    print("✅ Parsed: \(week.rawValue) \(day.rawValue) Period \(period) - \(subject) (\(teacherLine), Room \(room))")
                    entries.append(entry)

                    // Move past the 3 lines we just processed
                    lineIndex += 3
                } else {
                    // Doesn't match expected pattern, move to next line
                    lineIndex += 1
                }
            } else {
                // No current day context, skip line
                lineIndex += 1
            }
        }

        return entries
    }

    /// Parse day abbreviation to DayOfWeek
    /// - Parameter abbr: Day abbreviation (Mon, Tue, etc.)
    /// - Returns: DayOfWeek enum value
    private static func parseDayAbbreviation(_ abbr: String) -> DayOfWeek? {
        switch abbr.lowercased() {
        case "mon": return .monday
        case "tue": return .tuesday
        case "wed": return .wednesday
        case "thu": return .thursday
        case "fri": return .friday
        default: return nil
        }
    }

    /// Parse a table cell containing subject, teacher, and room
    /// - Parameters:
    ///   - text: Cell text
    ///   - week: Week type
    ///   - day: Day of week
    ///   - period: Period number
    /// - Returns: ScheduleEntry if parsing successful
    private static func parseTableCell(_ text: String, week: WeekType, day: DayOfWeek, period: Int) -> ScheduleEntry? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        // Expected format: "Subject Teacher Room" or "Subject\nTeacher\nRoom"
        // Teacher is usually 3 capital letters
        // Room starts with letters or numbers

        var subject = cleaned
        var teacher: String?
        var room = ""

        // Extract teacher code (3 capital letters)
        let teacherPattern = #"\b([A-Z]{3})\b"#
        if let teacherMatch = cleaned.range(of: teacherPattern, options: .regularExpression) {
            teacher = String(cleaned[teacherMatch])
            subject = subject.replacingOccurrences(of: teacher!, with: "")
        }

        // Extract room (format: Room123, R12, etc.)
        let roomPattern = #"(?:Room\s*)?([A-Z]?\d+[A-Z]?)"#
        if let roomMatch = cleaned.range(of: roomPattern, options: [.regularExpression, .caseInsensitive]) {
            let roomStr = String(cleaned[roomMatch])
            room = roomStr.replacingOccurrences(of: "Room", with: "", options: .caseInsensitive).trimmingCharacters(in: .whitespaces)
            subject = subject.replacingOccurrences(of: roomStr, with: "")
        }

        subject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !subject.isEmpty else { return nil }

        return ScheduleEntry(
            dayOfWeek: day,
            period: period,
            subject: subject,
            room: room,
            week: week,
            teacher: teacher
        )
    }

    /// Parse timetable text content to extract schedule entries
    /// - Parameter text: Raw text content from PDF
    /// - Returns: Array of schedule entries
    private static func parseTimetableText(_ text: String) -> [ScheduleEntry] {
        var entries: [ScheduleEntry] = []
        let lines = text.components(separatedBy: .newlines)

        var currentWeek: WeekType?
        var currentDay: DayOfWeek?

        print("🔍 Parsing \(lines.count) lines...")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            // Detect week headers (e.g., "Week 1", "Week 2")
            if trimmed.contains("Week 1") {
                print("📌 Line \(index + 1): Found Week 1 header")
                currentWeek = .week1
                continue
            } else if trimmed.contains("Week 2") {
                print("📌 Line \(index + 1): Found Week 2 header")
                currentWeek = .week2
                continue
            }

            // Detect day headers
            if let day = detectDayOfWeek(from: trimmed) {
                print("📌 Line \(index + 1): Found day header: \(day.rawValue)")
                currentDay = day
                continue
            }

            // Parse period entry lines
            if let week = currentWeek,
               let day = currentDay,
               let entry = parsePeriodLine(trimmed, week: week, day: day) {
                print("✅ Line \(index + 1): Parsed entry: \(entry.subject) - Period \(entry.period)")
                entries.append(entry)
            }
        }

        print("📊 Total entries parsed: \(entries.count)")
        return entries
    }

    /// Detect day of week from text line
    /// - Parameter text: Text line to analyze
    /// - Returns: Day of week if detected
    private static func detectDayOfWeek(from text: String) -> DayOfWeek? {
        let lowercased = text.lowercased()
        if lowercased.contains("monday") || lowercased.starts(with: "mon") {
            return .monday
        } else if lowercased.contains("tuesday") || lowercased.starts(with: "tue") {
            return .tuesday
        } else if lowercased.contains("wednesday") || lowercased.starts(with: "wed") {
            return .wednesday
        } else if lowercased.contains("thursday") || lowercased.starts(with: "thu") {
            return .thursday
        } else if lowercased.contains("friday") || lowercased.starts(with: "fri") {
            return .friday
        }
        return nil
    }

    /// Parse a single period line to create a schedule entry
    /// - Parameters:
    ///   - line: Text line containing period information
    ///   - week: Week type
    ///   - day: Day of week
    /// - Returns: Schedule entry if parsing successful
    private static func parsePeriodLine(_ line: String, week: WeekType, day: DayOfWeek) -> ScheduleEntry? {
        // Expected format variations:
        // "Period 1  09:00-09:50  Mathematics  R12  KCO"
        // "P1 Mathematics R12"
        // "1. Maths - Room 12 - 9:00"

        guard !line.isEmpty else { return nil }

        // Try to extract period number
        let periodPattern = #"(?:Period\s*|P)?(\d+)"#
        guard let periodMatch = line.range(of: periodPattern, options: .regularExpression),
              let periodNumber = Int(line[periodMatch].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) else {
            return nil
        }

        // Extract time if present (format: HH:MM or HH:MM-HH:MM)
        let timePattern = #"(\d{1,2}:\d{2})(?:-(\d{1,2}:\d{2}))?"#
        var startTime: String?
        var endTime: String?

        if let timeMatch = line.range(of: timePattern, options: .regularExpression) {
            let timeString = String(line[timeMatch])
            let times = timeString.components(separatedBy: "-")
            startTime = times.first
            endTime = times.count > 1 ? times.last : nil
        }

        // Extract room (format: R12, Room 12, Rm12)
        let roomPattern = #"(?:Room\s*|R|Rm)\s*(\w+)"#
        var room = ""
        if let roomMatch = line.range(of: roomPattern, options: [.regularExpression, .caseInsensitive]) {
            let roomString = String(line[roomMatch])
            room = roomString.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                .replacingOccurrences(of: "Room", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "Rm", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "R", with: "")
        }

        // Extract subject (the text between period and room, or period and time)
        var subject = line
        if let periodRange = subject.range(of: periodPattern, options: .regularExpression) {
            subject = String(subject[periodRange.upperBound...])
        }
        if let timeRange = subject.range(of: timePattern, options: .regularExpression) {
            subject = String(subject[..<timeRange.lowerBound])
        }
        if let roomRange = subject.range(of: roomPattern, options: [.regularExpression, .caseInsensitive]) {
            subject = String(subject[..<roomRange.lowerBound])
        }

        subject = subject.trimmingCharacters(in: .whitespacesAndNewlines)

        // Skip if no valid subject found
        guard !subject.isEmpty else { return nil }

        // Extract teacher code (usually 3 capital letters at the end)
        let teacherPattern = #"\b([A-Z]{3})\b"#
        var teacher: String?
        if let teacherMatch = subject.range(of: teacherPattern, options: .regularExpression) {
            teacher = String(subject[teacherMatch])
            subject = subject.replacingOccurrences(of: teacher!, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return ScheduleEntry(
            dayOfWeek: day,
            period: periodNumber,
            subject: subject,
            room: room,
            week: week,
            teacher: teacher,
            startTime: startTime,
            endTime: endTime
        )
    }
}

// MARK: - Errors

enum PDFError: LocalizedError {
    case accessDenied
    case invalidData
    case invalidPDF

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Cannot access the PDF file. Please grant permission."
        case .invalidData:
            return "The file data is invalid or corrupted."
        case .invalidPDF:
            return "The file is not a valid PDF document."
        }
    }
}
