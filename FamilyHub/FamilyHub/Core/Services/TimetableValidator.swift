//
//  TimetableValidator.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation

/// Service for validating timetable data integrity
struct TimetableValidator {
    /// Validate timetable data and return a report
    /// - Parameter timetableData: Timetable to validate
    /// - Returns: Validation report with statistics and any issues
    static func validate(_ timetableData: TimetableData) -> ValidationReport {
        var report = ValidationReport()

        let entries = timetableData.scheduleEntries
        report.totalEntries = entries.count

        // Count entries per week
        let week1Entries = entries.filter { $0.week == .week1 }
        let week2Entries = entries.filter { $0.week == .week2 }

        report.week1Count = week1Entries.count
        report.week2Count = week2Entries.count

        // Count entries per day
        for day in [DayOfWeek.monday, .tuesday, .wednesday, .thursday, .friday] {
            let dayCount = entries.filter { $0.dayOfWeek == day }.count
            report.entriesPerDay[day] = dayCount
        }

        // Check for missing data
        for entry in entries {
            if entry.subject.isEmpty {
                report.issues.append("Entry missing subject: Period \(entry.period), \(entry.dayOfWeek.rawValue)")
            }
            if entry.room.isEmpty {
                report.warnings.append("Entry missing room: \(entry.subject), Period \(entry.period)")
            }
            // Note: startTime is optional and not required (times are fixed per period)
        }

        // Check for duplicate entries
        var seen = Set<String>()
        for entry in entries {
            let key = "\(entry.week.rawValue)-\(entry.dayOfWeek.rawValue)-\(entry.period)"
            if seen.contains(key) {
                report.issues.append("Duplicate entry: \(entry.week.rawValue) \(entry.dayOfWeek.rawValue) Period \(entry.period)")
            }
            seen.insert(key)
        }

        return report
    }

    /// Print validation report to console
    /// - Parameter report: Validation report to print
    static func printReport(_ report: ValidationReport) {
        print("\n=== Timetable Validation Report ===")
        print("Total Entries: \(report.totalEntries)")
        print("Week 1 Entries: \(report.week1Count)")
        print("Week 2 Entries: \(report.week2Count)")
        print("\nEntries per day:")
        for (day, count) in report.entriesPerDay.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            print("  \(day.rawValue): \(count)")
        }

        if !report.warnings.isEmpty {
            print("\n⚠️ Warnings:")
            for warning in report.warnings {
                print("  - \(warning)")
            }
        }

        if !report.issues.isEmpty {
            print("\n❌ Issues:")
            for issue in report.issues {
                print("  - \(issue)")
            }
        } else {
            print("\n✅ No issues found!")
        }
        print("===================================\n")
    }
}

/// Report structure for timetable validation
struct ValidationReport {
    var totalEntries: Int = 0
    var week1Count: Int = 0
    var week2Count: Int = 0
    var entriesPerDay: [DayOfWeek: Int] = [:]
    var issues: [String] = []
    var warnings: [String] = []

    var isValid: Bool {
        issues.isEmpty
    }
}
