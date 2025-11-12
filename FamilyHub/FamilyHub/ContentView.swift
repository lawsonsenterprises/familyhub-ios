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
        let _ = print("📱 CONTENTVIEW body evaluated. selectedUser = \(String(describing: selectedUser?.name)), users.count = \(users.count)")

        return Group {
            if users.isEmpty {
                let _ = print("🟡 CONTENTVIEW - Showing FirstLaunchView (no users)")
                FirstLaunchView()
            } else if let selectedUser {
                let _ = print("🟢 CONTENTVIEW - Showing MainTabView for: \(selectedUser.name)")
                MainTabView(user: selectedUser)
            } else {
                let _ = print("🟠 CONTENTVIEW - Showing UserSelectionView (no user selected)")
                UserSelectionView(selectedUser: $selectedUser)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, TimetableData.self, ScheduleEntry.self, UserPreferences.self], inMemory: true)
}
