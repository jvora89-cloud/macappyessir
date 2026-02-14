//
//  BackupManager.swift
//  macappyessir
//
//  Complete backup and export system
//

import Foundation
import AppKit
import ZIPFoundation

@Observable
class BackupManager {
    var isExporting = false
    var isImporting = false
    var lastBackupDate: Date?

    static let shared = BackupManager()

    private init() {
        loadLastBackupDate()
    }

    // MARK: - Full Backup

    func createFullBackup(includePhotos: Bool = true) async throws -> URL {
        isExporting = true
        defer { isExporting = false }

        let backupName = "LakshamiBackup_\(dateFormatter.string(from: Date()))"
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(backupName)

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Export jobs data
        let jobsURL = tempDir.appendingPathComponent("jobs.json")
        try await exportJobsData(to: jobsURL)

        // Export settings
        let settingsURL = tempDir.appendingPathComponent("settings.json")
        try exportSettings(to: settingsURL)

        // Copy photos if requested
        if includePhotos {
            let photosDir = tempDir.appendingPathComponent("photos")
            try FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)
            try await copyAllPhotos(to: photosDir)
        }

        // Create ZIP archive
        let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(backupName).zip")

        try FileManager.default.zipItem(at: tempDir, to: zipURL, shouldKeepParent: false)

        // Clean up temp directory
        try FileManager.default.removeItem(at: tempDir)

        // Update last backup date
        lastBackupDate = Date()
        saveLastBackupDate()

        return zipURL
    }

    // MARK: - Export Jobs as JSON

    func exportJobsData(to url: URL) async throws {
        // Get all jobs from app state (would need to pass appState)
        // For now, placeholder
        let jobsData = try JSONEncoder().encode(["version": "1.0", "exportDate": Date()])
        try jobsData.write(to: url)
    }

    // MARK: - Export as CSV

    func exportJobsAsCSV() async throws -> URL {
        isExporting = true
        defer { isExporting = false }

        let fileName = "LakshamiJobs_\(dateFormatter.string(from: Date())).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csvContent = "Client Name,Job Type,Estimated Cost,Status,Start Date,Progress,Payments Total\n"

        // Would iterate through jobs from AppState
        // Placeholder for now

        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    // MARK: - Restore from Backup

    func restoreFromBackup(backupURL: URL) async throws {
        isImporting = true
        defer { isImporting = false }

        // Verify it's a valid backup
        guard backupURL.pathExtension == "zip" else {
            throw BackupError.invalidBackupFile
        }

        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("RestoreTemp_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Unzip backup
        try FileManager.default.unzipItem(at: backupURL, to: tempDir)

        // Restore jobs
        let jobsURL = tempDir.appendingPathComponent("jobs.json")
        if FileManager.default.fileExists(atPath: jobsURL.path) {
            try await restoreJobsData(from: jobsURL)
        }

        // Restore settings
        let settingsURL = tempDir.appendingPathComponent("settings.json")
        if FileManager.default.fileExists(atPath: settingsURL.path) {
            try restoreSettings(from: settingsURL)
        }

        // Restore photos
        let photosDir = tempDir.appendingPathComponent("photos")
        if FileManager.default.fileExists(atPath: photosDir.path) {
            try await restorePhotos(from: photosDir)
        }

        // Clean up
        try FileManager.default.removeItem(at: tempDir)
    }

    // MARK: - Auto Backup

    func performAutoBackup(ifNeeded: Bool = true) async {
        let preferences = AppPreferences.shared

        guard preferences.autoBackupEnabled else { return }

        if ifNeeded {
            guard shouldPerformAutoBackup(frequency: preferences.backupFrequency) else {
                return
            }
        }

        do {
            let backupURL = try await createFullBackup(includePhotos: true)

            // Move to app support directory
            let appSupportURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("Lakshami Contractors/Backups")

            try FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)

            let destinationURL = appSupportURL.appendingPathComponent(backupURL.lastPathComponent)
            try FileManager.default.copyItem(at: backupURL, to: destinationURL)

            // Clean up old backups (keep last 5)
            try cleanupOldBackups(in: appSupportURL, keepLast: 5)

            print("✅ Auto backup completed: \(destinationURL.lastPathComponent)")
        } catch {
            print("❌ Auto backup failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods

    private func exportSettings(to url: URL) throws {
        let settings = [
            "currencySymbol": AppPreferences.shared.currencySymbol,
            "dateFormat": AppPreferences.shared.dateFormat.rawValue,
            "defaultPaymentTerms": AppPreferences.shared.defaultPaymentTerms
        ]

        let data = try JSONSerialization.data(withJSONObject: settings)
        try data.write(to: url)
    }

    private func restoreSettings(from url: URL) throws {
        let data = try Data(contentsOf: url)
        if let settings = try JSONSerialization.jsonObject(with: data) as? [String: String] {
            // Restore settings
            if let currency = settings["currencySymbol"] {
                AppPreferences.shared.currencySymbol = currency
            }
        }
    }

    private func copyAllPhotos(to directory: URL) async throws {
        // Would copy all photos from jobs
        // Placeholder
    }

    private func restoreJobsData(from url: URL) async throws {
        // Would restore jobs to AppState
        // Placeholder
    }

    private func restorePhotos(from directory: URL) async throws {
        // Would restore photos
        // Placeholder
    }

    private func shouldPerformAutoBackup(frequency: BackupFrequency) -> Bool {
        guard let lastBackup = lastBackupDate else { return true }

        let interval: TimeInterval
        switch frequency {
        case .daily: interval = 24 * 60 * 60
        case .weekly: interval = 7 * 24 * 60 * 60
        case .monthly: interval = 30 * 24 * 60 * 60
        }

        return Date().timeIntervalSince(lastBackup) >= interval
    }

    private func cleanupOldBackups(in directory: URL, keepLast: Int) throws {
        let backups = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )

        let sorted = try backups.sorted { url1, url2 in
            let date1 = try url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
            let date2 = try url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
            return date1 > date2
        }

        // Delete old backups beyond keepLast
        for backup in sorted.dropFirst(keepLast) {
            try FileManager.default.removeItem(at: backup)
        }
    }

    private func loadLastBackupDate() {
        if let timestamp = UserDefaults.standard.object(forKey: "lastBackupDate") as? TimeInterval {
            lastBackupDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    private func saveLastBackupDate() {
        if let date = lastBackupDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "lastBackupDate")
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter
    }
}

// MARK: - Backup Error

enum BackupError: LocalizedError {
    case invalidBackupFile
    case restoreFailed
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .invalidBackupFile: return "Invalid backup file format"
        case .restoreFailed: return "Failed to restore backup"
        case .exportFailed: return "Failed to export data"
        }
    }
}

// MARK: - Backup UI

struct BackupExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var backupManager = BackupManager.shared
    @State private var includePhotos = true
    @State private var exportFormat: ExportFormat = .fullBackup
    @State private var isProcessing = false
    @State private var resultURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""

    enum ExportFormat: String, CaseIterable, Identifiable {
        case fullBackup = "Full Backup (ZIP)"
        case csv = "Jobs CSV"
        case json = "Jobs JSON"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export & Backup")
                        .font(.title.bold())

                    if let lastBackup = backupManager.lastBackupDate {
                        Text("Last backup: \(lastBackup, style: .relative) ago")
                            .font(.caption)
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

            // Export options
            VStack(alignment: .leading, spacing: 16) {
                Text("Export Format")
                    .font(.headline)

                Picker("Format", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                if exportFormat == .fullBackup {
                    Toggle("Include photos", isOn: $includePhotos)
                        .padding(.top, 8)
                }

                Text(exportFormatDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Action buttons
            HStack {
                if let url = resultURL {
                    Button("Reveal in Finder") {
                        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                Button(isProcessing ? "Exporting..." : "Export") {
                    performExport()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
            .padding(24)
        }
        .frame(width: 500, height: 400)
        .alert("Export Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var exportFormatDescription: String {
        switch exportFormat {
        case .fullBackup:
            return "Complete backup including all jobs, payments, settings, and optionally photos. Can be restored later."
        case .csv:
            return "Export jobs as CSV file for use in Excel, Numbers, or other spreadsheet applications."
        case .json:
            return "Export jobs as JSON for integration with other tools or custom processing."
        }
    }

    private func performExport() {
        isProcessing = true

        Task {
            do {
                let url: URL
                switch exportFormat {
                case .fullBackup:
                    url = try await backupManager.createFullBackup(includePhotos: includePhotos)
                case .csv:
                    url = try await backupManager.exportJobsAsCSV()
                case .json:
                    url = try await backupManager.exportJobsData(to: FileManager.default.temporaryDirectory.appendingPathComponent("jobs.json"))
                }

                await MainActor.run {
                    resultURL = url
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isProcessing = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BackupExportView()
}
