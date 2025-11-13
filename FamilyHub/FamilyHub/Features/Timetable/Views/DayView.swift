//
//  DayView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Day view showing today's timetable with current period highlighting
struct DayView: View {
    let timetableData: TimetableData
    let selectedWeek: WeekType
    let currentDate: Date

    @State private var currentPeriod: ScheduleEntry?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Date header
                    dateHeader

                    // Schedule entries
                    if entries.isEmpty {
                        emptyState
                    } else {
                        ForEach(entries) { entry in
                            PeriodCard(
                                entry: entry,
                                isCurrent: isCurrentPeriod(entry)
                            )
                            .id(entry.id)
                        }
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.backgroundPrimary)
            .onAppear {
                updateCurrentPeriod()
                // Scroll to current period
                if let current = entries.first(where: { isCurrentPeriod($0) }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(current.id, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    // MARK: - View Components

    private var dateHeader: some View {
        VStack(spacing: Spacing.xxs) {
            Text(currentDate, style: .date)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            Text(dayOfWeek.rawValue)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)

            VStack(spacing: Spacing.xs) {
                Text("No Classes Today")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Enjoy your day off!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    // MARK: - Computed Properties

    private var dayOfWeek: DayOfWeek {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)

        switch weekday {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .monday // Fallback for weekend
        }
    }

    private var entries: [ScheduleEntry] {
        timetableData.entries(for: selectedWeek, on: dayOfWeek)
    }

    // MARK: - Helper Methods

    private func isCurrentPeriod(_ entry: ScheduleEntry) -> Bool {
        TimetableCalculator.isCurrentPeriod(
            entry: entry,
            date: currentDate,
            currentWeek: selectedWeek
        )
    }

    private func updateCurrentPeriod() {
        currentPeriod = entries.first { isCurrentPeriod($0) }
    }
}

// MARK: - Period Card

struct PeriodCard: View {
    let entry: ScheduleEntry
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Time indicator
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                if let startTime = entry.startTime {
                    Text(startTime)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isCurrent ? .primaryApp : .textSecondary)
                }

                if let endTime = entry.endTime {
                    Text(endTime)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
            }
            .frame(width: 50, alignment: .leading)

            // Period info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(entry.subject)
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                HStack(spacing: Spacing.xs) {
                    if let teacher = entry.teacher {
                        Text(teacher)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }

                    if !entry.room.isEmpty {
                        Text("•")
                            .foregroundColor(.textTertiary)
                        Text("Room \(entry.room)")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            Spacer()

            // Current indicator
            if isCurrent {
                Circle()
                    .fill(Color.primaryApp)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent ? Color.primaryApp.opacity(0.1) : Color.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isCurrent ? Color.primaryApp.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

#Preview {
    let timetableData = TimetableData(owner: nil)
    return DayView(
        timetableData: timetableData,
        selectedWeek: .week1,
        currentDate: Date()
    )
}
