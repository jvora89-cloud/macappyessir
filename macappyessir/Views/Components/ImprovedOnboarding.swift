//
//  ImprovedOnboarding.swift
//  macappyessir
//
//  Enhanced onboarding with sample data and interactive features
//

import SwiftUI

@Observable
class OnboardingManager {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var shouldShowWhatsNew: Bool {
        get { UserDefaults.standard.bool(forKey: "shouldShowWhatsNew_v1.0") }
        set { UserDefaults.standard.set(newValue, forKey: "shouldShowWhatsNew_v1.0") }
    }

    static let shared = OnboardingManager()

    private init() {
        // Check if this is first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            hasCompletedOnboarding = false
            shouldShowWhatsNew = false
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

// MARK: - Enhanced Onboarding View

struct EnhancedOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0
    @State private var showSampleDataOption = true
    @State private var wantsToLoadSampleData = true

    let steps: [OnboardingStepInfo] = [
        OnboardingStepInfo(
            title: "Welcome to Lakshami Contractors! 🏗️",
            description: "Your professional contractor management app for macOS. Let's get you set up in just a few steps.",
            icon: "hand.wave.fill",
            color: .blue,
            action: nil
        ),
        OnboardingStepInfo(
            title: "Start with Sample Data?",
            description: "We can load realistic sample jobs so you can explore the app right away. You can delete them anytime.",
            icon: "doc.text.fill",
            color: .green,
            action: .sampleData
        ),
        OnboardingStepInfo(
            title: "Keyboard Shortcuts",
            description: "Navigate faster with keyboard shortcuts. Press ⌘K anytime to search, ⌘N for new estimate, and ⌘1-5 to switch tabs.",
            icon: "keyboard.fill",
            color: .purple,
            action: nil
        ),
        OnboardingStepInfo(
            title: "Your Data is Private",
            description: "All your data stays on your Mac. No cloud, no tracking, complete privacy. Back up with Time Machine or manually.",
            icon: "lock.shield.fill",
            color: .orange,
            action: nil
        ),
        OnboardingStepInfo(
            title: "You're All Set!",
            description: "Ready to manage your contracting business like a pro. Let's dive in!",
            icon: "checkmark.circle.fill",
            color: .green,
            action: nil
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(.sRGB, red: 0.95, green: 0.95, blue: 0.97), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)

                // Content area
                TabView(selection: $currentStep) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        VStack(spacing: 32) {
                            Spacer()

                            // Icon
                            Image(systemName: step.icon)
                                .font(.system(size: 80))
                                .foregroundStyle(step.color.gradient)
                                .shadow(color: step.color.opacity(0.3), radius: 20, x: 0, y: 10)

                            // Title
                            Text(step.title)
                                .font(.system(size: 36, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 60)

                            // Description
                            Text(step.description)
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 80)

                            // Sample data toggle (only on step 1)
                            if step.action == .sampleData {
                                Toggle(isOn: $wantsToLoadSampleData) {
                                    HStack(spacing: 12) {
                                        Image(systemName: wantsToLoadSampleData ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundStyle(wantsToLoadSampleData ? .green : .gray)
                                        Text("Load 8 sample jobs to get started")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                }
                                .toggleStyle(.button)
                                .buttonStyle(.plain)
                                .padding(.top, 8)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }

                    Spacer()

                    if currentStep < steps.count - 1 {
                        Button("Continue") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .frame(width: 800, height: 600)
    }

    private func completeOnboarding() {
        // Load sample data if user wants it
        if wantsToLoadSampleData {
            #if DEBUG
            appState.loadSampleData()
            #else
            SampleDataGenerator.shared.generateSampleData(for: appState)
            #endif
        }

        OnboardingManager.shared.completeOnboarding()
        dismiss()
    }
}

// MARK: - Onboarding Step Model

struct OnboardingStepInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: OnboardingAction?
}

enum OnboardingAction {
    case sampleData
}

// MARK: - What's New View

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.gradient)

                Text("What's New in 1.0")
                    .font(.system(size: 32, weight: .bold))

                Text("Lakshami Contractors")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)

            // Features list
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    FeatureRow(
                        icon: "wand.and.stars",
                        title: "Smart Estimate Wizard",
                        description: "Create professional estimates in minutes with our 5-step wizard and auto-complete."
                    )

                    FeatureRow(
                        icon: "magnifyingglass",
                        title: "Command Palette",
                        description: "Press ⌘K to instantly search jobs, clients, or navigate anywhere."
                    )

                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Payment Analytics",
                        description: "Track payments with milestone schedules and visualize your cash flow."
                    )

                    FeatureRow(
                        icon: "doc.richtext",
                        title: "Professional PDFs",
                        description: "Export stunning estimates with 3 template styles and custom branding."
                    )

                    FeatureRow(
                        icon: "camera.fill",
                        title: "Photo Documentation",
                        description: "Capture, edit, and annotate photos with built-in camera tools."
                    )

                    FeatureRow(
                        icon: "slider.horizontal.3",
                        title: "Advanced Filtering",
                        description: "Find any job instantly with powerful filters and saved presets."
                    )
                }
                .padding(.horizontal, 40)
            }
            .frame(maxHeight: 300)

            // CTA Button
            Button("Continue") {
                OnboardingManager.shared.shouldShowWhatsNew = false
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 32)
            .padding(.bottom, 40)
        }
        .frame(width: 600, height: 600)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EnhancedOnboardingView()
        .environment(AppState())
}

#Preview("What's New") {
    WhatsNewView()
}
