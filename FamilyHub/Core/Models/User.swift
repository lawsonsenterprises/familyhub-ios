//
//  User.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// Represents a family member using the app
@Model
final class User {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// User's display name
    var name: String

    /// User's role (student or parent)
    var role: UserRole

    /// Optional avatar image data
    var avatarData: Data?

    /// Creation timestamp
    var createdAt: Date

    /// User's timetable data (one-to-one relationship)
    @Relationship(deleteRule: .cascade) var timetableData: TimetableData?

    /// User's preferences (one-to-one relationship)
    @Relationship(deleteRule: .cascade) var preferences: UserPreferences?

    /// Initialise a new user
    /// - Parameters:
    ///   - name: User's display name
    ///   - role: User's role (student or parent)
    init(name: String, role: UserRole) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.createdAt = Date()
    }
}

// MARK: - Convenience Properties

extension User {
    /// Returns true if the user is a student
    var isStudent: Bool {
        role == .student
    }

    /// Returns true if the user is a parent
    var isParent: Bool {
        role == .parent
    }

    /// Returns initials from the user's name (e.g., "Amelia Smith" -> "AS")
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.joined()
    }
}
