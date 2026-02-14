//
//  UpdateChecker.swift
//  macappyessir
//
//  Checks for app updates from GitHub releases
//

import Foundation
import SwiftUI

@Observable
class UpdateChecker {
    var isCheckingForUpdates = false
    var latestVersion: String?
    var updateAvailable = false
    var downloadURL: URL?
    var releaseNotes: String?

    static let shared = UpdateChecker()

    private let currentVersion = "1.0.0" // Update this with each release
    private let githubRepo = "jvora89-cloud/macappyessir"
    private let releasesAPI = "https://api.github.com/repos/jvora89-cloud/macappyessir/releases/latest"

    private init() {}

    // MARK: - Public API

    func checkForUpdates(silent: Bool = true) {
        guard !isCheckingForUpdates else { return }

        isCheckingForUpdates = true

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: releasesAPI)!)
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)

                await MainActor.run {
                    self.latestVersion = release.tagName.replacingOccurrences(of: "v", with: "")
                    self.downloadURL = URL(string: release.htmlURL)
                    self.releaseNotes = release.body

                    // Compare versions
                    if self.isNewerVersion(latest: self.latestVersion ?? "", current: currentVersion) {
                        self.updateAvailable = true

                        if !silent {
                            self.showUpdateNotification()
                        }
                    } else if !silent {
                        // Show "up to date" message
                        print("✅ App is up to date")
                    }

                    self.isCheckingForUpdates = false
                }
            } catch {
                await MainActor.run {
                    self.isCheckingForUpdates = false
                    if !silent {
                        print("❌ Failed to check for updates: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func checkOnLaunch() {
        // Check for updates on launch (but not every time, only once per day)
        let lastCheckKey = "lastUpdateCheck"
        let lastCheck = UserDefaults.standard.double(forKey: lastCheckKey)
        let now = Date().timeIntervalSince1970

        // Check once per day
        if now - lastCheck > 24 * 60 * 60 {
            UserDefaults.standard.set(now, forKey: lastCheckKey)
            checkForUpdates(silent: true)
        }
    }

    func openDownloadPage() {
        if let url = downloadURL {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Private Methods

    private func isNewerVersion(latest: String, current: String) -> Bool {
        let latestComponents = latest.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }

        for (latest, current) in zip(latestComponents, currentComponents) {
            if latest > current {
                return true
            } else if latest < current {
                return false
            }
        }

        return latestComponents.count > currentComponents.count
    }

    private func showUpdateNotification() {
        // This would show a native notification
        // For now, just set a flag that the UI can observe
        print("🎉 Update available: \(latestVersion ?? "unknown")")
    }
}

// MARK: - GitHub Release Model

struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let body: String
    let htmlURL: String
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlURL = "html_url"
        case publishedAt = "published_at"
    }
}

// MARK: - Update Banner View

struct UpdateBannerView: View {
    @Environment(UpdateChecker.self) private var updateChecker
    @State private var showDetails = false

    var body: some View {
        if updateChecker.updateAvailable {
            HStack(spacing: 16) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Update Available")
                        .font(.headline)
                        .foregroundColor(.white)

                    if let version = updateChecker.latestVersion {
                        Text("Version \(version) is now available")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                Spacer()

                Button("View Details") {
                    showDetails = true
                }
                .buttonStyle(.bordered)
                .tint(.white)

                Button("Download") {
                    updateChecker.openDownloadPage()
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)

                Button(action: {
                    withAnimation {
                        updateChecker.updateAvailable = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .sheet(isPresented: $showDetails) {
                UpdateDetailsView()
            }
        }
    }
}

// MARK: - Update Details View

struct UpdateDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UpdateChecker.self) private var updateChecker

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Update Available")
                        .font(.title.bold())

                    if let version = updateChecker.latestVersion {
                        Text("Version \(version)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(24)

            Divider()

            // Release notes
            ScrollView {
                if let notes = updateChecker.releaseNotes {
                    Text(notes)
                        .font(.body)
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("No release notes available")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }

            Divider()

            // Action buttons
            HStack {
                Button("Remind Me Later") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Download Update") {
                    updateChecker.openDownloadPage()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Settings Integration

struct UpdateSettingsRow: View {
    @Environment(UpdateChecker.self) private var updateChecker

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Check for Updates")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if updateChecker.isCheckingForUpdates {
                    Text("Checking...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if updateChecker.updateAvailable {
                    Text("Update available!")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("You're up to date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(updateChecker.isCheckingForUpdates ? "Checking..." : "Check Now") {
                updateChecker.checkForUpdates(silent: false)
            }
            .disabled(updateChecker.isCheckingForUpdates)
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Preview

#Preview {
    UpdateBannerView()
        .environment(UpdateChecker.shared)
        .padding()
}

#Preview("Details") {
    UpdateDetailsView()
        .environment(UpdateChecker.shared)
}
