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
                    EmptyStateView(
                        icon: searchText.isEmpty ? "hammer.fill" : "magnifyingglass",
                        title: searchText.isEmpty ? "No active jobs" : "No matching jobs",
                        message: searchText.isEmpty ? "Create a new estimate to get started" : "Try adjusting your search"
                    )
                    .padding(.top, 60)
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
