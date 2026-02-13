//
//  SettingsView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var companyName: String = "Your Company Name"
    @State private var businessType: String = "General Contractor"
    @State private var notificationsEnabled: Bool = true
    @State private var autoBackup: Bool = true
    @State private var showKeyboardShortcuts: Bool = false
    @State private var showExportView: Bool = false
    @State private var showDiagnostics: Bool = false
    @State private var showCameraDiagnostics: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                // Business Info
                SettingsSection(title: "Business Information") {
                    VStack(spacing: 16) {
                        SettingsField(title: "Company Name", text: $companyName)
                        SettingsField(title: "Business Type", text: $businessType)
                    }
                }

                // Appearance
                SettingsSection(title: "Appearance") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Picker("", selection: Binding(
                            get: { appState.theme },
                            set: { appState.theme = $0 }
                        )) {
                            ForEach(AppTheme.allCases) { theme in
                                HStack {
                                    Image(systemName: themeIcon(for: theme))
                                    Text(theme.rawValue)
                                }
                                .tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text("Choose how QuoteHub looks. System will match your macOS appearance.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }

                // App Preferences
                SettingsSection(title: "Preferences") {
                    VStack(spacing: 12) {
                        SettingsToggle(
                            title: "Notifications",
                            subtitle: "Receive job updates and reminders",
                            isOn: $notificationsEnabled
                        )

                        Divider()

                        SettingsToggle(
                            title: "Auto Backup",
                            subtitle: "Automatically backup job data",
                            isOn: $autoBackup
                        )
                    }
                }

                // AI Settings
                SettingsSection(title: "AI Features") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Camera Estimates")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Coming soon - automatic estimates from photos")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Data Export
                SettingsSection(title: "Data Export") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Export to CSV")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Export jobs, payments, and financial reports")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Export Data") {
                                showExportView = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                // Data Storage
                SettingsSection(title: "Data Storage") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Data Location")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(DataManager.shared.getDataDirectoryPath())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button("Show in Finder") {
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: DataManager.shared.getDataDirectoryPath())
                            }
                            .buttonStyle(.bordered)
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Photos Directory")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(DataManager.shared.getPhotosDirectoryPath())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button("Show in Finder") {
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: DataManager.shared.getPhotosDirectoryPath())
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                // Diagnostics
                SettingsSection(title: "Diagnostics") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Performance & Error Monitoring")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("View app performance metrics and error logs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("View Diagnostics") {
                                showDiagnostics = true
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Camera Diagnostic")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Check camera status and troubleshoot issues")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Camera Test") {
                                showCameraDiagnostics = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                // About
                SettingsSection(title: "About") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Version")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("1.0.0")
                                .fontWeight(.medium)
                        }

                        Divider()

                        Button("Keyboard Shortcuts") {
                            showKeyboardShortcuts = true
                        }
                        .buttonStyle(.link)

                        Divider()

                        Button("Privacy Policy") {}
                            .buttonStyle(.link)

                        Divider()

                        Button("Terms of Service") {}
                            .buttonStyle(.link)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showKeyboardShortcuts) {
            KeyboardShortcutsView()
        }
        .sheet(isPresented: $showExportView) {
            ExportView()
        }
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsView()
        }
        .sheet(isPresented: $showCameraDiagnostics) {
            CameraDiagnosticView()
        }
    }

    private func themeIcon(for theme: AppTheme) -> String {
        switch theme {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 24)

            VStack {
                content
            }
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
}

struct SettingsField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
