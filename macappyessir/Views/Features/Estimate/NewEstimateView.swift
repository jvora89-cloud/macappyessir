//
//  NewEstimateView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct NewEstimateView: View {
    @Environment(AppState.self) private var appState
    @State private var useWizard: Bool = true

    var body: some View {
        if useWizard {
            NewEstimateWizard()
        } else {
            legacyView
        }
    }

    // Legacy view (kept for reference)
    private var legacyView: some View {
        LegacyNewEstimateView()
    }
}

// MARK: - Legacy View (Original Implementation)

struct LegacyNewEstimateView: View {
    @Environment(AppState.self) private var appState
    @State private var clientName: String = ""
    @State private var clientPhone: String = ""
    @State private var clientEmail: String = ""
    @State private var address: String = ""
    @State private var selectedType: ContractorType = .homeImprovement
    @State private var jobDescription: String = ""
    @State private var showCamera: Bool = false
    @State private var showEstimateCost: Bool = false
    @State private var showValidation: Bool = false
    @State private var showTemplatePicker: Bool = false

    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 12)
    ]

    var isValidForm: Bool {
        !clientName.isEmpty && !address.isEmpty && !jobDescription.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Estimate")
                            .font(.system(size: 32, weight: .bold))
                        Text("Use AI camera or enter details manually")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { showTemplatePicker = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill.badge.plus")
                            Text("Use Template")
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // AI Camera Section
                Button(action: { showCamera = true }) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.2), .blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 8) {
                            Text("Use AI Camera")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Take photos of the project site and let AI generate an estimate")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Button("Open Camera") {}
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                // Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    Text("OR ENTER MANUALLY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)

                // Manual Entry Form
                VStack(alignment: .leading, spacing: 20) {
                    Text("Client Information")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)

                    VStack(spacing: 16) {
                        FormField(title: "Client Name", placeholder: "John Smith", text: $clientName)
                        FormField(title: "Phone", placeholder: "(555) 123-4567", text: $clientPhone)
                        FormField(title: "Email", placeholder: "client@email.com", text: $clientEmail)
                        FormField(title: "Job Address", placeholder: "123 Main St, City, State", text: $address)
                    }
                    .padding(.horizontal, 24)

                    Text("Job Type")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ContractorType.allCases) { type in
                            ContractorTypeCard(
                                type: type,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Text("Job Description")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    TextEditor(text: $jobDescription)
                        .font(.body)
                        .frame(height: 120)
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 24)
                }

                // Validation Message
                if showValidation && !isValidForm {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Please fill in client name, address, and job description")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    Button("Continue to Pricing") {
                        if isValidForm {
                            showEstimateCost = true
                        } else {
                            showValidation = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Clear Form") {
                        clearForm()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showCamera) {
            WorkingCameraView(isPresented: $showCamera)
        }
        .sheet(isPresented: $showEstimateCost) {
            EstimateCostView(
                clientName: clientName,
                clientPhone: clientPhone,
                clientEmail: clientEmail,
                address: address,
                contractorType: selectedType,
                jobDescription: jobDescription
            )
        }
        .sheet(isPresented: $showTemplatePicker) {
            TemplatePickerView { template in
                applyTemplate(template)
            }
        }
    }

    private func applyTemplate(_ template: JobTemplate) {
        selectedType = template.contractorType
        jobDescription = template.description
        appState.toastManager.show(
            message: "Template applied: \(template.name)",
            icon: "doc.text.fill"
        )
    }

    private func clearForm() {
        clientName = ""
        clientPhone = ""
        clientEmail = ""
        address = ""
        selectedType = .homeImprovement
        jobDescription = ""
        showValidation = false
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
        }
    }
}

struct ContractorTypeCard: View {
    let type: ContractorType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : typeColor)

                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .padding(.vertical, 12)
            .background(isSelected ? typeColor : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var typeColor: Color {
        switch type {
        case .homeImprovement, .plumbing: return .blue
        case .fencing: return .brown
        case .remodeling: return .orange
        case .kitchen: return .purple
        case .bathroom: return .cyan
        case .painting: return .pink
        case .flooring: return .gray
        case .roofing: return .red
        case .landscaping: return .green
        case .electrical: return .yellow
        case .hvac: return .teal
        }
    }
}


#Preview {
    NewEstimateView()
}
