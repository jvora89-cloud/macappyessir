//
//  CompletedJobsView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct CompletedJobsView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText: String = ""

    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return appState.completedJobs
        }
        return appState.completedJobs.filter {
            $0.clientName.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Completed Jobs")
                        .font(.system(size: 32, weight: .bold))
                    HStack(spacing: 12) {
                        Text("\(appState.completedJobs.count) completed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("$\(Int(appState.totalRevenue / 1000))K revenue")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search completed jobs...", text: $searchText)
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
                        icon: searchText.isEmpty ? "checkmark.seal.fill" : "magnifyingglass",
                        title: searchText.isEmpty ? "No completed jobs yet" : "No matching jobs",
                        message: searchText.isEmpty ? "Completed jobs will appear here" : "Try adjusting your search"
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
    CompletedJobsView()
        .environment(AppState())
}
