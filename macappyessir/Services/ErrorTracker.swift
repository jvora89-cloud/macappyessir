//
//  ErrorTracker.swift
//  macappyessir
//
//  Created by Jay Vora on 2/10/26.
//

import Foundation
import OSLog

/// Error tracking service for monitoring app health and crashes
class ErrorTracker {
    static let shared = ErrorTracker()

    private let logger = Logger(subsystem: "com.quotehub.app", category: "ErrorTracking")
    private var errorLog: [TrackedError] = []
    private let maxStoredErrors = 100

    private init() {
        setupErrorHandling()
    }

    // MARK: - Setup

    private func setupErrorHandling() {
        // Set up global exception handler
        NSSetUncaughtExceptionHandler { exception in
            ErrorTracker.shared.trackException(exception)
        }

        logger.info("Error tracking initialized")
    }

    // MARK: - Track Errors

    func trackError(
        _ error: Error,
        context: String = "",
        severity: ErrorSeverity = .error,
        additionalInfo: [String: Any] = [:]
    ) {
        let trackedError = TrackedError(
            error: error,
            context: context,
            severity: severity,
            additionalInfo: additionalInfo
        )

        logError(trackedError)
        storeError(trackedError)
    }

    func trackException(_ exception: NSException) {
        let trackedError = TrackedError(
            name: exception.name.rawValue,
            message: exception.reason ?? "No reason provided",
            stackTrace: exception.callStackSymbols.joined(separator: "\n"),
            severity: .critical,
            additionalInfo: ["exception": exception.description]
        )

        logError(trackedError)
        storeError(trackedError)

        // In production, this would send immediately to error tracking service
        sendToErrorService(trackedError)
    }

    func trackMessage(
        _ message: String,
        level: ErrorSeverity = .info,
        context: String = "",
        additionalInfo: [String: Any] = [:]
    ) {
        let trackedError = TrackedError(
            name: level.rawValue,
            message: message,
            stackTrace: "",
            severity: level,
            context: context,
            additionalInfo: additionalInfo
        )

        logError(trackedError)

        if level >= .warning {
            storeError(trackedError)
        }
    }

    // MARK: - Domain-Specific Tracking

    func trackJobError(_ error: Error, jobId: UUID, operation: String) {
        trackError(
            error,
            context: "Job Operation",
            severity: .error,
            additionalInfo: [
                "job_id": jobId.uuidString,
                "operation": operation
            ]
        )
    }

    func trackPaymentError(_ error: Error, amount: Double, method: String) {
        trackError(
            error,
            context: "Payment Processing",
            severity: .error,
            additionalInfo: [
                "amount": amount,
                "payment_method": method
            ]
        )
    }

    func trackExportError(_ error: Error, exportType: String, itemCount: Int) {
        trackError(
            error,
            context: "Data Export",
            severity: .error,
            additionalInfo: [
                "export_type": exportType,
                "item_count": itemCount
            ]
        )
    }

    func trackPDFGenerationError(_ error: Error, jobId: UUID) {
        trackError(
            error,
            context: "PDF Generation",
            severity: .error,
            additionalInfo: [
                "job_id": jobId.uuidString
            ]
        )
    }

    func trackEmailError(_ error: Error, recipient: String) {
        trackError(
            error,
            context: "Email Sending",
            severity: .warning,
            additionalInfo: [
                "recipient": recipient
            ]
        )
    }

    func trackAIError(_ error: Error, operation: String, imageCount: Int = 0) {
        trackError(
            error,
            context: "AI Processing",
            severity: .error,
            additionalInfo: [
                "operation": operation,
                "image_count": imageCount
            ]
        )
    }

    func trackDataPersistenceError(_ error: Error, operation: String) {
        trackError(
            error,
            context: "Data Persistence",
            severity: .critical,
            additionalInfo: [
                "operation": operation
            ]
        )
    }

    // MARK: - Error Retrieval

    func getRecentErrors(limit: Int = 50) -> [TrackedError] {
        return Array(errorLog.prefix(limit))
    }

    func getErrorsByContext(_ context: String) -> [TrackedError] {
        return errorLog.filter { $0.context == context }
    }

    func getErrorsBySeverity(_ severity: ErrorSeverity) -> [TrackedError] {
        return errorLog.filter { $0.severity == severity }
    }

    func clearErrorLog() {
        errorLog.removeAll()
        logger.info("Error log cleared")
    }

    // MARK: - Error Statistics

    func getErrorStats() -> ErrorStats {
        let total = errorLog.count
        let critical = errorLog.filter { $0.severity == .critical }.count
        let errors = errorLog.filter { $0.severity == .error }.count
        let warnings = errorLog.filter { $0.severity == .warning }.count

        return ErrorStats(
            total: total,
            critical: critical,
            errors: errors,
            warnings: warnings
        )
    }

    // MARK: - Private Helpers

    private func logError(_ trackedError: TrackedError) {
        let logMessage = """
        ⚠️ Error Tracked
        Name: \(trackedError.name)
        Message: \(trackedError.message)
        Context: \(trackedError.context)
        Severity: \(trackedError.severity.rawValue)
        """

        switch trackedError.severity {
        case .critical:
            logger.critical("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        }

        #if DEBUG
        print(logMessage)
        if !trackedError.stackTrace.isEmpty {
            print("Stack Trace:\n\(trackedError.stackTrace)")
        }
        #endif
    }

    private func storeError(_ trackedError: TrackedError) {
        errorLog.insert(trackedError, at: 0)

        // Keep only the most recent errors
        if errorLog.count > maxStoredErrors {
            errorLog = Array(errorLog.prefix(maxStoredErrors))
        }
    }

    private func sendToErrorService(_ trackedError: TrackedError) {
        // In production, this would send to Sentry, Bugsnag, or similar service
        // For now, just log that we would send it
        logger.info("Would send error to tracking service: \(trackedError.name)")
    }
}

// MARK: - Models

struct TrackedError: Identifiable, Codable {
    let id: UUID
    let name: String
    let message: String
    let stackTrace: String
    let severity: ErrorSeverity
    let context: String
    let additionalInfo: [String: String]
    let timestamp: Date
    let appVersion: String
    let osVersion: String

    init(
        id: UUID = UUID(),
        name: String,
        message: String,
        stackTrace: String,
        severity: ErrorSeverity,
        context: String = "",
        additionalInfo: [String: Any] = [:]
    ) {
        self.id = id
        self.name = name
        self.message = message
        self.stackTrace = stackTrace
        self.severity = severity
        self.context = context
        // Convert Any to String for Codable
        self.additionalInfo = additionalInfo.mapValues { "\($0)" }
        self.timestamp = Date()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        self.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
    }

    init(
        error: Error,
        context: String = "",
        severity: ErrorSeverity,
        additionalInfo: [String: Any] = [:]
    ) {
        self.init(
            name: String(describing: type(of: error)),
            message: error.localizedDescription,
            stackTrace: Thread.callStackSymbols.joined(separator: "\n"),
            severity: severity,
            context: context,
            additionalInfo: additionalInfo
        )
    }
}

enum ErrorSeverity: String, Codable, Comparable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case critical = "Critical"

    static func < (lhs: ErrorSeverity, rhs: ErrorSeverity) -> Bool {
        let order: [ErrorSeverity] = [.info, .warning, .error, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

struct ErrorStats {
    let total: Int
    let critical: Int
    let errors: Int
    let warnings: Int

    var hasErrors: Bool {
        total > 0
    }

    var criticalRate: Double {
        total > 0 ? Double(critical) / Double(total) : 0
    }
}
