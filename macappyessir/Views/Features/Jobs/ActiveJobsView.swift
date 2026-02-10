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
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Jobs")
                        .font(.system(size: 32, weight: .bold))
                    Text("\(appState.activeJobs.count) jobs in progress • $\(Int(appState.totalActiveValue / 1000))K total value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                            JobCard(job: job)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    ActiveJobsView()
        .environment(AppState())
}
