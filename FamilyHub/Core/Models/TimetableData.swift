//
//  TimetableData.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// Represents a user's timetable data including Week A/B configuration
@Model
final class TimetableData {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// PDF data for the timetable (optional)
    var pdfData: Data?

    /// Current week type (Week A or Week B)
    var currentWeek: WeekType

    /// Date when Week A started (reference point for calculation)
    var weekStartDate: Date

    /// Last updated timestamp
    var lastUpdated: Date

    /// Manual override enabled (user manually set the week)
    var manualOverride: Bool

    /// Schedule entries (one-to-many relationship)
    @Relationship(deleteRule: .cascade) var scheduleEntries: [ScheduleEntry]

    /// Owner of this timetable (inverse relationship)
    @Relationship(inverse: \User.timetableData) var owner: User?

    /// Initialise timetable data for a user
    /// - Parameter owner: The user who owns this timetable
    init(owner: User? = nil) {
        self.id = UUID()
        self.currentWeek = .weekA
        self.weekStartDate = Date()
        self.lastUpdated = Date()
        self.manualOverride = false
        self.scheduleEntries = []
        self.owner = owner
    }
}

// MARK: - Convenience Methods

extension TimetableData {
    /// Returns true if a PDF has been imported
    var hasPDF: Bool {
        pdfData != nil
    }

    /// Returns true if schedule entries exist
    var hasSchedule: Bool {
        !scheduleEntries.isEmpty
    }

    /// Update the last updated timestamp
    func markUpdated() {
        lastUpdated = Date()
    }

    /// Get schedule entries for a specific week and day
    /// - Parameters:
    ///   - week: Week type (A or B)
    ///   - day: Day of week
    /// - Returns: Array of schedule entries sorted by period
    func entries(for week: WeekType, on day: DayOfWeek) -> [ScheduleEntry] {
        scheduleEntries
            .filter { $0.week == week && $0.dayOfWeek == day }
            .sorted { $0.period < $1.period }
    }

    /// Get all schedule entries for a specific week
    /// - Parameter week: Week type (A or B)
    /// - Returns: Array of schedule entries sorted by day and period
    func entries(for week: WeekType) -> [ScheduleEntry] {
        scheduleEntries
            .filter { $0.week == week }
            .sorted { entry1, entry2 in
                if entry1.dayOfWeek == entry2.dayOfWeek {
                    return entry1.period < entry2.period
                }
                return entry1.dayOfWeek.rawValue < entry2.dayOfWeek.rawValue
            }
    }
}
