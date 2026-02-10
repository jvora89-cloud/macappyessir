//
//  ActiveJobsView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct ActiveJobsView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText: String = ""
    @State private var isSelectionMode: Bool = false
    @State private var selectedJobs: Set<UUID> = []
    @State private var showDeleteConfirmation: Bool = false

    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return appState.activeJobs
        }
        return appState.activeJobs.filter {
            $0.clientName.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isSelectionMode ? "Select Jobs" : "Active Jobs")
                            .font(.system(size: 32, weight: .bold))
                        Text(isSelectionMode ? "\(selectedJobs.count) selected" : "\(appState.activeJobs.count) jobs in progress • $\(Int(appState.totalActiveValue / 1000))K total value")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if !isSelectionMode {
                        Button(action: { enterSelectionMode() }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Select")
                            }
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Cancel") {
                            exitSelectionMode()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search jobs...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(10)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding(24)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Jobs List
            ScrollableContentView {
                if filteredJobs.isEmpty {
                    if searchText.isEmpty {
                        // No jobs at all
                        EnhancedEmptyState(
                            icon: "hammer.fill",
                            title: "No Active Jobs Yet",
                            message: "Start your first project and watch your business grow",
                            actionTitle: "Create Estimate",
                            action: {
                                appState.selectedItem = .newEstimate
                            },
                            tips: [
                                "Use ⌘N to quickly create estimates",
                                "Add photos to document your work",
                                "Track payments and remaining balances"
                            ]
                        )
                        .padding(.top, 60)
                    } else {
                        // Search returned no results
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Matching Jobs",
                            message: "Try adjusting your search terms"
                        )
                        .padding(.top, 60)
                    }
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredJobs) { job in
                            if isSelectionMode {
                                SelectableJobCard(
                                    job: job,
                                    isSelected: selectedJobs.contains(job.id),
                                    onToggle: { toggleJobSelection(job) }
                                )
                            } else {
                                JobCard(job: job)
                            }
                        }
                    }
                    .padding(24)
                }
            }

            // Bulk Action Bar
            if isSelectionMode && !selectedJobs.isEmpty {
                VStack(spacing: 0) {
                    Divider()

                    HStack(spacing: 16) {
                        Text("\(selectedJobs.count) selected")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Button(action: { markSelectedAsComplete() }) {
                            Label("Mark Complete", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(.bordered)

                        Button(action: { showDeleteConfirmation = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .alert("Delete Jobs", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteSelectedJobs()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedJobs.count) job(s)? This cannot be undone.")
        }
    }

    private func enterSelectionMode() {
        isSelectionMode = true
        selectedJobs.removeAll()
    }

    private func exitSelectionMode() {
        isSelectionMode = false
        selectedJobs.removeAll()
    }

    private func toggleJobSelection(_ job: Job) {
        if selectedJobs.contains(job.id) {
            selectedJobs.remove(job.id)
        } else {
            selectedJobs.insert(job.id)
        }
    }

    private func markSelectedAsComplete() {
        for jobId in selectedJobs {
            if let job = appState.jobs.first(where: { $0.id == jobId }) {
                var updatedJob = job
                updatedJob.isCompleted = true
                updatedJob.completionDate = Date()
                updatedJob.progress = 1.0
                appState.updateJob(updatedJob)
            }
        }

        appState.toastManager.show(
            message: "\(selectedJobs.count) job(s) marked complete",
            icon: "checkmark.circle.fill"
        )

        exitSelectionMode()
    }

    private func deleteSelectedJobs() {
        for jobId in selectedJobs {
            if let job = appState.jobs.first(where: { $0.id == jobId }) {
                appState.deleteJob(job)
            }
        }

        appState.toastManager.show(
            message: "\(selectedJobs.count) job(s) deleted",
            icon: "trash"
        )

        exitSelectionMode()
    }
}

struct SelectableJobCard: View {
    let job: Job
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }

                // Job Card
                JobCard(job: job)
            }
            .padding(4)
            .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActiveJobsView()
        .environment(AppState())
}
