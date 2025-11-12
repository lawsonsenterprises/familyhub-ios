//
//  AppTheme.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

// MARK: - Spacing (8pt Grid System)

enum Spacing {
    /// 4pt - Tight spacing within components
    static let xxs: CGFloat = 4

    /// 8pt - Compact spacing (icon to text)
    static let xs: CGFloat = 8

    /// 12pt - Small spacing
    static let sm: CGFloat = 12

    /// 16pt - Standard spacing (most common) ✓
    static let md: CGFloat = 16

    /// 24pt - Section spacing
    static let lg: CGFloat = 24

    /// 32pt - Large section spacing
    static let xl: CGFloat = 32

    /// 48pt - Screen-level spacing
    static let xxl: CGFloat = 48
}

// MARK: - Card Metrics

enum CardMetrics {
    /// Corner radius for cards (16pt)
    static let cornerRadius: CGFloat = 16

    /// Standard card padding (16pt)
    static let padding: CGFloat = 16

    /// Shadow blur radius
    static let shadowRadius: CGFloat = 10

    /// Shadow offset Y
    static let shadowY: CGFloat = 5

    /// Shadow opacity (normal cards)
    static let shadowOpacity: CGFloat = 0.08

    /// Shadow opacity (elevated cards)
    static let shadowOpacityElevated: CGFloat = 0.12

    /// Border width for highlights
    static let borderWidth: CGFloat = 2
}

// MARK: - Animation Durations

enum AnimationDuration {
    /// Instant feedback (button press) - 0.1s
    static let instant: Double = 0.1

    /// Quick actions (toggle, selection) - 0.2s
    static let quick: Double = 0.2

    /// Standard transitions (most common) ✓ - 0.3s
    static let standard: Double = 0.3

    /// Leisurely transitions (modal present) - 0.5s
    static let leisurely: Double = 0.5
}

// MARK: - Typography Helpers

extension Font {
    /// Screen titles
    static let screenTitle = Font.largeTitle.bold()

    /// Section headers
    static let sectionHeader = Font.title2.bold()

    /// Card headers
    static let cardHeader = Font.headline

    /// Period subject text
    static let periodSubject = Font.headline

    /// Room/teacher info
    static let periodInfo = Font.subheadline

    /// Week badge text
    static let weekBadge = Font.callout.bold()

    /// Time stamps
    static let timestamp = Font.caption
}

// MARK: - Haptic Feedback Manager

struct HapticManager {
    /// Light impact - selection change
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium impact - action performed
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy impact - major action
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    /// Success notification
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Warning notification
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Error notification
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - View Modifiers

/// Standard card style modifier
struct CardStyle: ViewModifier {
    let isElevated: Bool

    func body(content: Content) -> some View {
        content
            .padding(CardMetrics.padding)
            .background(Material.periodCard)
            .clipShape(RoundedRectangle(cornerRadius: CardMetrics.cornerRadius, style: .continuous))
            .shadow(
                color: .black.opacity(isElevated ? CardMetrics.shadowOpacityElevated : CardMetrics.shadowOpacity),
                radius: isElevated ? 15 : CardMetrics.shadowRadius,
                y: isElevated ? 8 : CardMetrics.shadowY
            )
    }
}

extension View {
    /// Apply standard card styling
    /// - Parameter elevated: Whether the card should have elevated shadow
    func cardStyle(elevated: Bool = false) -> some View {
        modifier(CardStyle(isElevated: elevated))
    }
}

/// Period card style modifier (with current period highlighting)
struct PeriodCardStyle: ViewModifier {
    let isCurrentPeriod: Bool

    func body(content: Content) -> some View {
        content
            .padding(CardMetrics.padding)
            .background(isCurrentPeriod ? Material.periodCard : .thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CardMetrics.cornerRadius, style: .continuous))
            .shadow(
                color: .black.opacity(isCurrentPeriod ? CardMetrics.shadowOpacityElevated : CardMetrics.shadowOpacity),
                radius: isCurrentPeriod ? 15 : CardMetrics.shadowRadius,
                y: isCurrentPeriod ? 8 : CardMetrics.shadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: CardMetrics.cornerRadius, style: .continuous)
                    .stroke(isCurrentPeriod ? Color.accentApp : Color.clear, lineWidth: CardMetrics.borderWidth)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrentPeriod)
    }
}

extension View {
    /// Apply period card styling
    /// - Parameter isCurrentPeriod: Whether this is the current period
    func periodCardStyle(isCurrentPeriod: Bool) -> some View {
        modifier(PeriodCardStyle(isCurrentPeriod: isCurrentPeriod))
    }
}

// MARK: - Safe Area Helpers

extension View {
    /// Add safe area padding (horizontal)
    func horizontalSafeArea() -> some View {
        self.padding(.horizontal, Spacing.md)
    }

    /// Add safe area padding (vertical)
    func verticalSafeArea() -> some View {
        self.padding(.vertical, Spacing.md)
    }

    /// Add safe area padding (all edges)
    func allSafeArea() -> some View {
        self.padding(Spacing.md)
    }
}
