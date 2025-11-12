//
//  UserSelectionView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct UserSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @Binding var selectedUser: User?

    @State private var showingAddUser = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()

                // Content
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        headerSection

                        // User cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                            ForEach(users) { user in
                                UserCardView(user: user)
                                    .onTapGesture {
                                        selectUser(user)
                                    }
                            }
                        }

                        // Add user button
                        addUserButton
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.lg)
                }
            }
            .navigationTitle("FamilyHub")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddUser) {
                AddUserView()
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: "house.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.primaryApp)

            Text("Welcome to FamilyHub")
                .font(.screenTitle)
                .foregroundColor(.textPrimary)

            Text("Select your profile to continue")
                .font(.body)
                .foregroundColor(.textSecondary)
        }
        .padding(.top, Spacing.lg)
    }

    private var addUserButton: some View {
        Button {
            showingAddUser = true
            HapticManager.light()
        } label: {
            Label("Add Family Member", systemImage: "person.badge.plus")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(Color.accentApp)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Actions

    private func selectUser(_ user: User) {
        HapticManager.medium()
        withAnimation(.easeOut(duration: AnimationDuration.standard)) {
            selectedUser = user
        }
    }
}

#Preview {
    UserSelectionView(selectedUser: .constant(nil))
        .modelContainer(for: [User.self], inMemory: true)
}
