//
//  JobFilteringSystem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Advanced filtering and sorting for jobs list
//

import SwiftUI

// MARK: - Filter Models

enum JobSortOption: String, CaseIterable, Identifiable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case costHighest = "Cost (Highest)"
    case costLowest = "Cost (Lowest)"
    case progressHighest = "Progress (Highest)"
    case progressLowest = "Progress (Lowest)"
    case clientAZ = "Client (A-Z)"
    case clientZA = "Client (Z-A)"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dateNewest, .dateOldest: return "calendar"
        case .costHighest, .costLowest: return "dollarsign.circle"
        case .progressHighest, .progressLowest: return "chart.bar"
        case .clientAZ, .clientZA: return "person"
        }
    }
}

enum JobViewMode: String, CaseIterable {
    case list = "List"
    case grid = "Grid"

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

@Observable
class JobFilters {
    // Search
    var searchText: String = ""

    // Type filter
    var selectedTypes: Set<ContractorType> = []

    // Cost range
    var minCost: Double? = nil
    var maxCost: Double? = nil

    // Date range
    var startDate: Date? = nil
    var endDate: Date? = nil

    // Progress range (for active jobs)
    var minProgress: Double? = nil
    var maxProgress: Double? = nil

    // Sort
    var sortOption: JobSortOption = .dateNewest

    // View mode
    var viewMode: JobViewMode = .list

    // Advanced mode
    var showAdvancedFilters: Bool = false

    var hasActiveFilters: Bool {
        !searchText.isEmpty ||
        !selectedTypes.isEmpty ||
        minCost != nil ||
        maxCost != nil ||
        startDate != nil ||
        endDate != nil ||
        minProgress != nil ||
        maxProgress != nil
    }

    func clearAll() {
        searchText = ""
        selectedTypes.removeAll()
        minCost = nil
        maxCost = nil
        startDate = nil
        endDate = nil
        minProgress = nil
        maxProgress = nil
        sortOption = .dateNewest
    }

    func applyPreset(_ preset: FilterPreset) {
        clearAll()
        selectedTypes = preset.types
        minCost = preset.minCost
        maxCost = preset.maxCost
        minProgress = preset.minProgress
        maxProgress = preset.maxProgress
    }
}

struct FilterPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var types: Set<ContractorType>
    var minCost: Double?
    var maxCost: Double?
    var minProgress: Double?
    var maxProgress: Double?

    init(
        id: UUID = UUID(),
        name: String,
        types: Set<ContractorType> = [],
        minCost: Double? = nil,
        maxCost: Double? = nil,
        minProgress: Double? = nil,
        maxProgress: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.types = types
        self.minCost = minCost
        self.maxCost = maxCost
        self.minProgress = minProgress
        self.maxProgress = maxProgress
    }

    static let commonPresets: [FilterPreset] = [
        FilterPreset(name: "High Value", minCost: 20000),
        FilterPreset(name: "Kitchen & Bath", types: [.kitchen, .bathroom]),
        FilterPreset(name: "Nearly Done", minProgress: 0.75),
        FilterPreset(name: "Just Started", maxProgress: 0.25),
        FilterPreset(name: "Small Jobs", maxCost: 5000)
    ]
}

// MARK: - Job Filtering Extension

extension Array where Element == Job {
    func applyFilters(_ filters: JobFilters) -> [Job] {
        var result = self

        // Search
        if !filters.searchText.isEmpty {
            result = result.filter { job in
                job.clientName.localizedCaseInsensitiveContains(filters.searchText) ||
                job.address.localizedCaseInsensitiveContains(filters.searchText) ||
                job.description.localizedCaseInsensitiveContains(filters.searchText) ||
                job.contractorType.rawValue.localizedCaseInsensitiveContains(filters.searchText)
            }
        }

        // Type filter
        if !filters.selectedTypes.isEmpty {
            result = result.filter { filters.selectedTypes.contains($0.contractorType) }
        }

        // Cost range
        if let minCost = filters.minCost {
            result = result.filter { $0.estimatedCost >= minCost }
        }
        if let maxCost = filters.maxCost {
            result = result.filter { $0.estimatedCost <= maxCost }
        }

        // Date range
        if let startDate = filters.startDate {
            result = result.filter { $0.startDate >= startDate }
        }
        if let endDate = filters.endDate {
            result = result.filter { $0.startDate <= endDate }
        }

        // Progress range (for active jobs)
        if let minProgress = filters.minProgress {
            result = result.filter { $0.progress >= minProgress }
        }
        if let maxProgress = filters.maxProgress {
            result = result.filter { $0.progress <= maxProgress }
        }

        // Sort
        result = result.sorted(using: filters.sortOption)

        return result
    }

    func sorted(using option: JobSortOption) -> [Job] {
        switch option {
        case .dateNewest:
            return sorted { $0.startDate > $1.startDate }
        case .dateOldest:
            return sorted { $0.startDate < $1.startDate }
        case .costHighest:
            return sorted { $0.estimatedCost > $1.estimatedCost }
        case .costLowest:
            return sorted { $0.estimatedCost < $1.estimatedCost }
        case .progressHighest:
            return sorted { $0.progress > $1.progress }
        case .progressLowest:
            return sorted { $0.progress < $1.progress }
        case .clientAZ:
            return sorted { $0.clientName < $1.clientName }
        case .clientZA:
            return sorted { $0.clientName > $1.clientName }
        }
    }
}

// MARK: - Filter Bar UI

struct JobFilterBar: View {
    @Bindable var filters: JobFilters
    let showProgressFilter: Bool // For active jobs only

    var body: some View {
        VStack(spacing: 12) {
            // Search and controls
            HStack(spacing: 12) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search jobs...", text: $filters.searchText)
                        .textFieldStyle(.plain)

                    if !filters.searchText.isEmpty {
                        Button(action: { filters.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)

                // Sort menu
                Menu {
                    ForEach(JobSortOption.allCases) { option in
                        Button(action: { filters.sortOption = option }) {
                            HStack {
                                Image(systemName: option.icon)
                                Text(option.rawValue)
                                if filters.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                // View mode toggle
                HStack(spacing: 4) {
                    ForEach(JobViewMode.allCases, id: \.self) { mode in
                        Button(action: { filters.viewMode = mode }) {
                            Image(systemName: mode.icon)
                                .padding(8)
                                .background(filters.viewMode == mode ? Color.blue : Color.clear)
                                .foregroundColor(filters.viewMode == mode ? .white : .primary)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(2)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)

                // Advanced filters toggle
                Button(action: { filters.showAdvancedFilters.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: filters.showAdvancedFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        Text("Filters")
                        if filters.hasActiveFilters {
                            Text("(\(activeFilterCount))")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(filters.showAdvancedFilters ? Color.blue.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            // Quick filter chips
            if !filters.showAdvancedFilters && filters.hasActiveFilters {
                quickFilterChips
            }

            // Advanced filters panel
            if filters.showAdvancedFilters {
                advancedFiltersPanel
            }
        }
    }

    private var quickFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Active filter chips
                ForEach(Array(filters.selectedTypes), id: \.self) { type in
                    filterChip(
                        icon: type.icon,
                        text: type.rawValue,
                        color: .blue,
                        onRemove: { filters.selectedTypes.remove(type) }
                    )
                }

                if filters.minCost != nil || filters.maxCost != nil {
                    filterChip(
                        icon: "dollarsign.circle",
                        text: costRangeText,
                        color: .green,
                        onRemove: {
                            filters.minCost = nil
                            filters.maxCost = nil
                        }
                    )
                }

                if showProgressFilter && (filters.minProgress != nil || filters.maxProgress != nil) {
                    filterChip(
                        icon: "chart.bar",
                        text: progressRangeText,
                        color: .orange,
                        onRemove: {
                            filters.minProgress = nil
                            filters.maxProgress = nil
                        }
                    )
                }

                if filters.startDate != nil || filters.endDate != nil {
                    filterChip(
                        icon: "calendar",
                        text: dateRangeText,
                        color: .purple,
                        onRemove: {
                            filters.startDate = nil
                            filters.endDate = nil
                        }
                    )
                }

                // Clear all
                Button(action: { filters.clearAll() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("Clear All")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
    }

    private func filterChip(icon: String, text: String, color: Color, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }

    private var advancedFiltersPanel: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Advanced Filters")
                    .font(.headline)
                Spacer()
                Button("Clear All") {
                    filters.clearAll()
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }

            // Quick presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Presets")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterPreset.commonPresets) { preset in
                            Button(action: { filters.applyPreset(preset) }) {
                                Text(preset.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Divider()

            // Job Type
            VStack(alignment: .leading, spacing: 8) {
                Text("Job Type")
                    .font(.subheadline)
                    .fontWeight(.medium)

                let columns = [
                    GridItem(.adaptive(minimum: 100), spacing: 8)
                ]

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(ContractorType.allCases) { type in
                        typeFilterButton(type: type)
                    }
                }
            }

            // Cost Range
            VStack(alignment: .leading, spacing: 8) {
                Text("Cost Range")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("$")
                            TextField("0", value: $filters.minCost, format: .number)
                                .textFieldStyle(.plain)
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("$")
                            TextField("∞", value: $filters.maxCost, format: .number)
                                .textFieldStyle(.plain)
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                    }
                }
            }

            // Progress Range (for active jobs)
            if showProgressFilter {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Progress Range")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Min %")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("0", value: Binding(
                                get: { filters.minProgress.map { $0 * 100 } },
                                set: { filters.minProgress = $0.map { $0 / 100 } }
                            ), format: .number)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(6)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Max %")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("100", value: Binding(
                                get: { filters.maxProgress.map { $0 * 100 } },
                                set: { filters.maxProgress = $0.map { $0 / 100 } }
                            ), format: .number)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                }
            }

            // Date Range
            VStack(alignment: .leading, spacing: 8) {
                Text("Date Range")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    DatePicker("Start", selection: Binding(
                        get: { filters.startDate ?? Date.distantPast },
                        set: { filters.startDate = $0 }
                    ), displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)

                    Text("to")
                        .foregroundColor(.secondary)

                    DatePicker("End", selection: Binding(
                        get: { filters.endDate ?? Date() },
                        set: { filters.endDate = $0 }
                    ), displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
    }

    private func typeFilterButton(type: ContractorType) -> some View {
        Button(action: {
            if filters.selectedTypes.contains(type) {
                filters.selectedTypes.remove(type)
            } else {
                filters.selectedTypes.insert(type)
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.caption)
                Text(type.rawValue)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(filters.selectedTypes.contains(type) ? Color.blue : Color(nsColor: .controlBackgroundColor))
            .foregroundColor(filters.selectedTypes.contains(type) ? .white : .primary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var activeFilterCount: Int {
        var count = 0
        if !filters.selectedTypes.isEmpty { count += 1 }
        if filters.minCost != nil || filters.maxCost != nil { count += 1 }
        if filters.minProgress != nil || filters.maxProgress != nil { count += 1 }
        if filters.startDate != nil || filters.endDate != nil { count += 1 }
        return count
    }

    private var costRangeText: String {
        if let min = filters.minCost, let max = filters.maxCost {
            return "$\(Int(min))-$\(Int(max))"
        } else if let min = filters.minCost {
            return "$\(Int(min))+"
        } else if let max = filters.maxCost {
            return "Up to $\(Int(max))"
        }
        return "Cost"
    }

    private var progressRangeText: String {
        if let min = filters.minProgress, let max = filters.maxProgress {
            return "\(Int(min * 100))-\(Int(max * 100))%"
        } else if let min = filters.minProgress {
            return "\(Int(min * 100))%+"
        } else if let max = filters.maxProgress {
            return "Up to \(Int(max * 100))%"
        }
        return "Progress"
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        if let start = filters.startDate, let end = filters.endDate {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else if let start = filters.startDate {
            return "After \(formatter.string(from: start))"
        } else if let end = filters.endDate {
            return "Before \(formatter.string(from: end))"
        }
        return "Date"
    }
}

// MARK: - Grid View

struct JobGridView: View {
    let jobs: [Job]

    let columns = [
        GridItem(.adaptive(minimum: 280), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(jobs) { job in
                JobCard(job: job)
            }
        }
        .padding(24)
    }
}

#Preview {
    VStack {
        JobFilterBar(filters: JobFilters(), showProgressFilter: true)
    }
    .padding()
}
