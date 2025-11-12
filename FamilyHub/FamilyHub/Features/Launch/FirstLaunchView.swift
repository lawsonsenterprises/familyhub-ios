//
//  FirstLaunchView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

struct FirstLaunchView: View {
    @State private var showingAddUser = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()

                // Content
                VStack(spacing: Spacing.xl) {
                    Spacer()

                    // App icon
                    Image(systemName: "house.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.primaryApp)

                    // Welcome message
                    VStack(spacing: Spacing.sm) {
                        Text("Welcome to FamilyHub")
                            .font(.screenTitle)
                            .foregroundColor(.textPrimary)

                        Text("Your family's organisation hub")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    // Get started button
                    Button {
                        showingAddUser = true
                        HapticManager.medium()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.primaryApp)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal, Spacing.xl)

                    Spacer()
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(isFirstUser: true)
            }
        }
    }
}

#Preview {
    FirstLaunchView()
}
