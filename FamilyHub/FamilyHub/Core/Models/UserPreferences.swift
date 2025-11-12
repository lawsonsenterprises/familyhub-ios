//
//  UserPreferences.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// User-specific preferences and settings
@Model
final class UserPreferences {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Enable notifications for class reminders
    var enableNotifications: Bool

    /// How many minutes before class to send notification
    var notificationMinutesBefore: Int

    /// Preferred timetable view mode (day, week, fortnight)
    var preferredViewMode: ViewMode

    /// User who owns these preferences (inverse relationship)
    @Relationship(inverse: \User.preferences) var user: User?

    /// Initialise with default preferences
    init() {
        self.id = UUID()
        self.enableNotifications = true
        self.notificationMinutesBefore = 10
        self.preferredViewMode = .day
    }
}

// MARK: - Convenience Methods

extension UserPreferences {
    /// Update notification settings
    /// - Parameters:
    ///   - enabled: Whether notifications are enabled
    ///   - minutesBefore: Minutes before class to notify
    func updateNotificationSettings(enabled: Bool, minutesBefore: Int) {
        self.enableNotifications = enabled
        self.notificationMinutesBefore = minutesBefore
    }

    /// Update preferred view mode
    /// - Parameter mode: New preferred view mode
    func updateViewMode(_ mode: ViewMode) {
        self.preferredViewMode = mode
    }
}
