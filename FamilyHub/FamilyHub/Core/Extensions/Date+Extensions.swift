//
//  Date+Extensions.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the start of the current week (Monday)
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Returns the day of the week as DayOfWeek enum
    var dayOfWeek: DayOfWeek? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)

        switch weekday {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return nil // Weekend
        }
    }

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Check if date is a weekday (Monday-Friday)
    var isWeekday: Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        return weekday >= 2 && weekday <= 6
    }

    /// Format date as "Monday, 12 Nov"
    func formatted(style: DateFormatterStyle) -> String {
        let formatter = DateFormatter()

        switch style {
        case .short:
            formatter.dateFormat = "d MMM"
        case .medium:
            formatter.dateFormat = "E, d MMM"
        case .long:
            formatter.dateFormat = "EEEE, d MMMM"
        case .full:
            formatter.dateFormat = "EEEE, d MMMM yyyy"
        }

        return formatter.string(from: self)
    }

    /// Get date components for display
    var displayComponents: (day: String, month: String, weekday: String) {
        let formatter = DateFormatter()

        formatter.dateFormat = "d"
        let day = formatter.string(from: self)

        formatter.dateFormat = "MMM"
        let month = formatter.string(from: self)

        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: self)

        return (day, month, weekday)
    }
}

// MARK: - Date Formatter Styles

enum DateFormatterStyle {
    case short   // "12 Nov"
    case medium  // "Mon, 12 Nov"
    case long    // "Monday, 12 November"
    case full    // "Monday, 12 November 2025"
}
