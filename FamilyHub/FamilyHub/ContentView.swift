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
        let _ = print("📱 CONTENTVIEW body evaluated. selectedUser = \(String(describing: selectedUser?.name)), users.count = \(users.count)")

        return Group {
            if users.isEmpty {
                let _ = print("🟡 CONTENTVIEW - Showing FirstLaunchView (no users)")
                FirstLaunchView()
            } else if let selectedUser {
                let _ = print("🟢 CONTENTVIEW - Showing MainTabView for: \(selectedUser.name)")
                MainTabView(user: selectedUser, selectedUser: $selectedUser)
            } else {
                let _ = print("🟠 CONTENTVIEW - Showing UserSelectionView (no user selected)")
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
            print("✅ Created initial test users: Amelia, Rachel, Andy")
        } catch {
            print("❌ Error creating initial users: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, TimetableData.self, ScheduleEntry.self, UserPreferences.self], inMemory: true)
}
