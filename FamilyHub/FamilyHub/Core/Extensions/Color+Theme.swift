//
//  Color+Theme.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

// MARK: - Semantic Colours

extension Color {
    // MARK: - Primary Colours

    /// Primary app accent - iOS system blue
    static let primaryApp = Color.blue

    /// Secondary accent - complementary actions
    static let secondaryApp = Color.cyan

    /// Accent for CTAs and emphasis
    static let accentApp = Color.orange

    // MARK: - Week Identification

    /// Week 1 indicator colour
    static let week1 = Color.purple

    /// Week 2 indicator colour
    static let week2 = Color.green

    // MARK: - Semantic Text Colours

    /// Primary text - automatically adapts light/dark
    static let textPrimary = Color.primary

    /// Secondary text - less emphasis
    static let textSecondary = Color.secondary

    /// Tertiary text - minimal emphasis
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    // MARK: - Background Colours

    /// Primary background
    static let backgroundPrimary = Color(uiColor: .systemBackground)

    /// Secondary background (grouped)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)

    /// Card/cell backgrounds
    static let backgroundTertiary = Color(uiColor: .secondarySystemGroupedBackground)

    // MARK: - Status Colours

    /// Success states
    static let success = Color.green

    /// Warning states
    static let warning = Color.orange

    /// Error states
    static let error = Color.red

    /// Information states
    static let info = Color.blue
}

// MARK: - Material Extensions

extension Material {
    /// Material for timetable period cards
    static var periodCard: Material {
        .regularMaterial
    }

    /// Material for navigation bars
    static var navigationBar: Material {
        .thinMaterial
    }

    /// Material for tab bars
    static var tabBar: Material {
        .regularMaterial
    }

    /// Material for week selector
    static var weekSelector: Material {
        .thinMaterial
    }

    /// Material for modals and sheets
    static var modal: Material {
        .thickMaterial
    }

    /// Material for empty states
    static var emptyState: Material {
        .thinMaterial
    }
}
