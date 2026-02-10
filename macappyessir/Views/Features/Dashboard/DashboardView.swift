//
//  DashboardView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        GeometryReader { geometry in
            ScrollableContentView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QuoteHub")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("AI-Powered Contractor Estimates")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    Button(action: {
                        appState.selectedItem = .activeJobs
                    }) {
                        StatCard(
                            title: "Active Jobs",
                            value: "\(appState.activeJobs.count)",
                            subtitle: "$\(Int(appState.totalActiveValue / 1000))K in progress",
                            icon: "hammer.fill",
                            color: .orange
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        appState.selectedItem = .completed
                    }) {
                        StatCard(
                            title: "Completed",
                            value: "\(appState.completedJobs.count)",
                            subtitle: "This month",
                            icon: "checkmark.seal.fill",
                            color: .green
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        appState.selectedItem = .completed
                    }) {
                        StatCard(
                            title: "Revenue",
                            value: "$\(Int(appState.totalRevenue / 1000))K",
                            subtitle: "Total earned",
                            icon: "dollarsign.circle.fill",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        appState.selectedItem = .activeJobs
                    }) {
                        StatCard(
                            title: "Funds Received",
                            value: "$\(Int(appState.totalFundsReceived / 1000))K",
                            subtitle: appState.outstandingBalance > 0 ? "$\(Int(appState.outstandingBalance / 1000))K pending" : "All paid",
                            icon: "banknote.fill",
                            color: .green
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)

                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)

                    HStack(spacing: 16) {
                        QuickActionButton(
                            icon: "camera.fill",
                            title: "New Estimate",
                            subtitle: "Use AI Camera",
                            color: .orange,
                            action: {
                                appState.selectedItem = .newEstimate
                            }
                        )

                        QuickActionButton(
                            icon: "photo.badge.plus",
                            title: "Add Progress",
                            subtitle: "Update job photos",
                            color: .blue,
                            action: {
                                appState.selectedItem = .activeJobs
                            }
                        )
                    }
                    .padding(.horizontal, 24)
                }

                // Active Jobs Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Active Jobs")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Spacer()

                        Button("View All") {
                            appState.selectedItem = .activeJobs
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 24)

                    if appState.activeJobs.isEmpty {
                        EnhancedEmptyState(
                            icon: "hammer.fill",
                            title: "No Active Jobs",
                            message: "Start managing your contracting business with your first estimate",
                            actionTitle: "Create First Estimate",
                            action: {
                                appState.selectedItem = .newEstimate
                            },
                            tips: [
                                "Press ⌘N anytime to create a new estimate",
                                "AI will suggest costs based on your project description",
                                "Track progress, payments, and photos all in one place"
                            ]
                        )
                        .padding(.horizontal, 24)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(appState.activeJobs.prefix(3)) { job in
                                JobCard(job: job)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                    Spacer(minLength: 40)
                }
                .frame(minWidth: geometry.size.width)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
                if isHovered {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(color)
                }
            }

            Text(value)
                .font(.system(size: 32, weight: .bold))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(isHovered ? Color(nsColor: .controlBackgroundColor).opacity(0.8) : Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: isHovered ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
