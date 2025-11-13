//
//  WeekView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Week view showing Monday-Friday schedule in a grid layout
struct WeekView: View {
    let timetableData: TimetableData
    let selectedWeek: WeekType

    private let days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(days, id: \.self) { day in
                        DaySection(
                            day: day,
                            entries: timetableData.entries(for: selectedWeek, on: day),
                            isToday: isToday(day),
                            selectedWeek: selectedWeek
                        )
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.backgroundPrimary)
            .onAppear {
                // Scroll to current or next period
                let currentDay = currentDayOfWeek()
                let entries = timetableData.entries(for: selectedWeek, on: currentDay)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        // Try to scroll to current period first
                        if let current = entries.first(where: { isCurrentPeriod($0) }) {
                            proxy.scrollTo(current.id, anchor: .center)
                        }
                        // Otherwise, scroll to first entry of today
                        else if let firstToday = entries.first {
                            proxy.scrollTo(firstToday.id, anchor: .top)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func isToday(_ day: DayOfWeek) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())

        let dayNumber: Int
        switch day {
        case .monday: dayNumber = 2
        case .tuesday: dayNumber = 3
        case .wednesday: dayNumber = 4
        case .thursday: dayNumber = 5
        case .friday: dayNumber = 6
        }

        return weekday == dayNumber
    }

    private func currentDayOfWeek() -> DayOfWeek {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())

        switch weekday {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .monday // Fallback for weekend
        }
    }

    private func isCurrentPeriod(_ entry: ScheduleEntry) -> Bool {
        TimetableCalculator.isCurrentPeriod(
            entry: entry,
            currentWeek: selectedWeek
        )
    }
}

// MARK: - Day Section

struct DaySection: View {
    let day: DayOfWeek
    let entries: [ScheduleEntry]
    let isToday: Bool
    let selectedWeek: WeekType

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Day header
            HStack {
                Text(day.rawValue)
                    .font(.headline)
                    .foregroundColor(isToday ? .primaryApp : .textPrimary)

                if isToday {
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.primaryApp)
                        .clipShape(Capsule())
                }

                Spacer()

                Text("\(entries.count) \(entries.count == 1 ? "class" : "classes")")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.bottom, Spacing.xxs)

            // Entries
            if entries.isEmpty {
                Text("No classes")
                    .font(.subheadline)
                    .foregroundColor(.textTertiary)
                    .padding(.vertical, Spacing.sm)
            } else {
                VStack(spacing: Spacing.xxs) {
                    ForEach(entries) { entry in
                        CompactPeriodCard(
                            entry: entry,
                            isCurrent: isToday && isCurrentPeriod(entry)
                        )
                        .id(entry.id)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isToday ? Color.primaryApp.opacity(0.05) : Color.backgroundTertiary)
        )
    }

    // MARK: - Helper Methods

    private func isCurrentPeriod(_ entry: ScheduleEntry) -> Bool {
        TimetableCalculator.isCurrentPeriod(
            entry: entry,
            currentWeek: selectedWeek
        )
    }
}

// MARK: - Compact Period Card

struct CompactPeriodCard: View {
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
    return WeekView(
        timetableData: timetableData,
        selectedWeek: .week1
    )
}
