//
//  ContentView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @State private var selectedUser: User?
    @State private var hasCreatedInitialUsers = false

    var body: some View {
        Group {
            if users.isEmpty {
                FirstLaunchView()
            } else if let selectedUser {
                MainTabView(user: selectedUser, selectedUser: $selectedUser)
            } else {
                UserSelectionView(selectedUser: $selectedUser)
            }
        }
        .onAppear {
            createInitialUsersIfNeeded()
        }
    }

    // MARK: - Setup

    /// Creates initial test users for development if none exist
    private func createInitialUsersIfNeeded() {
        guard !hasCreatedInitialUsers && users.isEmpty else { return }
        hasCreatedInitialUsers = true

        // Create Amelia (student)
        let amelia = User(name: "Amelia", role: .student)
        let ameliaPreferences = UserPreferences()
        ameliaPreferences.user = amelia
        amelia.preferences = ameliaPreferences
        let ameliaTimetable = TimetableData(owner: amelia)
        amelia.timetableData = ameliaTimetable
        modelContext.insert(amelia)

        // Create Rachel (parent)
        let rachel = User(name: "Rachel", role: .parent)
        let rachelPreferences = UserPreferences()
        rachelPreferences.user = rachel
        rachel.preferences = rachelPreferences
        modelContext.insert(rachel)

        // Create Andy (parent)
        let andy = User(name: "Andy", role: .parent)
        let andyPreferences = UserPreferences()
        andyPreferences.user = andy
        andy.preferences = andyPreferences
        modelContext.insert(andy)

        do {
            try modelContext.save()
        } catch {
            print("Error creating initial users: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, TimetableData.self, ScheduleEntry.self, UserPreferences.self], inMemory: true)
}
