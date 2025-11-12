//
//  WeekSelector.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

/// Week selector component for switching between Week 1 and Week 2
struct WeekSelector: View {
    @Binding var selectedWeek: WeekType
    let calculatedWeek: WeekType
    let manualOverride: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Week indicator
            weekBadge(for: selectedWeek)

            Spacer()

            // Auto/Manual indicator
            if manualOverride {
                Text("Manual")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            } else {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption2)
                    Text("Auto")
                }
                .font(.caption)
                .foregroundColor(.textSecondary)
            }

            // Toggle button
            Button {
                onToggle()
                HapticManager.light()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.callout)
                    .foregroundColor(.primaryApp)
                    .padding(Spacing.xs)
                    .background(Color.backgroundTertiary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Material.weekSelector)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - View Components

    private func weekBadge(for week: WeekType) -> some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(week == .week1 ? Color.week1 : Color.week2)
                .frame(width: 12, height: 12)

            Text(week.rawValue)
                .font(.weekBadge)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.backgroundTertiary)
        )
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        // Auto mode - Week 1
        WeekSelector(
            selectedWeek: .constant(.week1),
            calculatedWeek: .week1,
            manualOverride: false,
            onToggle: {}
        )

        // Manual mode - Week 2
        WeekSelector(
            selectedWeek: .constant(.week2),
            calculatedWeek: .week1,
            manualOverride: true,
            onToggle: {}
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}
