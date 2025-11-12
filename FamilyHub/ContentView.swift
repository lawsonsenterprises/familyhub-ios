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

    var body: some View {
        Group {
            if users.isEmpty {
                // First launch - create initial user
                FirstLaunchView()
            } else if let selectedUser {
                // User selected - show main app
                MainTabView(user: selectedUser)
            } else {
                // Show user selection
                UserSelectionView(selectedUser: $selectedUser)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, TimetableData.self, ScheduleEntry.self, UserPreferences.self], inMemory: true)
}
