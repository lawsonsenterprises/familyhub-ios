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
                if let ocrText = performOCR(on: page) {
                    print("\n📄 ===== PAGE \(pageIndex + 1) OCR TEXT =====")
                    print(ocrText)
                    print("===== END PAGE \(pageIndex + 1) =====\n")

                    let pageEntries = parseTimetableFromOCR(ocrText)
                    print("✅ Extracted \(pageEntries.count) entries from OCR on page \(pageIndex + 1)")
                    entries.append(contentsOf: pageEntries)
                }
            }
        }

        return entries
    }

    /// Perform OCR on a PDF page using Vision framework
    /// - Parameter page: PDF page to process
    /// - Returns: Recognized text or nil if OCR fails
    private static func performOCR(on page: PDFPage) -> String? {
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

            guard let observations = request.results else {
                print("❌ No OCR observations")
                return nil
            }

            // Combine all recognized text
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            return recognizedText.isEmpty ? nil : recognizedText
        } catch {
            print("❌ OCR failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Parse timetable from OCR text (table format)
    /// - Parameter text: OCR text from scanned timetable
    /// - Returns: Array of schedule entries
    private static func parseTimetableFromOCR(_ text: String) -> [ScheduleEntry] {
        var entries: [ScheduleEntry] = []
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }

        print("🔍 Parsing OCR text with \(lines.count) lines...")

        // The timetable format is:
        // Row format: DayLabel | Subject Teacher Room | Subject Teacher Room | ...
        // Days are like "1Mon", "1Tue", "2Mon" (week number + day abbreviation)

        for (index, line) in lines.enumerated() {
            // Skip empty lines
            guard !line.isEmpty else { continue }

            // Try to match day pattern (e.g., "1Mon", "2Fri")
            if let match = line.range(of: #"^([12])(Mon|Tue|Wed|Thu|Fri)"#, options: .regularExpression) {
                let dayPrefix = String(line[match])
                let weekNum = String(dayPrefix.prefix(1))
                let dayAbbr = String(dayPrefix.dropFirst())

                let week: WeekType = weekNum == "1" ? .week1 : .week2
                guard let day = parseDayAbbreviation(dayAbbr) else { continue }

                print("📌 Line \(index + 1): Found day: \(week.rawValue) \(day.rawValue)")

                // Rest of line contains period data
                let periodData = String(line[match.upperBound...]).trimmingCharacters(in: .whitespaces)

                // Split by common separators and parse each chunk
                let chunks = periodData.components(separatedBy: CharacterSet(charactersIn: "|"))

                for (periodIndex, chunk) in chunks.enumerated() where !chunk.trimmingCharacters(in: .whitespaces).isEmpty {
                    if let entry = parseTableCell(chunk, week: week, day: day, period: periodIndex + 1) {
                        print("✅ Parsed: Period \(entry.period) - \(entry.subject)")
                        entries.append(entry)
                    }
                }
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
