//
//  AnalyticsManager.swift
//  macappyessir
//
//  Created by Jay Vora on 2/10/26.
//

import Foundation
import OSLog

/// Analytics manager for tracking user behavior and app events
class AnalyticsManager {
    static let shared = AnalyticsManager()

    private let logger = Logger(subsystem: "com.quotehub.app", category: "Analytics")
    private var isEnabled: Bool = true

    private init() {
        loadSettings()
    }

    // MARK: - Settings

    func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "analytics_enabled")
        logger.info("Analytics enabled: \(self.isEnabled)")
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "analytics_enabled")
        logger.info("Analytics \(enabled ? "enabled" : "disabled")")
    }

    // MARK: - Screen Views

    func trackScreenView(_ screenName: String) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "screen_view",
            properties: ["screen_name": screenName]
        )

        logEvent(event)
    }

    // MARK: - Job Events

    func trackJobCreated(type: ContractorType, estimatedCost: Double) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "job_created",
            properties: [
                "contractor_type": type.rawValue,
                "estimated_cost": estimatedCost,
                "cost_range": getCostRange(estimatedCost)
            ]
        )

        logEvent(event)
    }

    func trackJobCompleted(type: ContractorType, actualCost: Double, durationDays: Int) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "job_completed",
            properties: [
                "contractor_type": type.rawValue,
                "actual_cost": actualCost,
                "duration_days": durationDays,
                "cost_range": getCostRange(actualCost)
            ]
        )

        logEvent(event)
    }

    func trackJobDeleted(type: ContractorType) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "job_deleted",
            properties: ["contractor_type": type.rawValue]
        )

        logEvent(event)
    }

    // MARK: - Feature Usage

    func trackFeatureUsed(_ featureName: String, properties: [String: Any] = [:]) {
        guard isEnabled else { return }

        var eventProperties = properties
        eventProperties["feature_name"] = featureName

        let event = AnalyticsEvent(
            name: "feature_used",
            properties: eventProperties
        )

        logEvent(event)
    }

    func trackTemplateUsed(templateName: String, templateType: ContractorType) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "template_used",
            properties: [
                "template_name": templateName,
                "template_type": templateType.rawValue
            ]
        )

        logEvent(event)
    }

    func trackExport(type: String, itemCount: Int) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "export_completed",
            properties: [
                "export_type": type,
                "item_count": itemCount
            ]
        )

        logEvent(event)
    }

    func trackBulkAction(action: String, itemCount: Int) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "bulk_action",
            properties: [
                "action_type": action,
                "item_count": itemCount
            ]
        )

        logEvent(event)
    }

    // MARK: - Payment Events

    func trackPaymentAdded(amount: Double, method: String) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "payment_added",
            properties: [
                "amount": amount,
                "payment_method": method
            ]
        )

        logEvent(event)
    }

    // MARK: - AI Events

    func trackAICameraUsed() {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "ai_camera_used",
            properties: [:]
        )

        logEvent(event)
    }

    func trackAIEstimateGenerated(success: Bool, processingTime: Double) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "ai_estimate_generated",
            properties: [
                "success": success,
                "processing_time_seconds": processingTime
            ]
        )

        logEvent(event)
    }

    // MARK: - Error Events

    func trackError(domain: String, code: Int, description: String) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "error_occurred",
            properties: [
                "error_domain": domain,
                "error_code": code,
                "error_description": description
            ]
        )

        logEvent(event)
    }

    // MARK: - Performance Events

    func trackPerformance(metric: String, value: Double, unit: String = "ms") {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "performance_metric",
            properties: [
                "metric_name": metric,
                "value": value,
                "unit": unit
            ]
        )

        logEvent(event)
    }

    // MARK: - Session Events

    func trackSessionStart() {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "session_start",
            properties: [
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
                "os_version": ProcessInfo.processInfo.operatingSystemVersionString
            ]
        )

        logEvent(event)
    }

    func trackSessionEnd(duration: TimeInterval) {
        guard isEnabled else { return }

        let event = AnalyticsEvent(
            name: "session_end",
            properties: [
                "duration_seconds": duration
            ]
        )

        logEvent(event)
    }

    // MARK: - Private Helpers

    private func logEvent(_ event: AnalyticsEvent) {
        // Log to console in debug mode
        #if DEBUG
        logger.debug("📊 Analytics: \(event.name) - \(event.properties)")
        #endif

        // In production, this would send to analytics service (PostHog, Mixpanel, etc.)
        // For now, we're using OSLog which can be viewed in Console.app
        logger.info("Event: \(event.name, privacy: .public) Properties: \(String(describing: event.properties), privacy: .private)")

        // Store event locally for later batch upload
        storeEvent(event)
    }

    private func storeEvent(_ event: AnalyticsEvent) {
        // Store events locally for batch uploading
        // This could be implemented with Core Data or a local file
        // For MVP, we're just logging
    }

    private func getCostRange(_ cost: Double) -> String {
        switch cost {
        case 0..<1000: return "0-1K"
        case 1000..<5000: return "1K-5K"
        case 5000..<10000: return "5K-10K"
        case 10000..<25000: return "10K-25K"
        case 25000..<50000: return "25K-50K"
        default: return "50K+"
        }
    }
}

// MARK: - Analytics Event Model

struct AnalyticsEvent: Codable {
    let id: UUID
    let name: String
    let properties: [String: Any]
    let timestamp: Date

    init(name: String, properties: [String: Any]) {
        self.id = UUID()
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }

    // Custom Codable implementation to handle [String: Any]
    enum CodingKeys: String, CodingKey {
        case id, name, properties, timestamp
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(timestamp, forKey: .timestamp)

        // Convert properties to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: properties)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        try container.encode(jsonString, forKey: .properties)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        timestamp = try container.decode(Date.self, forKey: .timestamp)

        let jsonString = try container.decode(String.self, forKey: .properties)
        let jsonData = jsonString.data(using: .utf8) ?? Data()
        properties = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
    }
}
