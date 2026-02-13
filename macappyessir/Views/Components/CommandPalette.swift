//
//  CommandPalette.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Global search and command palette (⌘K)
//

import SwiftUI

struct CommandPalette: View {
    @Environment(AppState.self) private var appState
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Palette
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search jobs, clients, or type a command...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .focused($isSearchFocused)
                        .onSubmit {
                            executeSelected()
                        }

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor))

                Divider()

                // Results
                ScrollView {
                    if searchText.isEmpty {
                        quickActionsView
                    } else {
                        searchResultsView
                    }
                }
                .frame(maxHeight: 400)

                // Footer
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption2)
                        Text("Navigate")
                            .font(.caption)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "return")
                            .font(.caption2)
                        Text("Select")
                            .font(.caption)
                    }

                    HStack(spacing: 4) {
                        Text("esc")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(4)
                        Text("Close")
                            .font(.caption)
                    }

                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            }
            .frame(width: 600)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 30, y: 10)
        }
        .onAppear {
            isSearchFocused = true
        }
        .onKeyPress(.escape) {
            isPresented = false
            return .handled
        }
        .onKeyPress(.upArrow) {
            selectedIndex = max(0, selectedIndex - 1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            selectedIndex = min(filteredResults.count - 1, selectedIndex + 1)
            return .handled
        }
    }

    // MARK: - Quick Actions

    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Quick Actions")

            CommandItem(
                icon: "plus.circle.fill",
                title: "New Estimate",
                subtitle: "Create a new job estimate",
                shortcut: "⌘N",
                color: .orange,
                isSelected: selectedIndex == 0
            ) {
                appState.selectedItem = .newEstimate
                isPresented = false
            }
            .tag(0)

            CommandItem(
                icon: "chart.bar.fill",
                title: "View Dashboard",
                subtitle: "See business overview",
                shortcut: "⌘1",
                color: .blue,
                isSelected: selectedIndex == 1
            ) {
                appState.selectedItem = .dashboard
                isPresented = false
            }
            .tag(1)

            CommandItem(
                icon: "hammer.fill",
                title: "Active Jobs",
                subtitle: "View jobs in progress",
                shortcut: "⌘3",
                color: .orange,
                isSelected: selectedIndex == 2
            ) {
                appState.selectedItem = .activeJobs
                isPresented = false
            }
            .tag(2)

            CommandItem(
                icon: "checkmark.seal.fill",
                title: "Completed Jobs",
                subtitle: "View finished jobs",
                shortcut: "⌘4",
                color: .green,
                isSelected: selectedIndex == 3
            ) {
                appState.selectedItem = .completed
                isPresented = false
            }
            .tag(3)

            Divider()
                .padding(.vertical, 8)

            sectionHeader("Recent Jobs")

            ForEach(Array(appState.activeJobs.prefix(3).enumerated()), id: \.element.id) { index, job in
                CommandItem(
                    icon: "doc.text.fill",
                    title: job.clientName,
                    subtitle: "\(job.contractorType.rawValue) • \(job.formattedEstimate)",
                    color: .blue,
                    isSelected: selectedIndex == 4 + index
                ) {
                    // Navigate to job detail
                    isPresented = false
                }
                .tag(4 + index)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Search Results

    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if filteredResults.isEmpty {
                emptySearchView
            } else {
                ForEach(Array(filteredResults.enumerated()), id: \.element.id) { index, result in
                    CommandItem(
                        icon: result.icon,
                        title: result.title,
                        subtitle: result.subtitle,
                        color: result.color,
                        isSelected: selectedIndex == index
                    ) {
                        result.action()
                        isPresented = false
                    }
                    .tag(index)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var emptySearchView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No results found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Try different keywords or commands")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
    }

    // MARK: - Search Logic

    private var filteredResults: [SearchResult] {
        guard !searchText.isEmpty else { return [] }

        var results: [SearchResult] = []
        let query = searchText.lowercased()

        // Search actions
        if "new estimate".contains(query) || "create".contains(query) {
            results.append(SearchResult(
                icon: "plus.circle.fill",
                title: "New Estimate",
                subtitle: "Create a new job estimate",
                color: .orange,
                action: { appState.selectedItem = .newEstimate }
            ))
        }

        if "settings".contains(query) || "preferences".contains(query) {
            results.append(SearchResult(
                icon: "gear",
                title: "Settings",
                subtitle: "App preferences and configuration",
                color: .gray,
                action: { appState.selectedItem = .settings }
            ))
        }

        // Search jobs
        let matchingJobs = appState.activeJobs.filter { job in
            job.clientName.lowercased().contains(query) ||
            job.address.lowercased().contains(query) ||
            job.contractorType.rawValue.lowercased().contains(query) ||
            job.description.lowercased().contains(query)
        }

        results.append(contentsOf: matchingJobs.map { job in
            SearchResult(
                icon: "doc.text.fill",
                title: job.clientName,
                subtitle: "\(job.contractorType.rawValue) • \(job.address)",
                color: .blue,
                action: {
                    // Navigate to job detail
                    appState.selectedItem = .activeJobs
                }
            )
        })

        // Search completed jobs
        let matchingCompleted = appState.completedJobs.filter { job in
            job.clientName.lowercased().contains(query) ||
            job.address.lowercased().contains(query)
        }

        results.append(contentsOf: matchingCompleted.prefix(5).map { job in
            SearchResult(
                icon: "checkmark.seal.fill",
                title: job.clientName,
                subtitle: "\(job.contractorType.rawValue) • Completed",
                color: .green,
                action: {
                    appState.selectedItem = .completed
                }
            )
        })

        return results
    }

    private func executeSelected() {
        guard selectedIndex < filteredResults.count else { return }
        filteredResults[selectedIndex].action()
        isPresented = false
    }
}

// MARK: - Command Item

struct CommandItem: View {
    let icon: String
    let title: String
    let subtitle: String
    var shortcut: String? = nil
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Result

struct SearchResult: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
}

#Preview {
    CommandPalette(isPresented: .constant(true))
        .environment(AppState())
}
