//
//  CSVParser.swift
//  FamilyHub
//
//  Created by Claude Code on 13/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation

/// Service for parsing CSV timetable files
struct CSVParser {
    /// Result of parsing a CSV file
    struct ParseResult {
        let validEntries: [ScheduleEntry]
        let errors: [ParseError]
        let totalRows: Int

        var hasErrors: Bool {
            !errors.isEmpty
        }

        var successCount: Int {
            validEntries.count
        }

        var errorCount: Int {
            errors.count
        }
    }

    /// Error encountered during CSV parsing
    struct ParseError {
        let row: Int
        let message: String
    }

    /// Parse CSV content into schedule entries
    /// - Parameter csvContent: CSV file content as string
    /// - Returns: Parse result containing valid entries and any errors
    static func parse(_ csvContent: String) -> ParseResult {
        var validEntries: [ScheduleEntry] = []
        var errors: [ParseError] = []

        let lines = csvContent.components(separatedBy: .newlines)
        var totalRows = 0

        // Expected header: Week,Day,Period,Subject,Teacher,Room
        guard lines.count > 1 else {
            errors.append(ParseError(row: 0, message: "CSV file is empty or has no data rows"))
            return ParseResult(validEntries: [], errors: errors, totalRows: 0)
        }

        let headerLine = lines[0].trimmingCharacters(in: .whitespaces)
        let expectedHeaders = ["Week", "Day", "Period", "Subject", "Teacher", "Room"]
        let headers = parseCSVLine(headerLine)

        // Validate headers (case-insensitive)
        let normalizedHeaders = headers.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        let expectedNormalized = expectedHeaders.map { $0.lowercased() }

        if normalizedHeaders != expectedNormalized {
            errors.append(ParseError(
                row: 1,
                message: "Invalid CSV header. Expected: \(expectedHeaders.joined(separator: ","))"
            ))
        }

        // Parse data rows (skip header)
        for (index, line) in lines.dropFirst().enumerated() {
            let rowNumber = index + 2 // +2 because index is 0-based and we skipped header

            // Skip empty lines
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }

            totalRows += 1

            let fields = parseCSVLine(trimmed)

            // Validate field count
            guard fields.count == 6 else {
                errors.append(ParseError(
                    row: rowNumber,
                    message: "Expected 6 fields, found \(fields.count)"
                ))
                continue
            }

            let weekStr = fields[0].trimmingCharacters(in: .whitespaces)
            let dayStr = fields[1].trimmingCharacters(in: .whitespaces)
            let periodStr = fields[2].trimmingCharacters(in: .whitespaces)
            let subject = fields[3].trimmingCharacters(in: .whitespaces)
            let teacher = fields[4].trimmingCharacters(in: .whitespaces)
            let room = fields[5].trimmingCharacters(in: .whitespaces)

            // Validate Week
            guard let week = parseWeek(weekStr) else {
                errors.append(ParseError(
                    row: rowNumber,
                    message: "Invalid week value '\(weekStr)'. Must be '1' or '2'"
                ))
                continue
            }

            // Validate Day
            guard let day = parseDay(dayStr) else {
                errors.append(ParseError(
                    row: rowNumber,
                    message: "Invalid day value '\(dayStr)'. Must be Monday/Tuesday/Wednesday/Thursday/Friday"
                ))
                continue
            }

            // Validate Period (can be string now: "TUT", "AM Registration", "1"-"5", "PM Registration")
            guard var period = parsePeriod(periodStr) else {
                errors.append(ParseError(
                    row: rowNumber,
                    message: "Invalid period value '\(periodStr)'. Must be 'TUT', 'AM Registration', '1'-'5', or 'PM Registration'"
                ))
                continue
            }

            // Validate Subject (required, non-empty)
            guard !subject.isEmpty else {
                errors.append(ParseError(
                    row: rowNumber,
                    message: "Subject is required (cannot be empty)"
                ))
                continue
            }

            // Handle TUT period - determine AM (0) or PM (6) based on subject
            if periodStr.uppercased() == "TUT" {
                if subject.uppercased().contains("AM") {
                    period = 0  // AM Registration
                } else if subject.uppercased().contains("PM") {
                    period = 6  // PM Registration
                } else {
                    // Default to AM if not specified
                    period = 0
                }
            }

            // Teacher is optional (can be empty)
            let teacherValue = teacher.isEmpty ? nil : teacher

            // Validate Room (required, non-empty)
            guard !room.isEmpty else {
                errors.append(ParseError(
                    row: rowNumber,
                    message: "Room is required (cannot be empty)"
                ))
                continue
            }

            // Create entry
            let entry = ScheduleEntry(
                dayOfWeek: day,
                period: period,
                subject: subject,
                room: room,
                week: week,
                teacher: teacherValue
            )

            validEntries.append(entry)
        }

        return ParseResult(
            validEntries: validEntries,
            errors: errors,
            totalRows: totalRows
        )
    }

    /// Parse a CSV line handling quoted fields
    /// - Parameter line: CSV line to parse
    /// - Returns: Array of field values
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        // Add the last field
        fields.append(currentField)

        return fields
    }

    /// Parse week value from string
    /// - Parameter value: Week string ("1" or "2")
    /// - Returns: WeekType if valid, nil otherwise
    private static func parseWeek(_ value: String) -> WeekType? {
        switch value {
        case "1": return .week1
        case "2": return .week2
        default: return nil
        }
    }

    /// Parse day value from string
    /// - Parameter value: Day string (Monday, Tuesday, etc.)
    /// - Returns: DayOfWeek if valid, nil otherwise
    private static func parseDay(_ value: String) -> DayOfWeek? {
        switch value.lowercased() {
        case "monday": return .monday
        case "tuesday": return .tuesday
        case "wednesday": return .wednesday
        case "thursday": return .thursday
        case "friday": return .friday
        default: return nil
        }
    }

    /// Parse period value from string
    /// - Parameter value: Period string ("TUT", "AM Registration", "1"-"5", "PM Registration")
    /// - Returns: Period number if valid, nil otherwise
    private static func parsePeriod(_ value: String) -> Int? {
        let normalized = value.trimmingCharacters(in: .whitespaces).uppercased()

        // Handle "TUT" (Tutorial/Registration) - need to check subject field to determine AM/PM
        // For now, we'll map TUT to 0, but this will be refined in the validation
        if normalized == "TUT" {
            return 0  // Will be determined by subject (AM/PM Registration)
        }

        // Check for registration periods
        if value.lowercased().contains("am") && value.lowercased().contains("registration") {
            return 0  // AM Registration = Period 0
        }
        if value.lowercased().contains("pm") && value.lowercased().contains("registration") {
            return 6  // PM Registration = Period 6
        }

        // Try to parse as integer (1-5)
        if let period = Int(value), period >= 1 && period <= 5 {
            return period
        }

        return nil
    }
}
