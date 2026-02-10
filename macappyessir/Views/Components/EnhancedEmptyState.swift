//
//  EnhancedEmptyState.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import SwiftUI

struct EnhancedEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    let tips: [String]?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        tips: [String]? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.tips = tips
    }

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                // Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                // Message
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)

                // Action button
                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text(actionTitle)
                        }
                        .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }

            // Tips section
            if let tips = tips, !tips.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("Quick Tips")
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, alignment: .trailing)

                                Text(tip)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(12)
                .frame(maxWidth: 500)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

#Preview {
    EnhancedEmptyState(
        icon: "hammer.fill",
        title: "No Active Jobs",
        message: "Create your first estimate to get started with QuoteHub",
        actionTitle: "Create Estimate",
        action: { print("Create tapped") },
        tips: [
            "Use ⌘N to quickly create a new estimate",
            "AI will help suggest accurate costs based on your description",
            "You can add photos, track progress, and manage payments all in one place"
        ]
    )
}
