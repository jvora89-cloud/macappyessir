//
//  ExportView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var selectedExportType: ExportType = .allJobs

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Export your jobs and payments to CSV")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(24)

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Export Type Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Export Type")
                            .font(.headline)

                        VStack(spacing: 12) {
                            ForEach(ExportType.allCases) { exportType in
                                ExportTypeCard(
                                    type: exportType,
                                    isSelected: selectedExportType == exportType,
                                    action: {
                                        selectedExportType = exportType
                                    }
                                )
                            }
                        }
                    }

                    // Export Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What will be exported:")
                            .font(.headline)

                        HStack(spacing: 20) {
                            StatBadge(
                                value: "\(exportCount)",
                                label: exportCountLabel,
                                icon: selectedExportType.icon,
                                color: .blue
                            )

                            if selectedExportType == .payments {
                                StatBadge(
                                    value: "$\(Int(totalPaymentsAmount / 1000))K",
                                    label: "Total Value",
                                    icon: "dollarsign",
                                    color: .green
                                )
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)

                    // Export Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Export Information")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Text(selectedExportType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Files are saved to: ~/Documents/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
                .padding(24)
            }

            Divider()

            // Footer
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(action: { performExport() }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Export CSV")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .frame(width: 600, height: 700)
    }

    private var exportCount: Int {
        switch selectedExportType {
        case .allJobs:
            return appState.jobs.count
        case .activeJobs:
            return appState.activeJobs.count
        case .completedJobs:
            return appState.completedJobs.count
        case .payments:
            return appState.jobs.reduce(0) { $0 + $1.payments.count }
        case .financialSummary:
            return 1
        case .byType:
            return Set(appState.jobs.map { $0.contractorType }).count
        }
    }

    private var exportCountLabel: String {
        switch selectedExportType {
        case .allJobs: return "Jobs"
        case .activeJobs: return "Active"
        case .completedJobs: return "Completed"
        case .payments: return "Payments"
        case .financialSummary: return "Report"
        case .byType: return "Types"
        }
    }

    private var totalPaymentsAmount: Double {
        appState.jobs.reduce(0) { $0 + $1.totalPaid }
    }

    private func performExport() {
        if let fileURL = CSVExporter.shared.quickExport(jobs: appState.jobs, type: selectedExportType) {
            // Show in Finder
            NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: fileURL.deletingLastPathComponent().path)

            appState.toastManager.show(
                message: "Exported successfully!",
                icon: "checkmark.circle.fill"
            )

            dismiss()
        } else {
            appState.toastManager.show(
                message: "Export failed",
                icon: "exclamationmark.triangle"
            )
        }
    }
}

struct ExportTypeCard: View {
    let type: ExportType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color(nsColor: .controlBackgroundColor))
                        .frame(width: 44, height: 44)

                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(isSelected ? Color.blue.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ExportView()
        .environment(AppState())
}
