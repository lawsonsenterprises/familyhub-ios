//
//  CSVImportPreviewView.swift
//  FamilyHub
//
//  Created by Claude Code on 13/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Preview view for CSV import showing validation results
struct CSVImportPreviewView: View {
    let parseResult: CSVParser.ParseResult
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var showErrors = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary section
                summarySection
                    .padding(Spacing.md)
                    .background(Color.backgroundSecondary)

                Divider()

                // Content
                if parseResult.hasErrors {
                    ScrollView {
                        VStack(spacing: Spacing.md) {
                            // Errors section
                            if showErrors {
                                errorsSection
                            }

                            // Success preview
                            if parseResult.successCount > 0 {
                                successSection
                            }
                        }
                        .padding(Spacing.md)
                    }
                } else {
                    // All valid - show success
                    ScrollView {
                        successSection
                            .padding(Spacing.md)
                    }
                }

                Divider()

                // Action buttons
                actionButtons
                    .padding(Spacing.md)
                    .background(Color.backgroundSecondary)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Import Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - View Components

    private var summarySection: some View {
        VStack(spacing: Spacing.sm) {
            // Icon and title
            HStack(spacing: Spacing.sm) {
                Image(systemName: parseResult.hasErrors ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(parseResult.hasErrors ? .orange : .green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CSV Import Preview")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text("\(parseResult.totalRows) rows processed")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // Statistics
            HStack(spacing: Spacing.md) {
                statBadge(
                    title: "Valid",
                    value: "\(parseResult.successCount)",
                    colour: .green
                )

                if parseResult.hasErrors {
                    statBadge(
                        title: "Errors",
                        value: "\(parseResult.errorCount)",
                        colour: .orange
                    )
                }

                Spacer()
            }
        }
    }

    private func statBadge(title: String, value: String, colour: Color) -> some View {
        HStack(spacing: Spacing.xxs) {
            Circle()
                .fill(colour)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.caption2)
                .foregroundColor(.textSecondary)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(colour.opacity(0.1))
        .clipShape(Capsule())
    }

    private var errorsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button {
                withAnimation {
                    showErrors.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: showErrors ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text("Errors (\(parseResult.errorCount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    Spacer()
                }
            }

            if showErrors {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(Array(parseResult.errors.prefix(10).enumerated()), id: \.offset) { index, error in
                        errorRow(error)
                    }

                    if parseResult.errorCount > 10 {
                        Text("+ \(parseResult.errorCount - 10) more errors")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .padding(.top, Spacing.xxs)
                    }
                }
                .padding(Spacing.sm)
                .background(Color.red.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }

    private func errorRow(_ error: CSVParser.ParseError) -> some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Text("Row \(error.row):")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.red)
                .frame(width: 60, alignment: .leading)

            Text(error.message)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }

    private var successSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Valid Entries (\(parseResult.successCount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            Text("The following entries will be imported:")
                .font(.caption)
                .foregroundColor(.textSecondary)

            // Group by week
            ForEach([WeekType.week1, WeekType.week2], id: \.self) { week in
                let weekEntries = parseResult.validEntries.filter { $0.week == week }
                if !weekEntries.isEmpty {
                    weekSection(week: week, entries: weekEntries)
                }
            }
        }
    }

    private func weekSection(week: WeekType, entries: [ScheduleEntry]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(week == .week1 ? "Week 1" : "Week 2")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, 2)
                .background(week == .week1 ? Color.purple.opacity(0.2) : Color.green.opacity(0.2))
                .cornerRadius(4)

            // Group by day
            ForEach(DayOfWeek.allCases, id: \.self) { day in
                let dayEntries = entries.filter { $0.dayOfWeek == day }
                if !dayEntries.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        Text(day.shortName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.textSecondary)
                            .frame(width: 40, alignment: .leading)

                        Text("\(dayEntries.count) periods")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.leading, Spacing.sm)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .cornerRadius(8)
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.backgroundTertiary)
                    .cornerRadius(12)
            }

            Button {
                onConfirm()
            } label: {
                HStack(spacing: Spacing.xs) {
                    if parseResult.hasErrors {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    Text(parseResult.hasErrors ? "Import Anyway" : "Import")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(parseResult.hasErrors ? Color.orange : Color.accentApp)
                .cornerRadius(12)
            }
            .disabled(parseResult.successCount == 0)
        }
    }
}

// MARK: - Preview

#Preview {
    let validEntries = [
        ScheduleEntry(
            dayOfWeek: .monday,
            period: 0,
            subject: "Registration",
            room: "512",
            week: .week1,
            teacher: "KCO"
        ),
        ScheduleEntry(
            dayOfWeek: .monday,
            period: 1,
            subject: "English",
            room: "053",
            week: .week1,
            teacher: "BBR"
        ),
        ScheduleEntry(
            dayOfWeek: .tuesday,
            period: 1,
            subject: "Maths",
            room: "112",
            week: .week2,
            teacher: "SMT"
        )
    ]

    let errors = [
        CSVParser.ParseError(row: 3, message: "Invalid week value '3'. Must be '1' or '2'"),
        CSVParser.ParseError(row: 5, message: "Subject is required (cannot be empty)")
    ]

    let result = CSVParser.ParseResult(
        validEntries: validEntries,
        errors: errors,
        totalRows: 5
    )

    return CSVImportPreviewView(
        parseResult: result,
        onConfirm: { print("Confirmed") },
        onCancel: { print("Cancelled") }
    )
}
