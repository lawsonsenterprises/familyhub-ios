//
//  Enums.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation

/// User roles within the family app
enum UserRole: String, Codable {
    case student
    case parent
}

/// Week type for timetable rotation (Week 1 or Week 2)
enum WeekType: String, Codable, CaseIterable {
    case week1 = "Week 1"
    case week2 = "Week 2"

    /// Toggle between Week 1 and Week 2
    mutating func toggle() {
        self = self == .week1 ? .week2 : .week1
    }
}

/// Days of the school week
enum DayOfWeek: String, Codable, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"

    /// SF Symbol name for the day
    var symbolName: String {
        switch self {
        case .monday: return "calendar"
        case .tuesday: return "calendar"
        case .wednesday: return "calendar"
        case .thursday: return "calendar"
        case .friday: return "calendar"
        }
    }

    /// Short name for the day (3 letters)
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        }
    }
}

/// Timetable view modes
enum ViewMode: String, Codable {
    case day
    case week
    case fortnight

    var displayName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .fortnight: return "Fortnight"
        }
    }
}
