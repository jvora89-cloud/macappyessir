//
//  CompletedJobsView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct CompletedJobsView: View {
    @Environment(AppState.self) private var appState
    @State private var filters = JobFilters()

    var filteredJobs: [Job] {
        appState.completedJobs.applyFilters(filters)
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

                // Filter Bar
                JobFilterBar(filters: filters, showProgressFilter: false)
            }
            .padding(24)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Jobs List
            ScrollableContentView {
                if filteredJobs.isEmpty {
                    if filters.searchText.isEmpty && !filters.hasActiveFilters {
                        // No completed jobs
                        EnhancedEmptyState(
                            icon: "checkmark.seal.fill",
                            title: "No Completed Jobs Yet",
                            message: "Finish your first job to start building your success story",
                            tips: [
                                "Mark jobs complete from the job detail page",
                                "Completed jobs show in your revenue statistics",
                                "Generate invoices to track final payments"
                            ]
                        )
                        .padding(.top, 60)
                    } else {
                        // Filters returned no results
                        VStack(spacing: 16) {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "No Matching Jobs",
                                message: "Try adjusting your filters"
                            )
                            Button("Clear All Filters") {
                                filters.clearAll()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 60)
                    }
                } else {
                    if filters.viewMode == .grid {
                        JobGridView(jobs: filteredJobs)
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
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    CompletedJobsView()
        .environment(AppState())
}
