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
        let _ = print("👥 USERSELECTIONVIEW body evaluated. users.count = \(users.count), selectedUser = \(String(describing: selectedUser?.name))")

        return NavigationStack {
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
                                Button {
                                    print("🔵 BUTTON TAPPED - User: \(user.name)")
                                    selectUser(user)
                                    print("🔵 After selectUser() called")
                                } label: {
                                    UserCardView(user: user)
                                }
                                .buttonStyle(CardButtonStyle())
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
        print("🔵 selectUser() called for: \(user.name)")
        print("🔵 selectedUser BEFORE: \(String(describing: selectedUser?.name))")
        HapticManager.medium()
        withAnimation(.easeOut(duration: AnimationDuration.standard)) {
            selectedUser = user
            print("🔵 selectedUser AFTER: \(String(describing: selectedUser?.name))")
        }
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    UserSelectionView(selectedUser: .constant(nil))
        .modelContainer(for: [User.self], inMemory: true)
}
