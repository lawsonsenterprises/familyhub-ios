//
//  SettingsView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    let user: User

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    var body: some View {
        NavigationStack {
            List {
                // User profile section
                Section {
                    HStack(spacing: Spacing.sm) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 60, height: 60)

                            Text(user.initials)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(user.name)
                                .font(.headline)
                                .foregroundColor(.textPrimary)

                            Text(user.role == .student ? "Student" : "Parent")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                } header: {
                    Text("Profile")
                }
                .listRowBackground(Material.periodCard)

                // App settings
                Section {
                    NavigationLink {
                        Text("Notifications settings")
                    } label: {
                        Label("Notifications", systemImage: "bell.fill")
                    }

                    if user.isStudent {
                        NavigationLink {
                            Text("Week configuration")
                        } label: {
                            Label("Week Configuration", systemImage: "calendar.badge.clock")
                        }
                    }
                } header: {
                    Text("App Settings")
                }
                .listRowBackground(Material.periodCard)

                // Family section
                Section {
                    ForEach(users) { familyUser in
                        HStack {
                            Text(familyUser.name)
                            Spacer()
                            Text(familyUser.role == .student ? "Student" : "Parent")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                } header: {
                    Text("Family Members")
                }
                .listRowBackground(Material.periodCard)

                // About section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.textSecondary)
                    }

                    Link(destination: URL(string: "https://developer.apple.com")!) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }

                    Link(destination: URL(string: "https://developer.apple.com")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("About")
                }
                .listRowBackground(Material.periodCard)
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundSecondary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return SettingsView(user: user)
        .modelContainer(for: [User.self], inMemory: true)
}
