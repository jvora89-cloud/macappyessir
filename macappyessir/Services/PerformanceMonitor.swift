//
//  PerformanceMonitor.swift
//  macappyessir
//
//  Created by Jay Vora on 2/10/26.
//

import Foundation
import OSLog

/// Performance monitoring service for tracking app metrics
class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private let logger = Logger(subsystem: "com.quotehub.app", category: "Performance")
    private var timers: [String: Date] = [:]
    private var metrics: [PerformanceMetric] = []
    private let maxStoredMetrics = 500

    private init() {
        logger.info("Performance monitoring initialized")
    }

    // MARK: - Timer Functions

    func startTimer(_ name: String) {
        timers[name] = Date()
        logger.debug("Timer started: \(name)")
    }

    func endTimer(_ name: String, context: String = "") {
        guard let startTime = timers[name] else {
            logger.warning("Timer '\(name)' not found")
            return
        }

        let duration = Date().timeIntervalSince(startTime)
        timers.removeValue(forKey: name)

        let metric = PerformanceMetric(
            name: name,
            duration: duration,
            context: context,
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)

        // Report to analytics
        AnalyticsManager.shared.trackPerformance(
            metric: name,
            value: duration * 1000,
            unit: "ms"
        )
    }

    func measureAsync<T>(_ name: String, context: String = "", operation: () async throws -> T) async rethrows -> T {
        let startTime = Date()
        let result = try await operation()
        let duration = Date().timeIntervalSince(startTime)

        let metric = PerformanceMetric(
            name: name,
            duration: duration,
            context: context,
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)

        return result
    }

    func measure<T>(_ name: String, context: String = "", operation: () throws -> T) rethrows -> T {
        let startTime = Date()
        let result = try operation()
        let duration = Date().timeIntervalSince(startTime)

        let metric = PerformanceMetric(
            name: name,
            duration: duration,
            context: context,
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)

        return result
    }

    // MARK: - Memory Monitoring

    func recordMemoryUsage(context: String = "") {
        let usage = getMemoryUsage()

        let metric = PerformanceMetric(
            name: "memory_usage",
            value: usage,
            context: context,
            metricType: .memory
        )

        logMetric(metric)
        storeMetric(metric)

        // Alert if memory usage is high
        if usage > 500 * 1024 * 1024 { // 500 MB
            logger.warning("High memory usage detected: \(self.formatBytes(usage))")
        }
    }

    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(info.resident_size)
        } else {
            return 0
        }
    }

    // MARK: - Custom Metrics

    func recordMetric(_ name: String, value: Double, unit: String = "", context: String = "") {
        let metric = PerformanceMetric(
            name: name,
            value: value,
            unit: unit,
            context: context,
            metricType: .custom
        )

        logMetric(metric)
        storeMetric(metric)
    }

    // MARK: - Domain-Specific Metrics

    func trackJobLoadTime(duration: TimeInterval, jobCount: Int) {
        let metric = PerformanceMetric(
            name: "job_load_time",
            duration: duration,
            context: "\(jobCount) jobs",
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)

        if duration > 1.0 {
            logger.warning("Slow job load detected: \(duration)s for \(jobCount) jobs")
        }
    }

    func trackPDFGeneration(duration: TimeInterval, success: Bool) {
        let metric = PerformanceMetric(
            name: "pdf_generation",
            duration: duration,
            context: success ? "success" : "failed",
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)
    }

    func trackExportTime(duration: TimeInterval, exportType: String, itemCount: Int) {
        let metric = PerformanceMetric(
            name: "export_time",
            duration: duration,
            context: "\(exportType) - \(itemCount) items",
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)
    }

    func trackAIProcessing(duration: TimeInterval, imageCount: Int, success: Bool) {
        let metric = PerformanceMetric(
            name: "ai_processing",
            duration: duration,
            context: "\(imageCount) images - \(success ? "success" : "failed")",
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)

        // Track to analytics as well
        AnalyticsManager.shared.trackAIEstimateGenerated(success: success, processingTime: duration)
    }

    func trackSearchPerformance(duration: TimeInterval, resultCount: Int, query: String) {
        let metric = PerformanceMetric(
            name: "search_performance",
            duration: duration,
            context: "\(resultCount) results",
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)
    }

    // MARK: - App Lifecycle Metrics

    func trackAppLaunch(duration: TimeInterval) {
        let metric = PerformanceMetric(
            name: "app_launch",
            duration: duration,
            context: "cold_start",
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)

        if duration > 2.0 {
            logger.warning("Slow app launch detected: \(duration)s")
        }
    }

    func trackViewAppear(_ viewName: String, duration: TimeInterval) {
        let metric = PerformanceMetric(
            name: "view_appear",
            duration: duration,
            context: viewName,
            metricType: .timing
        )

        logMetric(metric)
        storeMetric(metric)
    }

    // MARK: - Metrics Retrieval

    func getRecentMetrics(limit: Int = 100) -> [PerformanceMetric] {
        return Array(metrics.prefix(limit))
    }

    func getMetricsByName(_ name: String) -> [PerformanceMetric] {
        return metrics.filter { $0.name == name }
    }

    func getMetricsByType(_ type: MetricType) -> [PerformanceMetric] {
        return metrics.filter { $0.metricType == type }
    }

    func getAverageMetric(_ name: String) -> Double? {
        let matching = metrics.filter { $0.name == name }
        guard !matching.isEmpty else { return nil }

        let total = matching.reduce(0.0) { $0 + ($1.duration ?? $1.value ?? 0) }
        return total / Double(matching.count)
    }

    func getMetricStats(_ name: String) -> MetricStats? {
        let matching = metrics.filter { $0.name == name }
        guard !matching.isEmpty else { return nil }

        let values = matching.compactMap { $0.duration ?? $0.value }
        let sorted = values.sorted()

        return MetricStats(
            name: name,
            count: matching.count,
            average: values.reduce(0, +) / Double(values.count),
            min: sorted.first ?? 0,
            max: sorted.last ?? 0,
            median: sorted[sorted.count / 2]
        )
    }

    func clearMetrics() {
        metrics.removeAll()
        logger.info("Performance metrics cleared")
    }

    // MARK: - Private Helpers

    private func logMetric(_ metric: PerformanceMetric) {
        var message = "📈 \(metric.name)"

        if let duration = metric.duration {
            message += " - \(String(format: "%.2f", duration * 1000))ms"
        } else if let value = metric.value {
            message += " - \(value)\(metric.unit ?? "")"
        }

        if !metric.context.isEmpty {
            message += " (\(metric.context))"
        }

        logger.debug("\(message)")

        #if DEBUG
        print(message)
        #endif
    }

    private func storeMetric(_ metric: PerformanceMetric) {
        metrics.insert(metric, at: 0)

        // Keep only the most recent metrics
        if metrics.count > maxStoredMetrics {
            metrics = Array(metrics.prefix(maxStoredMetrics))
        }
    }

    private func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Models

struct PerformanceMetric: Identifiable, Codable {
    let id: UUID
    let name: String
    let duration: TimeInterval?
    let value: Double?
    let unit: String?
    let context: String
    let metricType: MetricType
    let timestamp: Date

    init(
        id: UUID = UUID(),
        name: String,
        duration: TimeInterval? = nil,
        value: Double? = nil,
        unit: String? = nil,
        context: String = "",
        metricType: MetricType
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.value = value
        self.unit = unit
        self.context = context
        self.metricType = metricType
        self.timestamp = Date()
    }
}

enum MetricType: String, Codable {
    case timing = "Timing"
    case memory = "Memory"
    case custom = "Custom"
}

struct MetricStats {
    let name: String
    let count: Int
    let average: Double
    let min: Double
    let max: Double
    let median: Double
}
