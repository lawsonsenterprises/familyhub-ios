//
//  TimetableData.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// Represents a user's timetable data including Week 1/2 configuration
@Model
final class TimetableData {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Current week type (Week 1 or Week 2)
    var currentWeek: WeekType

    /// Date when Week 1 started (reference point for calculation)
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
        self.currentWeek = .week1
        self.weekStartDate = Date()
        self.lastUpdated = Date()
        self.manualOverride = false
        self.scheduleEntries = []
        self.owner = owner
    }
}

// MARK: - Convenience Methods

extension TimetableData {
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
    ///   - week: Week type (1 or 2)
    ///   - day: Day of week
    /// - Returns: Array of schedule entries sorted by period
    func entries(for week: WeekType, on day: DayOfWeek) -> [ScheduleEntry] {
        scheduleEntries
            .filter { $0.week == week && $0.dayOfWeek == day }
            .sorted { $0.period < $1.period }
    }

    /// Get all schedule entries for a specific week
    /// - Parameter week: Week type (1 or 2)
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
