//
//  DashboardView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    let user: User

    @State private var currentDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Welcome message
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Hello, \(user.name)!")
                            .font(.screenTitle)
                            .foregroundColor(.textPrimary)

                        Text(currentDate.formatted(style: .long))
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)

                    // Content
                    VStack(spacing: Spacing.md) {
                        if user.isStudent, let timetableData = user.timetableData, timetableData.hasSchedule {
                            // Today's schedule
                            TodayScheduleCard(
                                timetableData: timetableData,
                                currentDate: currentDate
                            )
                        } else {
                            // No timetable - show placeholder
                            placeholderCard(
                                icon: "calendar.badge.clock",
                                title: "Today's Schedule",
                                description: user.isStudent ? "Import your timetable to see today's schedule" : "Timetables are available for students"
                            )
                        }

                        if user.isParent {
                            placeholderCard(
                                icon: "person.2.fill",
                                title: "Family Overview",
                                description: "See what everyone is up to"
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func placeholderCard(icon: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primaryApp)

                Text(title)
                    .font(.cardHeader)
                    .foregroundColor(.textPrimary)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return DashboardView(user: user)
}
