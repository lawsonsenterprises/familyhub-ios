//
//  TimetableModuleView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

struct TimetableModuleView: View {
    let user: User

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 64))
                        .foregroundColor(.textTertiary)

                    VStack(spacing: Spacing.xs) {
                        Text("Timetable Module")
                            .font(.sectionHeader)
                            .foregroundColor(.textPrimary)

                        Text("Week 1/2 timetable views will appear here")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    if user.isStudent {
                        Button {
                            // Import PDF action
                        } label: {
                            Label("Import Timetable PDF", systemImage: "doc.badge.plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.accentApp)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(Spacing.xl)
            }
            .navigationTitle("Timetable")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return TimetableModuleView(user: user)
}
