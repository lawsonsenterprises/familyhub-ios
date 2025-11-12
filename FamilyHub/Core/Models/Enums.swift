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

/// Week type for timetable rotation (Week A or Week B)
enum WeekType: String, Codable, CaseIterable {
    case weekA = "Week A"
    case weekB = "Week B"

    /// Toggle between Week A and Week B
    mutating func toggle() {
        self = self == .weekA ? .weekB : .weekA
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
