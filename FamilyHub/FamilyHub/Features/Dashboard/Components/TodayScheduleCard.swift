//
//  TodayScheduleCard.swift
//  FamilyHub
//
//  Created by Claude Code on 13/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Represents a scheduled item (period, break, or lunch)
enum ScheduleItem: Identifiable {
    case period(ScheduleEntry)
    case break_
    case lunch

    var id: String {
        switch self {
        case .period(let entry):
            return entry.id.uuidString
        case .break_:
            return "break"
        case .lunch:
            return "lunch"
        }
    }
}

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
                // Show schedule with breaks/lunch
                VStack(spacing: Spacing.xxs) {
                    ForEach(scheduleItems) { item in
                        switch item {
                        case .period(let entry):
                            TodayPeriodRow(
                                entry: entry,
                                isCurrent: isCurrentPeriod(entry)
                            )
                        case .break_:
                            BreakRow(type: .break_, isCurrent: isCurrentBreak)
                        case .lunch:
                            BreakRow(type: .lunch, isCurrent: isCurrentLunch)
                        }
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

    /// Build schedule items including breaks and lunch
    private var scheduleItems: [ScheduleItem] {
        var items: [ScheduleItem] = []

        for entry in todayEntries {
            // Add break after Period 2 (before Period 3)
            if entry.period == 3 && !items.contains(where: { if case .break_ = $0 { return true }; return false }) {
                items.append(.break_)
            }

            items.append(.period(entry))

            // Add lunch after Period 4 (before TUTPM/Period 5)
            if entry.period == 4 && !items.contains(where: { if case .lunch = $0 { return true }; return false }) {
                items.append(.lunch)
            }
        }

        return items
    }

    private var isCurrentBreak: Bool {
        TimetableCalculator.isTimeBetween(
            start: "10:45",
            end: "11:05",
            current: currentDate
        )
    }

    private var isCurrentLunch: Bool {
        TimetableCalculator.isTimeBetween(
            start: "13:05",
            end: "13:35",
            current: currentDate
        )
    }

    // MARK: - Helper Methods

    private func isCurrentPeriod(_ entry: ScheduleEntry) -> Bool {
        TimetableCalculator.isCurrentPeriod(
            entry: entry,
            date: currentDate,
            currentWeek: currentWeek
        )
    }
}

// MARK: - Today Period Row

struct TodayPeriodRow: View {
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

// MARK: - Break Row

struct BreakRow: View {
    enum BreakType {
        case break_
        case lunch

        var title: String {
            switch self {
            case .break_: return "Break"
            case .lunch: return "Lunch"
            }
        }

        var icon: String {
            switch self {
            case .break_: return "cup.and.saucer.fill"
            case .lunch: return "fork.knife"
            }
        }

        var times: (start: String, end: String) {
            switch self {
            case .break_: return ("10:45", "11:05")
            case .lunch: return ("13:05", "13:35")
            }
        }

        var duration: String {
            switch self {
            case .break_: return "20 min"
            case .lunch: return "30 min"
            }
        }
    }

    let type: BreakType
    let isCurrent: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Time column (fixed width)
            VStack(alignment: .trailing, spacing: 2) {
                Text(type.times.start)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(isCurrent ? .primaryApp : .textPrimary)
                Text(type.times.end)
                    .font(.callout)
                    .foregroundColor(.textTertiary)
            }
            .frame(width: 50)

            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(isCurrent ? Color.primaryApp : Color.backgroundTertiary.opacity(0.5))
                .frame(width: 3)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.callout)
                            .foregroundColor(isCurrent ? .primaryApp : .textSecondary)

                        Text(type.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(isCurrent ? .primaryApp : .textSecondary)
                    }

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

                Text(type.duration)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
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
