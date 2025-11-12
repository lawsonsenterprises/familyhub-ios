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

    @State private var selectedWeek: WeekType = .week1
    @State private var viewMode: ViewMode = .week
    @State private var manualOverride: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let timetableData = user.timetableData, timetableData.hasSchedule {
                    // Week selector
                    WeekSelector(
                        selectedWeek: $selectedWeek,
                        calculatedWeek: calculatedWeek,
                        manualOverride: manualOverride,
                        onToggle: toggleWeek
                    )
                    .padding(Spacing.md)

                    // View mode picker
                    viewModePicker
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.sm)

                    // Content based on view mode
                    Group {
                        switch viewMode {
                        case .day:
                            DayView(
                                timetableData: timetableData,
                                selectedWeek: selectedWeek,
                                currentDate: Date()
                            )
                        case .week:
                            WeekView(
                                timetableData: timetableData,
                                selectedWeek: selectedWeek
                            )
                        case .fortnight:
                            FortnightView(
                                timetableData: timetableData,
                                selectedWeek: selectedWeek
                            )
                        }
                    }
                } else {
                    // Empty state
                    emptyState
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Timetable")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                updateSelectedWeek()
            }
        }
    }

    // MARK: - View Components

    private var viewModePicker: some View {
        Picker("View Mode", selection: $viewMode) {
            ForEach([ViewMode.day, ViewMode.week, ViewMode.fortnight], id: \.self) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(.textTertiary)

            VStack(spacing: Spacing.xs) {
                Text("No Timetable Yet")
                    .font(.sectionHeader)
                    .foregroundColor(.textPrimary)

                Text("Import a PDF timetable to get started")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if user.isStudent {
                Button {
                    // Import PDF action (Phase 2.2)
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

            Spacer()
        }
        .padding(Spacing.xl)
    }

    // MARK: - Computed Properties

    private var calculatedWeek: WeekType {
        guard let timetableData = user.timetableData else {
            return .week1
        }
        return TimetableCalculator.currentWeek(startDate: timetableData.weekStartDate)
    }

    // MARK: - Actions

    private func toggleWeek() {
        selectedWeek.toggle()
        manualOverride = (selectedWeek != calculatedWeek)
    }

    private func updateSelectedWeek() {
        guard let timetableData = user.timetableData else { return }

        if timetableData.manualOverride {
            selectedWeek = timetableData.currentWeek
            manualOverride = true
        } else {
            selectedWeek = calculatedWeek
            manualOverride = false
        }
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return TimetableModuleView(user: user)
}
