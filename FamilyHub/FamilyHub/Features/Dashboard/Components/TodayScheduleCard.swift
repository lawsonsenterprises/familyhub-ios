//
//  TodayScheduleCard.swift
//  FamilyHub
//
//  Created by Claude Code on 13/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Card showing today's timetable schedule with current period highlighting
struct TodayScheduleCard: View {
    let timetableData: TimetableData
    let currentDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack(spacing: Spacing.sm) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.primaryApp)

                Text("Today's Schedule")
                    .font(.cardHeader)
                    .foregroundColor(.textPrimary)

                Spacer()

                // Day name
                Text(dayOfWeek.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textSecondary)
            }

            // Schedule content
            if isWeekend {
                // Weekend message
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "sun.max.fill")
                        .font(.title3)
                        .foregroundColor(.orange)

                    Text("No Classes Today")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Text("Enjoy your weekend!")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
            } else if todayEntries.isEmpty {
                // No classes scheduled
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title3)
                        .foregroundColor(.orange)

                    Text("No Classes Scheduled")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Text("Check your timetable for details")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
            } else {
                // Show classes
                VStack(spacing: Spacing.xs) {
                    ForEach(todayEntries.prefix(5)) { entry in
                        TodayPeriodRow(
                            entry: entry,
                            isCurrent: isCurrentPeriod(entry),
                            isNext: isNextPeriod(entry)
                        )
                    }

                    // Show more indicator
                    if todayEntries.count > 5 {
                        Text("+ \(todayEntries.count - 5) more")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                            .padding(.top, Spacing.xxs)
                    }
                }
            }
        }
        .cardStyle()
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
        default: return .monday // Fallback
        }
    }

    private var isWeekend: Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        return weekday == 1 || weekday == 7 // Sunday or Saturday
    }

    private var currentWeek: WeekType {
        TimetableCalculator.currentWeek(startDate: timetableData.weekStartDate)
    }

    private var todayEntries: [ScheduleEntry] {
        timetableData.entries(for: currentWeek, on: dayOfWeek)
    }

    private var currentPeriod: ScheduleEntry? {
        todayEntries.first { isCurrentPeriod($0) }
    }

    private var nextPeriod: ScheduleEntry? {
        guard let current = currentPeriod,
              let currentIndex = todayEntries.firstIndex(where: { $0.id == current.id }),
              currentIndex + 1 < todayEntries.count else {
            return todayEntries.first
        }
        return todayEntries[currentIndex + 1]
    }

    // MARK: - Helper Methods

    private func isCurrentPeriod(_ entry: ScheduleEntry) -> Bool {
        TimetableCalculator.isCurrentPeriod(
            entry: entry,
            date: currentDate,
            currentWeek: currentWeek
        )
    }

    private func isNextPeriod(_ entry: ScheduleEntry) -> Bool {
        guard let next = nextPeriod else { return false }
        return entry.id == next.id
    }
}

// MARK: - Today Period Row

struct TodayPeriodRow: View {
    let entry: ScheduleEntry
    let isCurrent: Bool
    let isNext: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Period label
            Text(entry.periodLabel)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(isCurrent ? .white : .textTertiary)
                .frame(width: 40, alignment: .leading)
                .padding(.horizontal, Spacing.xxs)
                .padding(.vertical, 2)
                .background(isCurrent ? Color.primaryApp : Color.clear)
                .cornerRadius(4)

            // Subject
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.subject)
                    .font(.caption)
                    .fontWeight(isCurrent ? .semibold : .regular)
                    .foregroundColor(isCurrent ? .primaryApp : .textPrimary)
                    .lineLimit(1)

                if !entry.room.isEmpty {
                    Text("Room \(entry.room)")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            // Current/Next indicator
            if isCurrent {
                HStack(spacing: Spacing.xxs) {
                    Circle()
                        .fill(Color.primaryApp)
                        .frame(width: 6, height: 6)

                    Text("Now")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryApp)
                }
            } else if isNext {
                Text("Next")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(
            isCurrent ? Color.primaryApp.opacity(0.08) : Color.clear
        )
        .cornerRadius(6)
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    let timetableData = TimetableData(owner: user)

    // Add sample entries
    let entries = [
        ScheduleEntry(dayOfWeek: .monday, period: 0, subject: "AM Registration", room: "512", week: .week1, teacher: "KCO"),
        ScheduleEntry(dayOfWeek: .monday, period: 1, subject: "English Language", room: "53", week: .week1, teacher: "BBR"),
        ScheduleEntry(dayOfWeek: .monday, period: 2, subject: "History", room: "417", week: .week1, teacher: "ERE"),
        ScheduleEntry(dayOfWeek: .monday, period: 3, subject: "PE", room: "7", week: .week1, teacher: "MRO"),
        ScheduleEntry(dayOfWeek: .monday, period: 4, subject: "Computer Science", room: "247", week: .week1, teacher: "ALW"),
        ScheduleEntry(dayOfWeek: .monday, period: 5, subject: "PM Registration", room: "512", week: .week1, teacher: "KCO"),
        ScheduleEntry(dayOfWeek: .monday, period: 6, subject: "Mathematics", room: "113", week: .week1, teacher: "KDN")
    ]

    for entry in entries {
        timetableData.scheduleEntries.append(entry)
    }

    return TodayScheduleCard(
        timetableData: timetableData,
        currentDate: Date()
    )
    .padding()
}
