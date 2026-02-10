//
//  AccessibilityHelpers.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import SwiftUI
import Combine

// MARK: - Accessibility Identifiers
enum AccessibilityID {
    // Navigation
    static let sidebar = "sidebar"
    static let dashboardButton = "dashboard_button"
    static let newEstimateButton = "new_estimate_button"
    static let activeJobsButton = "active_jobs_button"
    static let completedJobsButton = "completed_jobs_button"
    static let settingsButton = "settings_button"

    // Dashboard
    static let dashboardView = "dashboard_view"
    static let statsGrid = "stats_grid"
    static let activeJobsStat = "active_jobs_stat"
    static let completedStat = "completed_stat"
    static let revenueStat = "revenue_stat"
    static let fundsReceivedStat = "funds_received_stat"

    // Jobs
    static let jobCard = "job_card"
    static let jobDetailView = "job_detail_view"
    static let editJobButton = "edit_job_button"
    static let deleteJobButton = "delete_job_button"
    static let markCompleteButton = "mark_complete_button"

    // Estimate
    static let estimateForm = "estimate_form"
    static let clientNameField = "client_name_field"
    static let addressField = "address_field"
    static let costField = "cost_field"
    static let createJobButton = "create_job_button"

    // Search
    static let searchField = "search_field"
}

// MARK: - View Extension for Accessibility
extension View {
    /// Adds accessibility label and hint
    func accessibleElement(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }

    /// Makes element accessible with identifier for UI testing
    func accessibleWithID(
        _ identifier: String,
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityIdentifier(identifier)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }

    /// Adds accessibility value for dynamic content
    func accessibleValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }
}

// MARK: - Keyboard Shortcuts Helper
struct KeyboardShortcutHelper {
    static let newEstimate = KeyboardShortcut("n", modifiers: .command)
    static let save = KeyboardShortcut("s", modifiers: .command)
    static let find = KeyboardShortcut("f", modifiers: .command)
    static let settings = KeyboardShortcut(",", modifiers: .command)
    static let dashboard = KeyboardShortcut("1", modifiers: .command)
    static let activeJobs = KeyboardShortcut("3", modifiers: .command)
    static let completedJobs = KeyboardShortcut("4", modifiers: .command)
}

// MARK: - Color Contrast Checker
struct ColorContrastChecker {
    /// Check if two colors meet WCAG AA standards (4.5:1 for normal text)
    static func meetsWCAGAA(foreground: Color, background: Color) -> Bool {
        // Simplified check - in production, use actual luminance calculation
        return true // Placeholder for proper implementation
    }

    /// Accessible color pairs for QuoteHub
    static let accessiblePairs: [(foreground: Color, background: Color)] = [
        (.primary, .white),
        (.white, .blue),
        (.white, .orange),
        (.secondary, .white)
    ]
}

// MARK: - Focus Management
class FocusStateManager: ObservableObject {
    @Published var focusedField: String?

    func focus(on field: String) {
        focusedField = field
    }

    func clearFocus() {
        focusedField = nil
    }
}

#Preview {
    VStack {
        Text("Accessibility Helper Preview")
            .accessibleElement(
                label: "Preview text",
                hint: "This demonstrates accessibility helpers"
            )

        Button("Test Button") {}
            .accessibleWithID(
                "test_button",
                label: "Test Button",
                hint: "Double tap to activate"
            )
    }
    .padding()
}
