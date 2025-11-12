//
//  DataService.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// Service for managing SwiftData operations
@MainActor
final class DataService {
    /// Shared singleton instance
    static let shared = DataService()

    /// SwiftData model container
    let modelContainer: ModelContainer

    /// Private initializer for singleton
    private init() {
        let schema = Schema([
            User.self,
            TimetableData.self,
            ScheduleEntry.self,
            UserPreferences.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // iCloud sync enabled
        )

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: - User Management

extension DataService {
    /// Create a new user
    /// - Parameters:
    ///   - name: User's name
    ///   - role: User's role
    ///   - context: Model context to use
    /// - Returns: The created user
    func createUser(name: String, role: UserRole, context: ModelContext) -> User {
        let user = User(name: name, role: role)

        // Create default preferences
        let preferences = UserPreferences()
        preferences.user = user
        user.preferences = preferences

        // Create empty timetable data for students
        if role == .student {
            let timetableData = TimetableData(owner: user)
            user.timetableData = timetableData
        }

        context.insert(user)

        do {
            try context.save()
        } catch {
            print("Error saving user: \(error)")
        }

        return user
    }

    /// Fetch all users
    /// - Parameter context: Model context to use
    /// - Returns: Array of all users
    func fetchUsers(context: ModelContext) -> [User] {
        let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.createdAt)])

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }

    /// Delete a user
    /// - Parameters:
    ///   - user: User to delete
    ///   - context: Model context to use
    func deleteUser(_ user: User, context: ModelContext) {
        context.delete(user)

        do {
            try context.save()
        } catch {
            print("Error deleting user: \(error)")
        }
    }
}

// MARK: - Timetable Management

extension DataService {
    /// Save timetable data
    /// - Parameters:
    ///   - timetable: Timetable data to save
    ///   - context: Model context to use
    func saveTimetable(_ timetable: TimetableData, context: ModelContext) {
        timetable.markUpdated()

        do {
            try context.save()
        } catch {
            print("Error saving timetable: \(error)")
        }
    }

    /// Fetch timetable for a user
    /// - Parameters:
    ///   - user: User to fetch timetable for
    ///   - context: Model context to use
    /// - Returns: User's timetable data, if it exists
    func fetchTimetable(for user: User, context: ModelContext) -> TimetableData? {
        return user.timetableData
    }

    /// Add schedule entry to timetable
    /// - Parameters:
    ///   - entry: Schedule entry to add
    ///   - timetable: Timetable to add to
    ///   - context: Model context to use
    func addScheduleEntry(_ entry: ScheduleEntry, to timetable: TimetableData, context: ModelContext) {
        entry.timetableData = timetable
        timetable.scheduleEntries.append(entry)
        timetable.markUpdated()

        do {
            try context.save()
        } catch {
            print("Error adding schedule entry: \(error)")
        }
    }

    /// Remove schedule entry from timetable
    /// - Parameters:
    ///   - entry: Schedule entry to remove
    ///   - context: Model context to use
    func removeScheduleEntry(_ entry: ScheduleEntry, context: ModelContext) {
        context.delete(entry)

        do {
            try context.save()
        } catch {
            print("Error removing schedule entry: \(error)")
        }
    }
}
