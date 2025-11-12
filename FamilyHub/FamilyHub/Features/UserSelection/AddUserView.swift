//
//  AddUserView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct AddUserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedRole: UserRole = .student

    var isFirstUser: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                } header: {
                    Text("Details")
                }

                Section {
                    Picker("Role", selection: $selectedRole) {
                        Text("Student").tag(UserRole.student)
                        Text("Parent").tag(UserRole.parent)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Role")
                } footer: {
                    Text("Students can have timetables. Parents can view all family members' information.")
                }
            }
            .navigationTitle(isFirstUser ? "Create Your Profile" : "Add Family Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !isFirstUser {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isFirstUser ? "Continue" : "Add") {
                        addUser()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addUser() {
        let user = User(name: name, role: selectedRole)

        // Create default preferences
        let preferences = UserPreferences()
        preferences.user = user
        user.preferences = preferences

        // Create timetable data for students
        if selectedRole == .student {
            let timetableData = TimetableData(owner: user)
            user.timetableData = timetableData
        }

        modelContext.insert(user)

        do {
            try modelContext.save()
            HapticManager.success()
            dismiss()
        } catch {
            print("Error saving user: \(error)")
            HapticManager.error()
        }
    }
}

#Preview {
    AddUserView()
        .modelContainer(for: [User.self], inMemory: true)
}
