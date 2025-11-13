//
//  ScheduleEntry.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// Represents a single period in the timetable
@Model
final class ScheduleEntry {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Day of the week
    var dayOfWeek: DayOfWeek

    /// Period number (1, 2, 3, etc.)
    var period: Int

    /// Subject name (e.g., "Mathematics", "English")
    var subject: String

    /// Room number or name
    var room: String

    /// Teacher name or code (optional)
    var teacher: String?

    /// Week type (A or B)
    var week: WeekType

    /// Start time (e.g., "09:00") - optional
    var startTime: String?

    /// End time (e.g., "10:00") - optional
    var endTime: String?

    /// Parent timetable data (inverse relationship)
    @Relationship(inverse: \TimetableData.scheduleEntries) var timetableData: TimetableData?

    /// Initialise a schedule entry
    /// - Parameters:
    ///   - dayOfWeek: Day of the week
    ///   - period: Period number
    ///   - subject: Subject name
    ///   - room: Room number/name
    ///   - week: Week type (A or B)
    ///   - teacher: Optional teacher name/code
    ///   - startTime: Optional start time
    ///   - endTime: Optional end time
    init(
        dayOfWeek: DayOfWeek,
        period: Int,
        subject: String,
        room: String,
        week: WeekType,
        teacher: String? = nil,
        startTime: String? = nil,
        endTime: String? = nil
    ) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.period = period
        self.subject = subject
        self.room = room
        self.week = week
        self.teacher = teacher
        self.startTime = startTime
        self.endTime = endTime
    }
}

// MARK: - Convenience Properties

extension ScheduleEntry {
    /// Returns formatted time range (e.g., "09:00 - 10:00")
    var timeRange: String? {
        guard let start = startTime, let end = endTime else {
            return nil
        }
        return "\(start) - \(end)"
    }

    /// Returns a display string for the entry (e.g., "Period 3: Mathematics")
    var displayTitle: String {
        "Period \(period): \(subject)"
    }

    /// Returns a secondary display string (e.g., "Room 12 • KCO")
    var displaySubtitle: String {
        if let teacher {
            return "\(room) • \(teacher)"
        }
        return room
    }

    /// Returns the period label for display
    /// Maps internal period numbers to user-friendly labels:
    /// - 0 → "Tutor" (AM Registration)
    /// - 1-4 → "P1", "P2", "P3", "P4"
    /// - 5 → "Tutor" (PM Registration)
    /// - 6 → "P5"
    var periodLabel: String {
        switch period {
        case 0: return "Tutor"
        case 1: return "P1"
        case 2: return "P2"
        case 3: return "P3"
        case 4: return "P4"
        case 5: return "Tutor"
        case 6: return "P5"
        default: return "P\(period)"
        }
    }
}
