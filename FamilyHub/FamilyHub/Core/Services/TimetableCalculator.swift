//
//  TimetableCalculator.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation

/// Service for calculating Week 1/2 and current period
struct TimetableCalculator {
    /// Calculate current week based on start date
    /// - Parameter startDate: Date when Week 1 started
    /// - Returns: Current week type (1 or 2)
    static func currentWeek(startDate: Date) -> WeekType {
        let weeksSinceStart = weeksSince(startDate: startDate)
        return weeksSinceStart % 2 == 0 ? .week1 : .week2
    }

    /// Calculate number of weeks since start date
    /// - Parameter startDate: Reference start date
    /// - Returns: Number of weeks elapsed
    static func weeksSince(startDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: Date())
        return abs(components.weekOfYear ?? 0)
    }

    /// Check if a schedule entry is currently active
    /// - Parameters:
    ///   - entry: Schedule entry to check
    ///   - date: Date to check against (defaults to now)
    ///   - currentWeek: Current week type
    /// - Returns: True if the entry is currently active
    static func isCurrentPeriod(
        entry: ScheduleEntry,
        date: Date = Date(),
        currentWeek: WeekType
    ) -> Bool {
        let calendar = Calendar.current

        // Check if it's the right week
        guard entry.week == currentWeek else {
            return false
        }

        // Check if it's the right day
        let currentWeekday = calendar.component(.weekday, from: date)
        let entryWeekday = weekdayNumber(for: entry.dayOfWeek)

        guard currentWeekday == entryWeekday else {
            return false
        }

        // If we have start and end times, check if current time is within range
        if let startTime = entry.startTime, let endTime = entry.endTime {
            return isTimeBetween(
                start: startTime,
                end: endTime,
                current: date
            )
        }

        // If no times specified, we can't determine if it's current
        return false
    }

    /// Get the next period for a user
    /// - Parameters:
    ///   - entries: All schedule entries
    ///   - date: Date to check from (defaults to now)
    ///   - currentWeek: Current week type
    /// - Returns: Next schedule entry, if any
    static func nextPeriod(
        from entries: [ScheduleEntry],
        date: Date = Date(),
        currentWeek: WeekType
    ) -> ScheduleEntry? {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)

        // Filter to current week and today or future days
        let relevantEntries = entries.filter { entry in
            entry.week == currentWeek &&
            weekdayNumber(for: entry.dayOfWeek) >= currentWeekday
        }

        // Sort by day and period
        let sortedEntries = relevantEntries.sorted { entry1, entry2 in
            let day1 = weekdayNumber(for: entry1.dayOfWeek)
            let day2 = weekdayNumber(for: entry2.dayOfWeek)

            if day1 == day2 {
                return entry1.period < entry2.period
            }
            return day1 < day2
        }

        // Find first entry that hasn't started yet
        for entry in sortedEntries {
            if let startTime = entry.startTime {
                if weekdayNumber(for: entry.dayOfWeek) > currentWeekday {
                    return entry
                } else if weekdayNumber(for: entry.dayOfWeek) == currentWeekday {
                    if !hasTimePassed(time: startTime, date: date) {
                        return entry
                    }
                }
            }
        }

        return nil
    }

    /// Convert DayOfWeek to calendar weekday number
    /// - Parameter day: Day of week enum
    /// - Returns: Calendar weekday number (1=Sunday, 2=Monday, etc.)
    private static func weekdayNumber(for day: DayOfWeek) -> Int {
        switch day {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        }
    }

    /// Check if current time is between start and end times
    /// - Parameters:
    ///   - start: Start time string (e.g., "09:00")
    ///   - end: End time string (e.g., "10:00")
    ///   - current: Current date
    /// - Returns: True if current time is within range
    private static func isTimeBetween(start: String, end: String, current: Date) -> Bool {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        guard let startDate = dateFormatter.date(from: start),
              let endDate = dateFormatter.date(from: end) else {
            return false
        }

        let currentComponents = calendar.dateComponents([.hour, .minute], from: current)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endDate)

        let currentMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)
        let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)

        return currentMinutes >= startMinutes && currentMinutes < endMinutes
    }

    /// Check if a time has passed
    /// - Parameters:
    ///   - time: Time string (e.g., "09:00")
    ///   - date: Current date
    /// - Returns: True if time has passed
    private static func hasTimePassed(time: String, date: Date) -> Bool {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        guard let timeDate = dateFormatter.date(from: time) else {
            return false
        }

        let currentComponents = calendar.dateComponents([.hour, .minute], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)

        let currentMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)
        let timeMinutes = (timeComponents.hour ?? 0) * 60 + (timeComponents.minute ?? 0)

        return currentMinutes >= timeMinutes
    }
}
