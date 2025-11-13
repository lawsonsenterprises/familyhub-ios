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
                        VStack(spacing: Spacing.xxs) {
                            ForEach(entries) { entry in
                                PeriodCard(
                                    entry: entry,
                                    isCurrent: isCurrentPeriod(entry)
                                )
                                .id(entry.id)
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.backgroundPrimary)
            .onAppear {
                updateCurrentPeriod()
                // Scroll to current or next period
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        // Try to scroll to current period first
                        if let current = entries.first(where: { isCurrentPeriod($0) }) {
                            proxy.scrollTo(current.id, anchor: .center)
                        }
                        // Otherwise, scroll to first entry
                        else if let first = entries.first {
                            proxy.scrollTo(first.id, anchor: .top)
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
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Time column (fixed width)
            if let times = TimetableCalculator.times(for: entry.period) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(times.start)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(isCurrent ? .primaryApp : .textPrimary)
                    Text(times.end)
                        .font(.callout)
                        .foregroundColor(.textTertiary)
                }
                .frame(width: 50)
            }

            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(isCurrent ? Color.primaryApp : Color.backgroundTertiary)
                .frame(width: 3)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(entry.subject)
                        .font(.body)
                        .fontWeight(isCurrent ? .semibold : .medium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Current indicator
                    if isCurrent {
                        Text("Now")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.primaryApp)
                            .cornerRadius(6)
                    }
                }

                HStack(spacing: 4) {
                    Text(entry.periodLabel)
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    if let teacher = entry.teacher {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                        Text(teacher)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    if !entry.room.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                        Text("Room \(entry.room)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isCurrent ? Color.primaryApp.opacity(0.08) : Color.clear)
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
