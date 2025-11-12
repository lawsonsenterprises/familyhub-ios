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

    /// Extract schedule data from PDF using text extraction
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
            guard let page = document.page(at: pageIndex),
                  let pageContent = page.string else {
                print("⚠️ Could not extract text from page \(pageIndex + 1)")
                continue
            }

            print("\n📄 ===== PAGE \(pageIndex + 1) TEXT =====")
            print(pageContent)
            print("===== END PAGE \(pageIndex + 1) =====\n")

            // Parse the page content
            let pageEntries = parseTimetableText(pageContent)
            print("✅ Extracted \(pageEntries.count) entries from page \(pageIndex + 1)")
            entries.append(contentsOf: pageEntries)
        }

        return entries
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
