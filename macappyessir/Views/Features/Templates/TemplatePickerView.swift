//
//  TemplatePickerView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import SwiftUI

struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (JobTemplate) -> Void

    @State private var templates: [JobTemplate] = []
    @State private var selectedType: ContractorType = .kitchen
    @State private var searchText: String = ""

    var filteredTemplates: [JobTemplate] {
        let typeFiltered = templates.filter { $0.contractorType == selectedType }

        if searchText.isEmpty {
            return typeFiltered
        }

        return typeFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Job Templates")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Start with a pre-configured template")
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

            // Filters
            VStack(alignment: .leading, spacing: 12) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search templates...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(10)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)

                // Type Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ContractorType.allCases) { type in
                            TypeFilterChip(
                                type: type,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()

            // Templates List
            if filteredTemplates.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No Templates Found")
                        .font(.headline)

                    Text(searchText.isEmpty ? "No templates for this job type yet" : "Try adjusting your search")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredTemplates) { template in
                            TemplateCard(
                                template: template,
                                onSelect: {
                                    onSelect(template)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(24)
                }
            }

            Divider()

            // Footer
            HStack {
                Text("\(filteredTemplates.count) templates")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(24)
        }
        .frame(width: 700, height: 600)
        .onAppear {
            templates = TemplateManager.shared.loadTemplates()
        }
    }
}

struct TemplateCard: View {
    let template: JobTemplate
    let onSelect: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(template.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: template.contractorType.icon)
                                .font(.caption)
                            Text(template.contractorType.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(template.formattedCost)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)

                        Text("\(template.estimatedDays) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Cost Breakdown
                HStack(spacing: 16) {
                    Label("\(Int(template.materialsCost))", systemImage: "hammer.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(Int(template.laborCost))", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if isHovered {
                        HStack(spacing: 4) {
                            Text("Use Template")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(16)
            .background(isHovered ? Color.blue.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHovered ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct TypeFilterChip: View {
    let type: ContractorType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.caption)
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(nsColor: .controlBackgroundColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TemplatePickerView { template in
        print("Selected: \(template.name)")
    }
}
