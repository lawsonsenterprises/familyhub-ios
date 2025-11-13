//
//  FortnightView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Fortnight view showing both Week 1 and Week 2 side-by-side for comparison
struct FortnightView: View {
    let timetableData: TimetableData
    let selectedWeek: WeekType

    private let days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                ForEach(days, id: \.self) { day in
                    FortnightDaySection(
                        day: day,
                        week1Entries: timetableData.entries(for: .week1, on: day),
                        week2Entries: timetableData.entries(for: .week2, on: day),
                        isToday: isToday(day),
                        selectedWeek: selectedWeek
                    )
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.backgroundPrimary)
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
}

// MARK: - Fortnight Day Section

struct FortnightDaySection: View {
    let day: DayOfWeek
    let week1Entries: [ScheduleEntry]
    let week2Entries: [ScheduleEntry]
    let isToday: Bool
    let selectedWeek: WeekType

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
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
            }

            // Week comparison
            HStack(alignment: .top, spacing: Spacing.sm) {
                // Week 1
                WeekColumn(
                    weekType: .week1,
                    entries: week1Entries,
                    isSelected: selectedWeek == .week1
                )

                // Week 2
                WeekColumn(
                    weekType: .week2,
                    entries: week2Entries,
                    isSelected: selectedWeek == .week2
                )
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.backgroundTertiary)
        )
    }
}

// MARK: - Week Column

struct WeekColumn: View {
    let weekType: WeekType
    let entries: [ScheduleEntry]
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Week header
            HStack(spacing: Spacing.xxs) {
                Circle()
                    .fill(weekType == .week1 ? Color.week1 : Color.week2)
                    .frame(width: 8, height: 8)

                Text(weekType.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)
            }
            .padding(.bottom, Spacing.xxs)

            // Entries
            if entries.isEmpty {
                Text("No classes")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                    .padding(.vertical, Spacing.xs)
            } else {
                VStack(spacing: Spacing.xxs) {
                    ForEach(entries) { entry in
                        MinimalPeriodCard(entry: entry, isHighlighted: isSelected)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isSelected ? Color.backgroundSecondary : Color.backgroundPrimary.opacity(0.5))
        )
    }
}

// MARK: - Minimal Period Card

struct MinimalPeriodCard: View {
    let entry: ScheduleEntry
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.subject)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isHighlighted ? .textPrimary : .textSecondary)
                .lineLimit(1)

            HStack(spacing: Spacing.xxs) {
                if let times = TimetableCalculator.times(for: entry.period) {
                    Text(times.start)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }

                if !entry.room.isEmpty {
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                    Text("R\(entry.room)")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.backgroundSecondary.opacity(isHighlighted ? 0.8 : 0.4))
        )
    }
}

#Preview {
    let timetableData = TimetableData(owner: nil)
    return FortnightView(
        timetableData: timetableData,
        selectedWeek: .week1
    )
}
