//
//  OnboardingSystem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  First-time user onboarding tour and help system
//

import SwiftUI

// MARK: - Onboarding Model

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let tip: String?

    static let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to MacAppYesSir!",
            description: "Your professional contractor management app for macOS. Let's take a quick tour!",
            icon: "star.fill",
            tip: nil
        ),
        OnboardingStep(
            title: "Dashboard Overview",
            description: "View all your key metrics, revenue trends, and active jobs at a glance. See your business performance in real-time with beautiful charts.",
            icon: "chart.line.uptrend.xyaxis",
            tip: "Press ⌘1 to quickly return to the dashboard"
        ),
        OnboardingStep(
            title: "Create Estimates",
            description: "Use the multi-step wizard to create professional estimates. Choose AI Camera, templates, or manual entry for maximum flexibility.",
            icon: "doc.text.fill",
            tip: "Press ⌘N to create a new estimate anytime"
        ),
        OnboardingStep(
            title: "Command Palette",
            description: "Press ⌘K to access the powerful command palette. Search for jobs, clients, or quickly navigate anywhere in the app.",
            icon: "command",
            tip: "⌘K is the fastest way to navigate!"
        ),
        OnboardingStep(
            title: "Track Payments",
            description: "Manage payment schedules, milestones, and receipts. Get analytics on received payments and outstanding balances.",
            icon: "dollarsign.circle.fill",
            tip: "Set up payment milestones for larger projects"
        ),
        OnboardingStep(
            title: "Professional PDFs",
            description: "Export beautiful estimates, invoices, and receipts with multiple template styles and custom branding.",
            icon: "doc.badge.arrow.up.fill",
            tip: "Customize your branding in Settings"
        ),
        OnboardingStep(
            title: "You're All Set!",
            description: "You're ready to manage your contracting business like a pro. Start by creating your first estimate!",
            icon: "checkmark.circle.fill",
            tip: "Visit Settings anytime to customize your experience"
        )
    ]
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.smooth, value: currentStep)
                }
            }
            .frame(height: 4)

            // Content
            ZStack {
                ForEach(Array(OnboardingStep.steps.enumerated()), id: \.element.id) { index, step in
                    if index == currentStep {
                        onboardingStepView(step: step)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
            }
            .animation(.smooth, value: currentStep)

            Divider()

            // Navigation
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<OnboardingStep.steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.smooth, value: currentStep)
                    }
                }

                Spacer()

                if currentStep < OnboardingStep.steps.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return)
                }
            }
            .padding(20)
        }
        .frame(width: 700, height: 550)
    }

    private func onboardingStepView(step: OnboardingStep) -> some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: step.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }

            // Content
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(step.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 40)
            }

            // Tip
            if let tip = step.tip {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                    Text(tip)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private var progress: CGFloat {
        CGFloat(currentStep + 1) / CGFloat(OnboardingStep.steps.count)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

// MARK: - Help System

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    enum HelpTopic: String, CaseIterable, Identifiable {
        case gettingStarted = "Getting Started"
        case creatingEstimates = "Creating Estimates"
        case managingJobs = "Managing Jobs"
        case payments = "Payments & Invoices"
        case pdfExport = "PDF Export"
        case keyboardShortcuts = "Keyboard Shortcuts"
        case troubleshooting = "Troubleshooting"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .gettingStarted: return "play.circle.fill"
            case .creatingEstimates: return "doc.text.fill"
            case .managingJobs: return "briefcase.fill"
            case .payments: return "dollarsign.circle.fill"
            case .pdfExport: return "doc.badge.arrow.up.fill"
            case .keyboardShortcuts: return "command"
            case .troubleshooting: return "wrench.and.screwdriver.fill"
            }
        }

        var content: String {
            switch self {
            case .gettingStarted:
                return """
                Welcome to MacAppYesSir! Here's how to get started:

                1. Create your first estimate using ⌘N
                2. Use the AI Camera to capture job sites
                3. Set up payment schedules for your projects
                4. Export professional PDFs for clients

                The dashboard shows all your key metrics at a glance.
                """
            case .creatingEstimates:
                return """
                Creating estimates is easy with our wizard:

                • Choose AI Camera for automatic estimates
                • Use templates for common job types
                • Enter manually for custom projects

                The wizard guides you through 5 steps:
                1. Choose method
                2. Client information
                3. Job details
                4. Pricing
                5. Review & save
                """
            case .managingJobs:
                return """
                Manage all your jobs in one place:

                • View active and completed jobs
                • Track progress with detailed timelines
                • Add photos to document work
                • Update job status and milestones

                Use ⌘K to quickly find any job.
                """
            case .payments:
                return """
                Track payments and get paid faster:

                • Set up payment schedules
                • Track milestones and deposits
                • Generate professional receipts
                • View payment analytics

                Mark payments complete as you receive them.
                """
            case .pdfExport:
                return """
                Export professional documents:

                • Choose from multiple template styles
                • Customize with your branding
                • Preview before exporting
                • Share or save PDFs

                Set up your branding in Settings.
                """
            case .keyboardShortcuts:
                return """
                Master these keyboard shortcuts:

                ⌘K - Command Palette (search anything)
                ⌘N - New Estimate
                ⌘1 - Dashboard
                ⌘2 - New Estimate
                ⌘3 - Active Jobs
                ⌘4 - Completed Jobs
                ⌘5 - Settings
                ⌘, - Settings

                View all shortcuts in Settings → About.
                """
            case .troubleshooting:
                return """
                Common issues and solutions:

                Camera not working?
                • Check System Settings → Privacy → Camera
                • Try restarting the app
                • Run Camera Diagnostic in Settings

                Can't find a job?
                • Use ⌘K command palette
                • Check Active vs Completed tabs
                • Use advanced filters

                Need more help? Contact support@macappyessir.com
                """
            }
        }
    }

    @State private var selectedTopic: HelpTopic = .gettingStarted

    var body: some View {
        HSplitView {
            // Sidebar
            List(HelpTopic.allCases, selection: $selectedTopic) { topic in
                HStack(spacing: 12) {
                    Image(systemName: topic.icon)
                        .foregroundColor(.blue)
                    Text(topic.rawValue)
                }
                .tag(topic)
            }
            .frame(minWidth: 200, idealWidth: 250)

            // Content
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: selectedTopic.icon)
                        .font(.title)
                        .foregroundColor(.blue)
                    Text(selectedTopic.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                }

                ScrollView {
                    Text(selectedTopic.content)
                        .font(.body)
                        .lineSpacing(6)
                }

                Spacer()

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .frame(minWidth: 400)
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

// MARK: - Quick Tips Widget

struct QuickTipsWidget: View {
    @State private var currentTipIndex = 0
    @State private var isExpanded = false

    let tips = [
        "Press ⌘K to search for anything",
        "Create estimates faster with templates",
        "Set up payment milestones for large jobs",
        "Use batch mode to capture multiple photos",
        "Export PDFs with custom branding",
        "Filter jobs by type, cost, or progress"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("Quick Tip")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                Text(tips[currentTipIndex])
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)

                HStack {
                    Button(action: previousTip) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Spacer()

                    Text("\(currentTipIndex + 1) of \(tips.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: nextTip) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    private func nextTip() {
        withAnimation {
            currentTipIndex = (currentTipIndex + 1) % tips.count
        }
    }

    private func previousTip() {
        withAnimation {
            currentTipIndex = (currentTipIndex - 1 + tips.count) % tips.count
        }
    }
}

// MARK: - Settings Enhancement

extension SettingsView {
    var enhancedAboutSection: some View {
        SettingsSection(title: "Help & Support") {
            VStack(spacing: 12) {
                Button(action: {
                    // Show onboarding again
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("View Onboarding Tour")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Take the tour again")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)

                Divider()

                Button("Help & Documentation") {
                    // Open help view
                }
                .buttonStyle(.plain)

                Divider()

                Button("Contact Support") {
                    if let url = URL(string: "mailto:support@macappyessir.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
