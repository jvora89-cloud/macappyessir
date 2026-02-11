//
//  AnalyticsTests.swift
//  macappyessirTests
//
//  Created by Jay Vora on 2/10/26.
//

import XCTest
@testable import macappyessir

final class AnalyticsTests: XCTestCase {

    // MARK: - Analytics Manager Tests

    func testAnalyticsManagerSingleton() {
        let manager1 = AnalyticsManager.shared
        let manager2 = AnalyticsManager.shared

        XCTAssertTrue(manager1 === manager2, "AnalyticsManager should be a singleton")
    }

    func testEnableDisableAnalytics() {
        let manager = AnalyticsManager.shared

        manager.setEnabled(true)
        // Cannot directly test isEnabled as it's private, but we can verify no errors occur

        manager.setEnabled(false)
        // Analytics should be disabled now
    }

    func testTrackJobCreated() {
        let manager = AnalyticsManager.shared

        // Should not throw or crash
        manager.trackJobCreated(type: .kitchen, estimatedCost: 25000)
        manager.trackJobCreated(type: .bathroom, estimatedCost: 15000)
        manager.trackJobCreated(type: .roofing, estimatedCost: 12000)
    }

    func testTrackJobCompleted() {
        let manager = AnalyticsManager.shared

        // Should not throw or crash
        manager.trackJobCompleted(type: .kitchen, actualCost: 26000, durationDays: 14)
        manager.trackJobCompleted(type: .painting, actualCost: 5500, durationDays: 5)
    }

    func testTrackJobDeleted() {
        let manager = AnalyticsManager.shared

        // Should not throw or crash
        manager.trackJobDeleted(type: .fencing)
    }

    func testTrackFeatureUsed() {
        let manager = AnalyticsManager.shared

        // Test without properties
        manager.trackFeatureUsed("export_csv")

        // Test with properties
        manager.trackFeatureUsed("template_picker", properties: [
            "selected_type": "kitchen",
            "template_count": 5
        ])
    }

    func testTrackTemplateUsed() {
        let manager = AnalyticsManager.shared

        manager.trackTemplateUsed(templateName: "Standard Kitchen Remodel", templateType: .kitchen)
        manager.trackTemplateUsed(templateName: "Full Bathroom Renovation", templateType: .bathroom)
    }

    func testTrackExport() {
        let manager = AnalyticsManager.shared

        manager.trackExport(type: "csv_jobs", itemCount: 25)
        manager.trackExport(type: "csv_payments", itemCount: 50)
    }

    func testTrackBulkAction() {
        let manager = AnalyticsManager.shared

        manager.trackBulkAction(action: "mark_complete", itemCount: 3)
        manager.trackBulkAction(action: "delete", itemCount: 5)
    }

    func testTrackPaymentAdded() {
        let manager = AnalyticsManager.shared

        manager.trackPaymentAdded(amount: 5000, method: "check")
        manager.trackPaymentAdded(amount: 3000, method: "cash")
    }

    func testTrackAICameraUsed() {
        let manager = AnalyticsManager.shared

        // Should not throw or crash
        manager.trackAICameraUsed()
    }

    func testTrackAIEstimateGenerated() {
        let manager = AnalyticsManager.shared

        manager.trackAIEstimateGenerated(success: true, processingTime: 2.5)
        manager.trackAIEstimateGenerated(success: false, processingTime: 1.2)
    }

    func testTrackError() {
        let manager = AnalyticsManager.shared

        manager.trackError(domain: "TestDomain", code: 404, description: "Test error")
        manager.trackError(domain: "NetworkError", code: 500, description: "Server error")
    }

    func testTrackPerformance() {
        let manager = AnalyticsManager.shared

        manager.trackPerformance(metric: "job_load_time", value: 150.5, unit: "ms")
        manager.trackPerformance(metric: "pdf_generation", value: 2.3, unit: "s")
    }

    func testTrackSessionStart() {
        let manager = AnalyticsManager.shared

        // Should not throw or crash
        manager.trackSessionStart()
    }

    func testTrackSessionEnd() {
        let manager = AnalyticsManager.shared

        // Should not throw or crash
        manager.trackSessionEnd(duration: 3600)
    }

    func testTrackScreenView() {
        let manager = AnalyticsManager.shared

        manager.trackScreenView("DashboardView")
        manager.trackScreenView("NewEstimateView")
        manager.trackScreenView("JobDetailView")
    }

    // MARK: - Analytics Event Tests

    func testAnalyticsEventCreation() {
        let event = AnalyticsEvent(
            name: "test_event",
            properties: ["key1": "value1", "key2": 123]
        )

        XCTAssertEqual(event.name, "test_event")
        XCTAssertNotNil(event.id)
        XCTAssertNotNil(event.timestamp)
        XCTAssertEqual(event.properties.count, 2)
    }

    func testAnalyticsEventWithEmptyProperties() {
        let event = AnalyticsEvent(
            name: "simple_event",
            properties: [:]
        )

        XCTAssertEqual(event.name, "simple_event")
        XCTAssertTrue(event.properties.isEmpty)
    }

    // MARK: - Error Tracker Tests

    func testErrorTrackerSingleton() {
        let tracker1 = ErrorTracker.shared
        let tracker2 = ErrorTracker.shared

        XCTAssertTrue(tracker1 === tracker2, "ErrorTracker should be a singleton")
    }

    func testTrackErrorWithSeverity() {
        let tracker = ErrorTracker.shared

        enum TestError: Error {
            case testCase
        }

        // Should not throw or crash
        tracker.trackError(TestError.testCase, context: "Test Context", severity: .error)
        tracker.trackError(TestError.testCase, context: "Critical Test", severity: .critical)
    }

    func testTrackMessage() {
        let tracker = ErrorTracker.shared

        tracker.trackMessage("Test info message", level: .info)
        tracker.trackMessage("Test warning message", level: .warning)
        tracker.trackMessage("Test error message", level: .error)
    }

    func testErrorSeverityComparison() {
        XCTAssertTrue(ErrorSeverity.info < ErrorSeverity.warning)
        XCTAssertTrue(ErrorSeverity.warning < ErrorSeverity.error)
        XCTAssertTrue(ErrorSeverity.error < ErrorSeverity.critical)
    }

    func testTrackJobError() {
        let tracker = ErrorTracker.shared

        enum JobError: Error {
            case saveFailed
        }

        let jobId = UUID()
        tracker.trackJobError(JobError.saveFailed, jobId: jobId, operation: "save")
    }

    func testTrackPaymentError() {
        let tracker = ErrorTracker.shared

        enum PaymentError: Error {
            case invalidAmount
        }

        tracker.trackPaymentError(PaymentError.invalidAmount, amount: 5000, method: "check")
    }

    func testGetErrorStats() {
        let tracker = ErrorTracker.shared
        let stats = tracker.getErrorStats()

        XCTAssertGreaterThanOrEqual(stats.total, 0)
        XCTAssertGreaterThanOrEqual(stats.critical, 0)
        XCTAssertGreaterThanOrEqual(stats.errors, 0)
        XCTAssertGreaterThanOrEqual(stats.warnings, 0)
    }

    // MARK: - Performance Monitor Tests

    func testPerformanceMonitorSingleton() {
        let monitor1 = PerformanceMonitor.shared
        let monitor2 = PerformanceMonitor.shared

        XCTAssertTrue(monitor1 === monitor2, "PerformanceMonitor should be a singleton")
    }

    func testTimerMeasurement() {
        let monitor = PerformanceMonitor.shared

        monitor.startTimer("test_operation")

        // Simulate some work
        Thread.sleep(forTimeInterval: 0.1)

        monitor.endTimer("test_operation", context: "Test context")

        // Timer should have recorded a duration
    }

    func testMeasureFunction() {
        let monitor = PerformanceMonitor.shared

        let result = monitor.measure("calculation") {
            return 2 + 2
        }

        XCTAssertEqual(result, 4)
    }

    func testRecordMemoryUsage() {
        let monitor = PerformanceMonitor.shared

        // Should not throw or crash
        monitor.recordMemoryUsage(context: "Test")
    }

    func testRecordMetric() {
        let monitor = PerformanceMonitor.shared

        monitor.recordMetric("custom_metric", value: 123.45, unit: "units", context: "Test")
    }

    func testTrackJobLoadTime() {
        let monitor = PerformanceMonitor.shared

        monitor.trackJobLoadTime(duration: 0.5, jobCount: 25)
        monitor.trackJobLoadTime(duration: 1.2, jobCount: 100)
    }

    func testTrackPDFGeneration() {
        let monitor = PerformanceMonitor.shared

        monitor.trackPDFGeneration(duration: 2.3, success: true)
        monitor.trackPDFGeneration(duration: 1.5, success: false)
    }

    func testTrackExportTime() {
        let monitor = PerformanceMonitor.shared

        monitor.trackExportTime(duration: 1.8, exportType: "CSV", itemCount: 50)
    }

    func testTrackAIProcessing() {
        let monitor = PerformanceMonitor.shared

        monitor.trackAIProcessing(duration: 5.2, imageCount: 3, success: true)
    }

    func testTrackAppLaunch() {
        let monitor = PerformanceMonitor.shared

        monitor.trackAppLaunch(duration: 1.5)
    }

    func testGetAverageMetric() {
        let monitor = PerformanceMonitor.shared

        // Record some metrics
        monitor.recordMetric("test_metric", value: 100)
        monitor.recordMetric("test_metric", value: 200)
        monitor.recordMetric("test_metric", value: 300)

        if let average = monitor.getAverageMetric("test_metric") {
            XCTAssertEqual(average, 200, accuracy: 0.01)
        }
    }

    // MARK: - Metric Type Tests

    func testMetricTypes() {
        let timingMetric = PerformanceMetric(
            name: "timing_test",
            duration: 1.5,
            metricType: .timing
        )

        let memoryMetric = PerformanceMetric(
            name: "memory_test",
            value: 100000,
            metricType: .memory
        )

        let customMetric = PerformanceMetric(
            name: "custom_test",
            value: 42,
            metricType: .custom
        )

        XCTAssertEqual(timingMetric.metricType, .timing)
        XCTAssertEqual(memoryMetric.metricType, .memory)
        XCTAssertEqual(customMetric.metricType, .custom)
    }
}
