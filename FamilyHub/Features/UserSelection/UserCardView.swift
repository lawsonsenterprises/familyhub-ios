//
//  UserCardView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI

struct UserCardView: View {
    let user: User

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Avatar
            ZStack {
                Circle()
                    .fill(avatarGradient)
                    .frame(width: 80, height: 80)

                if let avatarData = user.avatarData,
                   let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Text(user.initials)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            // Name
            Text(user.name)
                .font(.cardHeader)
                .foregroundColor(.textPrimary)

            // Role badge
            Text(user.role == .student ? "Student" : "Parent")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(Material.weekSelector)
                .clipShape(Capsule())
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Material.periodCard)
        .clipShape(RoundedRectangle(cornerRadius: CardMetrics.cornerRadius, style: .continuous))
        .shadow(
            color: .black.opacity(CardMetrics.shadowOpacity),
            radius: CardMetrics.shadowRadius,
            y: CardMetrics.shadowY
        )
    }

    private var avatarGradient: LinearGradient {
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        ]

        // Use user ID to consistently select a gradient
        let index = abs(user.id.hashValue) % gradients.count
        return gradients[index]
    }
}

#Preview {
    HStack {
        UserCardView(user: User(name: "Amelia", role: .student))
        UserCardView(user: User(name: "Rachel", role: .parent))
    }
    .padding()
    .background(Color.backgroundPrimary)
}
