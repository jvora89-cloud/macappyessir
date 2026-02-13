//
//  EnhancedDashboardView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Enhanced dashboard with charts, trends, and better UX
//

import SwiftUI
import Charts

struct EnhancedDashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showingQuickAdd = false

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        case year = "1Y"
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollableContentView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with greeting
                    headerSection

                    // Key Metrics with Trends
                    metricsGridSection

                    // Revenue Chart
                    revenueChartSection

                    // Quick Actions
                    quickActionsSection

                    // Recent Activity
                    recentActivitySection

                    // Active Jobs Preview
                    activeJobsPreviewSection

                    Spacer(minLength: 40)
                }
                .frame(minWidth: geometry.size.width)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText())
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Here's what's happening with your business")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Time range selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: - Metrics Grid

    private var metricsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            EnhancedStatCard(
                title: "Active Jobs",
                value: "\(appState.activeJobs.count)",
                subtitle: "$\(formatCurrency(appState.totalActiveValue)) in progress",
                icon: "hammer.fill",
                color: .orange,
                trend: calculateTrend(for: .activeJobs),
                action: { appState.selectedItem = .activeJobs }
            )

            EnhancedStatCard(
                title: "Completed",
                value: "\(appState.completedJobs.count)",
                subtitle: "This \(selectedTimeRange.rawValue.lowercased())",
                icon: "checkmark.seal.fill",
                color: .green,
                trend: calculateTrend(for: .completed),
                action: { appState.selectedItem = .completed }
            )

            EnhancedStatCard(
                title: "Revenue",
                value: "$\(formatCurrency(appState.totalRevenue))",
                subtitle: "Total earned",
                icon: "dollarsign.circle.fill",
                color: .blue,
                trend: calculateTrend(for: .revenue),
                action: { appState.selectedItem = .completed }
            )

            EnhancedStatCard(
                title: "Funds Received",
                value: "$\(formatCurrency(appState.totalFundsReceived))",
                subtitle: appState.outstandingBalance > 0 ? "$\(formatCurrency(appState.outstandingBalance)) pending" : "All paid ✓",
                icon: "banknote.fill",
                color: appState.outstandingBalance > 0 ? .orange : .green,
                trend: calculateTrend(for: .fundsReceived),
                action: { appState.selectedItem = .activeJobs }
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Revenue Chart

    private var revenueChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Revenue Trend")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                // Chart
                if #available(macOS 13.0, *) {
                    Chart {
                        ForEach(generateRevenueData()) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Revenue", dataPoint.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            AreaMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Revenue", dataPoint.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text("$\(Int(amount/1000))K")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                } else {
                    Text("Charts require macOS 13.0+")
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }

                // Summary Stats
                HStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Average per Job")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(formatCurrency(calculateAverageJobValue()))")
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completion Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(calculateCompletionRate())%")
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Payment Collection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(calculatePaymentRate())%")
                            .font(.headline)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    icon: "camera.fill",
                    title: "New Estimate",
                    subtitle: "AI Camera",
                    color: .orange,
                    shortcut: "⌘N",
                    action: { appState.selectedItem = .newEstimate }
                )

                QuickActionCard(
                    icon: "doc.text.fill",
                    title: "View Reports",
                    subtitle: "Analytics",
                    color: .blue,
                    shortcut: "⌘R",
                    action: { showingQuickAdd = true }
                )

                QuickActionCard(
                    icon: "square.and.arrow.up.fill",
                    title: "Export Data",
                    subtitle: "PDF & CSV",
                    color: .green,
                    shortcut: "⌘E",
                    action: { appState.selectedItem = .settings }
                )
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(getRecentActivity()) { activity in
                    ActivityRow(activity: activity)
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Active Jobs Preview

    private var activeJobsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Jobs")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All →") {
                    appState.selectedItem = .activeJobs
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)

            if appState.activeJobs.isEmpty {
                EnhancedEmptyState(
                    icon: "hammer.fill",
                    title: "No Active Jobs",
                    message: "Create your first estimate to get started",
                    actionTitle: "New Estimate",
                    action: { appState.selectedItem = .newEstimate },
                    tips: [
                        "Use ⌘N to quickly create estimates",
                        "AI camera analyzes job sites automatically",
                        "Track progress and payments in real-time"
                    ]
                )
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(appState.activeJobs.prefix(3)) { job in
                        CompactJobCard(job: job)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Helper Functions

    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        }
        return String(format: "%.0f", amount)
    }

    private func calculateTrend(for metric: DashboardMetricType) -> TrendData {
        // Simplified trend calculation - in real app would compare to previous period
        let change = Double.random(in: -15...25)
        return TrendData(percentage: change, isPositive: change > 0)
    }

    private func generateRevenueData() -> [RevenueDataPoint] {
        let days = selectedTimeRange == .week ? 7 : selectedTimeRange == .month ? 30 : 90
        var data: [RevenueDataPoint] = []
        let calendar = Calendar.current

        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -days + i, to: Date()) {
                let baseAmount = Double.random(in: 5000...15000)
                data.append(RevenueDataPoint(date: date, amount: baseAmount))
            }
        }
        return data
    }

    private func calculateAverageJobValue() -> Double {
        guard !appState.completedJobs.isEmpty else { return 0 }
        let total = appState.completedJobs.reduce(0) { $0 + ($1.actualCost ?? $1.estimatedCost) }
        return total / Double(appState.completedJobs.count)
    }

    private func calculateCompletionRate() -> Int {
        let total = appState.activeJobs.count + appState.completedJobs.count
        guard total > 0 else { return 0 }
        return Int((Double(appState.completedJobs.count) / Double(total)) * 100)
    }

    private func calculatePaymentRate() -> Int {
        guard appState.totalRevenue > 0 else { return 0 }
        return Int((appState.totalFundsReceived / appState.totalRevenue) * 100)
    }

    private func getRecentActivity() -> [ActivityItem] {
        var activities: [ActivityItem] = []

        // Add recent completed jobs
        for job in appState.completedJobs.prefix(3) {
            activities.append(ActivityItem(
                icon: "checkmark.circle.fill",
                color: .green,
                title: "Completed: \(job.clientName)",
                subtitle: "Finished \(job.contractorType.rawValue)",
                time: timeAgo(from: job.completionDate ?? Date())
            ))
        }

        // Add recent active jobs
        for job in appState.activeJobs.prefix(2) {
            activities.append(ActivityItem(
                icon: "hammer.circle.fill",
                color: .orange,
                title: "In Progress: \(job.clientName)",
                subtitle: "\(Int(job.progress * 100))% complete",
                time: timeAgo(from: job.startDate)
            ))
        }

        return Array(activities.prefix(5))
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let days = Int(interval / 86400)
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        return "\(days) days ago"
    }
}

// MARK: - Supporting Types

enum DashboardMetricType {
    case activeJobs, completed, revenue, fundsReceived
}

struct TrendData {
    let percentage: Double
    let isPositive: Bool
}

struct RevenueDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let time: String
}

// MARK: - Enhanced Stat Card

struct EnhancedStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: TrendData
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)

                    Spacer()

                    // Trend indicator
                    HStack(spacing: 4) {
                        Image(systemName: trend.isPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text(String(format: "%.1f%%", abs(trend.percentage)))
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(trend.isPositive ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((trend.isPositive ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(6)
                }

                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

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
            .background(
                ZStack {
                    Color(nsColor: .controlBackgroundColor)
                    if isHovered {
                        color.opacity(0.05)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isHovered ? color.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(color: isHovered ? color.opacity(0.2) : .clear, radius: 12, x: 0, y: 6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let shortcut: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(shortcut)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(4)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isHovered ? color.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.spring(response: 0.3), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let activity: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.title3)
                .foregroundColor(activity.color)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(activity.time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Compact Job Card

struct CompactJobCard: View {
    let job: Job
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 16) {
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: job.progress)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(job.progress * 100))%")
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            // Job info
            VStack(alignment: .leading, spacing: 4) {
                Text(job.clientName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(job.contractorType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Label(job.formattedEstimate, systemImage: "dollarsign.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)

                    Label("\(job.photos.count) photos", systemImage: "photo.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isHovered {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        .background(isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        .cornerRadius(8)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var progressColor: Color {
        let percentage = job.progress * 100
        switch percentage {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .yellow
        case 75..<100: return .blue
        default: return .green
        }
    }
}

#Preview {
    EnhancedDashboardView()
        .environment(AppState())
}
