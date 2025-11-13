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
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ForEach(days, id: \.self) { day in
                    DaySection(
                        day: day,
                        entries: timetableData.entries(for: selectedWeek, on: day),
                        isToday: isToday(day)
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

// MARK: - Day Section

struct DaySection: View {
    let day: DayOfWeek
    let entries: [ScheduleEntry]
    let isToday: Bool

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
                VStack(spacing: Spacing.xs) {
                    ForEach(entries) { entry in
                        CompactPeriodCard(entry: entry)
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
}

// MARK: - Compact Period Card

struct CompactPeriodCard: View {
    let entry: ScheduleEntry

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Time
            if let startTime = entry.startTime {
                Text(startTime)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                    .frame(width: 45, alignment: .leading)
            }

            // Subject and details
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.subject)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                if !entry.room.isEmpty {
                    Text("Room \(entry.room)")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            // Period label
            Text(entry.periodLabel)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.textTertiary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    let timetableData = TimetableData(owner: nil)
    return WeekView(
        timetableData: timetableData,
        selectedWeek: .week1
    )
}
