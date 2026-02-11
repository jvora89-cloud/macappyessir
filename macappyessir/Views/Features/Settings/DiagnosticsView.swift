//
//  DiagnosticsView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/10/26.
//

import SwiftUI

struct DiagnosticsView: View {
    @State private var selectedTab: DiagnosticsTab = .performance
    @State private var errorStats = ErrorTracker.shared.getErrorStats()
    @State private var recentErrors: [TrackedError] = []
    @State private var recentMetrics: [PerformanceMetric] = []
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Diagnostics")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("App performance and error monitoring")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { refreshData() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(24)

            Divider()

            // Tab Picker
            Picker("Diagnostics Tab", selection: $selectedTab) {
                ForEach(DiagnosticsTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()

            // Content
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedTab {
                    case .performance:
                        PerformanceMetricsView(metrics: recentMetrics)
                    case .errors:
                        ErrorLogView(errors: recentErrors, stats: errorStats)
                    case .system:
                        SystemInfoView()
                    }
                }
                .padding(24)
            }

            Divider()

            // Footer Actions
            HStack {
                Text("\(errorStats.total) errors • \(recentMetrics.count) metrics")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Clear All Data") {
                    showClearConfirmation = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            .padding(24)
        }
        .frame(width: 800, height: 600)
        .onAppear {
            refreshData()
        }
        .alert("Clear All Diagnostics Data?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will delete all performance metrics and error logs. This cannot be undone.")
        }
    }

    private func refreshData() {
        errorStats = ErrorTracker.shared.getErrorStats()
        recentErrors = ErrorTracker.shared.getRecentErrors(limit: 50)
        recentMetrics = PerformanceMonitor.shared.getRecentMetrics(limit: 100)
    }

    private func clearAllData() {
        ErrorTracker.shared.clearErrorLog()
        PerformanceMonitor.shared.clearMetrics()
        refreshData()
    }
}

// MARK: - Performance Metrics View

struct PerformanceMetricsView: View {
    let metrics: [PerformanceMetric]

    var timingMetrics: [PerformanceMetric] {
        metrics.filter { $0.metricType == .timing }
    }

    var memoryMetrics: [PerformanceMetric] {
        metrics.filter { $0.metricType == .memory }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Summary Cards
            HStack(spacing: 16) {
                MetricSummaryCard(
                    title: "Total Metrics",
                    value: "\(metrics.count)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                MetricSummaryCard(
                    title: "Timing Events",
                    value: "\(timingMetrics.count)",
                    icon: "timer",
                    color: .green
                )

                MetricSummaryCard(
                    title: "Memory Checks",
                    value: "\(memoryMetrics.count)",
                    icon: "memorychip",
                    color: .orange
                )
            }

            // Recent Metrics
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Performance Metrics")
                    .font(.headline)

                if metrics.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No metrics recorded yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 8) {
                        ForEach(metrics.prefix(20)) { metric in
                            MetricRow(metric: metric)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
    }
}

struct MetricRow: View {
    let metric: PerformanceMetric

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: metricIcon)
                .font(.caption)
                .foregroundColor(metricColor)
                .frame(width: 20)

            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(metric.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !metric.context.isEmpty {
                    Text(metric.context)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Value
            if let duration = metric.duration {
                Text(String(format: "%.2fms", duration * 1000))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            } else if let value = metric.value {
                Text("\(Int(value))\(metric.unit ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            // Timestamp
            Text(metric.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var metricIcon: String {
        switch metric.metricType {
        case .timing: return "timer"
        case .memory: return "memorychip"
        case .custom: return "square.grid.3x3"
        }
    }

    private var metricColor: Color {
        switch metric.metricType {
        case .timing: return .green
        case .memory: return .orange
        case .custom: return .blue
        }
    }
}

// MARK: - Error Log View

struct ErrorLogView: View {
    let errors: [TrackedError]
    let stats: ErrorStats

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Error Statistics
            HStack(spacing: 16) {
                MetricSummaryCard(
                    title: "Total Errors",
                    value: "\(stats.total)",
                    icon: "exclamationmark.triangle",
                    color: stats.hasErrors ? .red : .gray
                )

                MetricSummaryCard(
                    title: "Critical",
                    value: "\(stats.critical)",
                    icon: "exclamationmark.octagon",
                    color: stats.critical > 0 ? .red : .gray
                )

                MetricSummaryCard(
                    title: "Warnings",
                    value: "\(stats.warnings)",
                    icon: "exclamationmark.shield",
                    color: stats.warnings > 0 ? .orange : .gray
                )
            }

            // Recent Errors
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Errors")
                    .font(.headline)

                if errors.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("No errors recorded")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Your app is running smoothly!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 8) {
                        ForEach(errors.prefix(20)) { error in
                            ErrorRow(error: error)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
    }
}

struct ErrorRow: View {
    let error: TrackedError
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 12) {
                    // Severity Icon
                    Image(systemName: severityIcon)
                        .font(.caption)
                        .foregroundColor(severityColor)
                        .frame(width: 20)

                    // Error Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(error.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text(error.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(isExpanded ? nil : 1)
                    }

                    Spacer()

                    // Context Badge
                    if !error.context.isEmpty {
                        Text(error.context)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }

                    // Expand Icon
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if !error.stackTrace.isEmpty {
                        Text("Stack Trace:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(error.stackTrace)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }

                    HStack(spacing: 16) {
                        Label(error.timestamp.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                        Label(error.appVersion, systemImage: "app.badge")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding(.leading, 32)
            }
        }
        .padding(.vertical, 8)
    }

    private var severityIcon: String {
        switch error.severity {
        case .critical: return "exclamationmark.octagon.fill"
        case .error: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.shield.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var severityColor: Color {
        switch error.severity {
        case .critical: return .red
        case .error: return .orange
        case .warning: return .yellow
        case .info: return .blue
        }
    }
}

// MARK: - System Info View

struct SystemInfoView: View {
    @State private var memoryUsage: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // App Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Application")
                    .font(.headline)

                DiagnosticInfoRow(label: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")
                DiagnosticInfoRow(label: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown")
                DiagnosticInfoRow(label: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "unknown")
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)

            // System Info
            VStack(alignment: .leading, spacing: 12) {
                Text("System")
                    .font(.headline)

                DiagnosticInfoRow(label: "OS Version", value: ProcessInfo.processInfo.operatingSystemVersionString)
                DiagnosticInfoRow(label: "Processor Count", value: "\(ProcessInfo.processInfo.processorCount)")
                DiagnosticInfoRow(label: "Memory Usage", value: formatBytes(memoryUsage))
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)

            // Analytics Status
            VStack(alignment: .leading, spacing: 12) {
                Text("Monitoring Services")
                    .font(.headline)

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Analytics tracking active")
                    Spacer()
                }
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Error tracking active")
                    Spacer()
                }
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Performance monitoring active")
                    Spacer()
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
        .onAppear {
            updateMemoryUsage()
        }
    }

    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            memoryUsage = Double(info.resident_size)
        }
    }

    private func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct DiagnosticInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Supporting Views

struct MetricSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

enum DiagnosticsTab: String, CaseIterable, Identifiable {
    case performance = "Performance"
    case errors = "Errors"
    case system = "System"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .performance: return "speedometer"
        case .errors: return "exclamationmark.triangle"
        case .system: return "info.circle"
        }
    }
}

#Preview {
    DiagnosticsView()
}
