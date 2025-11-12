//
//  MainTabView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    let user: User

    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(user: user)
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
                .tag(Tab.dashboard)

            TimetableModuleView(user: user)
                .tabItem {
                    Label("Timetable", systemImage: "calendar")
                }
                .tag(Tab.timetable)

            SettingsView(user: user)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            HapticManager.light()
        }
    }

    enum Tab {
        case dashboard
        case timetable
        case settings
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return MainTabView(user: user)
        .modelContainer(for: [User.self], inMemory: true)
}
