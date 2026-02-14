//
//  AppPreferences.swift
//  macappyessir
//
//  User preferences and customization
//

import Foundation
import SwiftUI

@Observable
class AppPreferences {
    // Currency
    var currencySymbol: String {
        didSet { UserDefaults.standard.set(currencySymbol, forKey: "currencySymbol") }
    }

    // Date Format
    var dateFormat: DateFormatStyle {
        didSet { UserDefaults.standard.set(dateFormat.rawValue, forKey: "dateFormat") }
    }

    // Payment Terms
    var defaultPaymentTerms: String {
        didSet { UserDefaults.standard.set(defaultPaymentTerms, forKey: "defaultPaymentTerms") }
    }

    // Auto-save
    var autoSaveInterval: Int {
        didSet { UserDefaults.standard.set(autoSaveInterval, forKey: "autoSaveInterval") }
    }

    // Startup Behavior
    var startupBehavior: StartupBehavior {
        didSet { UserDefaults.standard.set(startupBehavior.rawValue, forKey: "startupBehavior") }
    }

    // Notification Preferences
    var notifyOnPaymentReceived: Bool {
        didSet { UserDefaults.standard.set(notifyOnPaymentReceived, forKey: "notifyOnPaymentReceived") }
    }

    var notifyOnJobCompletion: Bool {
        didSet { UserDefaults.standard.set(notifyOnJobCompletion, forKey: "notifyOnJobCompletion") }
    }

    // Display Preferences
    var showJobCostInList: Bool {
        didSet { UserDefaults.standard.set(showJobCostInList, forKey: "showJobCostInList") }
    }

    var compactMode: Bool {
        didSet { UserDefaults.standard.set(compactMode, forKey: "compactMode") }
    }

    // PDF Preferences
    var defaultPDFTemplate: String {
        didSet { UserDefaults.standard.set(defaultPDFTemplate, forKey: "defaultPDFTemplate") }
    }

    var includeTaxInPDF: Bool {
        didSet { UserDefaults.standard.set(includeTaxInPDF, forKey: "includeTaxInPDF") }
    }

    var taxRate: Double {
        didSet { UserDefaults.standard.set(taxRate, forKey: "taxRate") }
    }

    // Custom Job Types
    var customJobTypes: [String] {
        didSet {
            if let encoded = try? JSONEncoder().encode(customJobTypes) {
                UserDefaults.standard.set(encoded, forKey: "customJobTypes")
            }
        }
    }

    // Backup Preferences
    var autoBackupEnabled: Bool {
        didSet { UserDefaults.standard.set(autoBackupEnabled, forKey: "autoBackupEnabled") }
    }

    var backupFrequency: BackupFrequency {
        didSet { UserDefaults.standard.set(backupFrequency.rawValue, forKey: "backupFrequency") }
    }

    static let shared = AppPreferences()

    private init() {
        // Load saved preferences or use defaults
        self.currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.dateFormat = DateFormatStyle(rawValue: UserDefaults.standard.string(forKey: "dateFormat") ?? "US") ?? .us
        self.defaultPaymentTerms = UserDefaults.standard.string(forKey: "defaultPaymentTerms") ?? "Payment due within 30 days of completion. Late payments subject to 1.5% monthly interest."
        self.autoSaveInterval = UserDefaults.standard.integer(forKey: "autoSaveInterval") != 0 ? UserDefaults.standard.integer(forKey: "autoSaveInterval") : 60
        self.startupBehavior = StartupBehavior(rawValue: UserDefaults.standard.string(forKey: "startupBehavior") ?? "dashboard") ?? .dashboard
        self.notifyOnPaymentReceived = UserDefaults.standard.bool(forKey: "notifyOnPaymentReceived")
        self.notifyOnJobCompletion = UserDefaults.standard.bool(forKey: "notifyOnJobCompletion")
        self.showJobCostInList = UserDefaults.standard.bool(forKey: "showJobCostInList")
        self.compactMode = UserDefaults.standard.bool(forKey: "compactMode")
        self.defaultPDFTemplate = UserDefaults.standard.string(forKey: "defaultPDFTemplate") ?? "Modern"
        self.includeTaxInPDF = UserDefaults.standard.bool(forKey: "includeTaxInPDF")
        self.taxRate = UserDefaults.standard.double(forKey: "taxRate") != 0 ? UserDefaults.standard.double(forKey: "taxRate") : 0.08
        self.autoBackupEnabled = UserDefaults.standard.bool(forKey: "autoBackupEnabled")
        self.backupFrequency = BackupFrequency(rawValue: UserDefaults.standard.string(forKey: "backupFrequency") ?? "daily") ?? .daily

        // Load custom job types
        if let data = UserDefaults.standard.data(forKey: "customJobTypes"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            self.customJobTypes = decoded
        } else {
            self.customJobTypes = []
        }
    }

    func resetToDefaults() {
        currencySymbol = "$"
        dateFormat = .us
        defaultPaymentTerms = "Payment due within 30 days of completion. Late payments subject to 1.5% monthly interest."
        autoSaveInterval = 60
        startupBehavior = .dashboard
        notifyOnPaymentReceived = false
        notifyOnJobCompletion = false
        showJobCostInList = false
        compactMode = false
        defaultPDFTemplate = "Modern"
        includeTaxInPDF = false
        taxRate = 0.08
        customJobTypes = []
        autoBackupEnabled = false
        backupFrequency = .daily
    }
}

// MARK: - Preference Types

enum DateFormatStyle: String, CaseIterable, Identifiable {
    case us = "US"
    case european = "European"
    case iso = "ISO"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .us: return "MM/DD/YYYY"
        case .european: return "DD/MM/YYYY"
        case .iso: return "YYYY-MM-DD"
        }
    }

    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch self {
        case .us:
            formatter.dateFormat = "MM/dd/yyyy"
        case .european:
            formatter.dateFormat = "dd/MM/yyyy"
        case .iso:
            formatter.dateFormat = "yyyy-MM-dd"
        }
        return formatter.string(from: date)
    }
}

enum StartupBehavior: String, CaseIterable, Identifiable {
    case dashboard = "dashboard"
    case lastView = "lastView"
    case jobs = "jobs"
    case newEstimate = "newEstimate"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .lastView: return "Last Used View"
        case .jobs: return "Jobs List"
        case .newEstimate: return "New Estimate"
        }
    }
}

enum BackupFrequency: String, CaseIterable, Identifiable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}

// MARK: - Preferences View

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferences = AppPreferences.shared
    @State private var newJobType = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Preferences")
                    .font(.title.bold())

                Spacer()

                Button("Reset to Defaults") {
                    preferences.resetToDefaults()
                }
                .buttonStyle(.bordered)

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)

            Divider()

            // Preferences content
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // General Section
                    PreferenceSection(title: "General", icon: "gearshape.fill") {
                        PreferenceRow(title: "Currency Symbol") {
                            TextField("$", text: $preferences.currencySymbol)
                                .frame(width: 80)
                                .textFieldStyle(.roundedBorder)
                        }

                        PreferenceRow(title: "Date Format") {
                            Picker("", selection: $preferences.dateFormat) {
                                ForEach(DateFormatStyle.allCases) { format in
                                    Text(format.displayName).tag(format)
                                }
                            }
                            .frame(width: 150)
                        }

                        PreferenceRow(title: "Startup Behavior") {
                            Picker("", selection: $preferences.startupBehavior) {
                                ForEach(StartupBehavior.allCases) { behavior in
                                    Text(behavior.displayName).tag(behavior)
                                }
                            }
                            .frame(width: 200)
                        }

                        PreferenceRow(title: "Auto-save Interval") {
                            HStack {
                                Slider(value: Binding(
                                    get: { Double(preferences.autoSaveInterval) },
                                    set: { preferences.autoSaveInterval = Int($0) }
                                ), in: 30...300, step: 30)
                                .frame(width: 200)

                                Text("\(preferences.autoSaveInterval)s")
                                    .frame(width: 50, alignment: .leading)
                            }
                        }
                    }

                    // PDF Section
                    PreferenceSection(title: "PDF Export", icon: "doc.richtext.fill") {
                        PreferenceRow(title: "Default Template") {
                            Picker("", selection: $preferences.defaultPDFTemplate) {
                                Text("Modern").tag("Modern")
                                Text("Classic").tag("Classic")
                                Text("Minimal").tag("Minimal")
                            }
                            .frame(width: 150)
                        }

                        PreferenceRow(title: "Include Tax") {
                            Toggle("", isOn: $preferences.includeTaxInPDF)
                        }

                        if preferences.includeTaxInPDF {
                            PreferenceRow(title: "Tax Rate") {
                                HStack {
                                    TextField("0.08", value: $preferences.taxRate, format: .number)
                                        .frame(width: 80)
                                        .textFieldStyle(.roundedBorder)

                                    Text("(\(preferences.taxRate * 100, specifier: "%.1f")%)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        PreferenceRow(title: "Payment Terms") {
                            TextEditor(text: $preferences.defaultPaymentTerms)
                                .frame(height: 80)
                                .border(Color.gray.opacity(0.3))
                        }
                    }

                    // Custom Job Types
                    PreferenceSection(title: "Custom Job Types", icon: "wrench.and.screwdriver.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add your own job types beyond the defaults")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                TextField("Enter job type", text: $newJobType)
                                    .textFieldStyle(.roundedBorder)

                                Button("Add") {
                                    if !newJobType.isEmpty {
                                        preferences.customJobTypes.append(newJobType)
                                        newJobType = ""
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            if !preferences.customJobTypes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(preferences.customJobTypes, id: \.self) { type in
                                        HStack {
                                            Text(type)
                                            Spacer()
                                            Button(action: {
                                                preferences.customJobTypes.removeAll { $0 == type }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }

                    // Notifications
                    PreferenceSection(title: "Notifications", icon: "bell.fill") {
                        PreferenceRow(title: "Payment Received") {
                            Toggle("", isOn: $preferences.notifyOnPaymentReceived)
                        }

                        PreferenceRow(title: "Job Completion") {
                            Toggle("", isOn: $preferences.notifyOnJobCompletion)
                        }
                    }

                    // Backup
                    PreferenceSection(title: "Backup", icon: "arrow.clockwise.circle.fill") {
                        PreferenceRow(title: "Auto Backup") {
                            Toggle("", isOn: $preferences.autoBackupEnabled)
                        }

                        if preferences.autoBackupEnabled {
                            PreferenceRow(title: "Frequency") {
                                Picker("", selection: $preferences.backupFrequency) {
                                    ForEach(BackupFrequency.allCases) { frequency in
                                        Text(frequency.displayName).tag(frequency)
                                    }
                                }
                                .frame(width: 150)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 700, height: 600)
    }
}

struct PreferenceSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(.leading, 32)
        }
    }
}

struct PreferenceRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 150, alignment: .leading)

            content
        }
    }
}

// MARK: - Preview

#Preview {
    PreferencesView()
}
