//
//  AppModule.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import SwiftUI

/// Protocol for modular app features
protocol AppModule: Identifiable {
    /// Unique identifier for the module
    var id: UUID { get }

    /// Module display name
    var name: String { get }

    /// SF Symbol icon name
    var iconName: String { get }

    /// Brief description of the module
    var description: String { get }

    /// Whether the module is available for the current user
    var isAvailable: Bool { get }

    /// Main view for the module
    /// - Parameter user: User viewing the module
    /// - Returns: Main module view
    @ViewBuilder
    func mainView(for user: User) -> any View

    /// Settings view for the module
    /// - Parameter user: User configuring the module
    /// - Returns: Module settings view
    @ViewBuilder
    func settingsView(for user: User) -> any View
}

// MARK: - Default Implementation

extension AppModule {
    /// Default availability is true
    var isAvailable: Bool {
        return true
    }
}
