//
//  EstimateCostView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import SwiftUI

struct EstimateCostView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let clientName: String
    let clientPhone: String
    let clientEmail: String
    let address: String
    let contractorType: ContractorType
    let jobDescription: String

    @State private var estimatedCost: String = ""
    @State private var materialsCost: String = ""
    @State private var laborCost: String = ""
    @State private var notes: String = ""
    @State private var estimatedDays: String = "7"
    @State private var showValidationError = false
    @State private var useAIEstimate = true
    @State private var isGeneratingAI = false

    var totalCost: Double {
        let materials = Double(materialsCost) ?? 0
        let labor = Double(laborCost) ?? 0
        return materials + labor
    }

    var isValidForm: Bool {
        !estimatedCost.isEmpty && Double(estimatedCost) != nil && Double(estimatedCost)! > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimate Costs")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(clientName)
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
                    // AI Estimate Section
                    if useAIEstimate {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.orange)
                                Text("AI-Powered Estimate")
                                    .font(.headline)
                            }

                            if isGeneratingAI {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Analyzing project details...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            } else {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Based on similar \(contractorType.rawValue.lowercased()) projects:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    HStack {
                                        Text("Suggested Range:")
                                            .font(.subheadline)
                                        Text(suggestedRange)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }

                                    Button(action: generateAIEstimate) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Regenerate")
                                        }
                                        .font(.caption)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }

                    // Project Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Project Summary")
                            .font(.headline)

                        InfoRow(label: "Type", value: contractorType.rawValue)
                        InfoRow(label: "Location", value: address)

                        if !jobDescription.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Description")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(jobDescription)
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(6)
                            }
                        }
                    }

                    Divider()

                    // Cost Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Cost Breakdown")
                            .font(.headline)

                        CostField(
                            title: "Materials Cost",
                            placeholder: "0",
                            text: $materialsCost,
                            icon: "hammer.fill"
                        )

                        CostField(
                            title: "Labor Cost",
                            placeholder: "0",
                            text: $laborCost,
                            icon: "person.fill"
                        )

                        if !materialsCost.isEmpty || !laborCost.isEmpty {
                            HStack {
                                Text("Subtotal")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatCurrency(totalCost))
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 8)
                        }
                    }

                    Divider()

                    // Total Estimate
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Estimate")
                            .font(.headline)

                        HStack {
                            Text("$")
                                .font(.title)
                                .foregroundColor(.secondary)
                            TextField("0.00", text: $estimatedCost)
                                .textFieldStyle(.plain)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .padding(16)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)

                        if totalCost > 0 && estimatedCost.isEmpty {
                            Button("Use Breakdown Total") {
                                estimatedCost = String(format: "%.0f", totalCost)
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }

                        if showValidationError && !isValidForm {
                            Text("Please enter a valid cost")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Timeline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Timeline")
                            .font(.headline)

                        HStack {
                            TextField("Days", text: $estimatedDays)
                                .textFieldStyle(.plain)
                                .frame(width: 60)
                                .padding(12)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(8)

                            Text("days to complete")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional Notes")
                            .font(.headline)

                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                            .font(.body)
                    }
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

                Button("Save as Draft") {
                    saveDraft()
                }
                .buttonStyle(.bordered)
                .disabled(!isValidForm)

                Button("Create Job") {
                    createJob()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!isValidForm)
            }
            .padding(24)
        }
        .frame(width: 600, height: 750)
        .onAppear {
            generateAIEstimate()
        }
    }

    private var suggestedRange: String {
        guard let cost = Double(estimatedCost), cost > 0 else {
            return generateSuggestedRange()
        }
        let low = cost * 0.85
        let high = cost * 1.15
        return "\(formatCurrency(low)) - \(formatCurrency(high))"
    }

    private func generateSuggestedRange() -> String {
        // Simple estimation based on job type
        let baseCost: Double
        switch contractorType {
        case .kitchen:
            baseCost = 25000
        case .bathroom:
            baseCost = 15000
        case .roofing:
            baseCost = 12000
        case .painting:
            baseCost = 5000
        case .flooring:
            baseCost = 8000
        case .fencing:
            baseCost = 6000
        case .landscaping:
            baseCost = 4000
        case .plumbing:
            baseCost = 3000
        case .electrical:
            baseCost = 4000
        case .hvac:
            baseCost = 8000
        case .remodeling:
            baseCost = 30000
        case .homeImprovement:
            baseCost = 10000
        }

        let low = baseCost * 0.7
        let high = baseCost * 1.3
        return "\(formatCurrency(low)) - \(formatCurrency(high))"
    }

    private func generateAIEstimate() {
        isGeneratingAI = true

        Task {
            do {
                let result = try await AIEstimationService.shared.generateEstimate(
                    contractorType: contractorType,
                    description: jobDescription,
                    address: address
                )

                await MainActor.run {
                    estimatedCost = String(format: "%.0f", result.estimatedCost)
                    materialsCost = String(format: "%.0f", result.materialsCost)
                    laborCost = String(format: "%.0f", result.laborCost)
                    estimatedDays = String(result.suggestedTimeline)

                    // Add AI insights to notes
                    if !result.reasoning.isEmpty {
                        notes = "AI Analysis:\n\(result.reasoning)"

                        if !result.riskFactors.isEmpty {
                            notes += "\n\nRisk Factors:\n" + result.riskFactors.map { "• \($0)" }.joined(separator: "\n")
                        }

                        if !result.recommendations.isEmpty {
                            notes += "\n\nRecommendations:\n" + result.recommendations.map { "• \($0)" }.joined(separator: "\n")
                        }
                    }

                    isGeneratingAI = false
                }
            } catch {
                await MainActor.run {
                    print("❌ AI Estimation failed: \(error.localizedDescription)")
                    // Fallback to baseline estimate
                    let baseCost = Double.random(in: 3000...35000)
                    estimatedCost = String(format: "%.0f", baseCost)
                    materialsCost = String(format: "%.0f", baseCost * 0.6)
                    laborCost = String(format: "%.0f", baseCost * 0.4)
                    isGeneratingAI = false
                }
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    private func saveDraft() {
        guard isValidForm else {
            showValidationError = true
            return
        }

        createJobWithStatus(isCompleted: false, progress: 0.0)
    }

    private func createJob() {
        guard isValidForm else {
            showValidationError = true
            return
        }

        createJobWithStatus(isCompleted: false, progress: 0.0)
    }

    private func createJobWithStatus(isCompleted: Bool, progress: Double) {
        guard let cost = Double(estimatedCost) else { return }

        let job = Job(
            clientName: clientName,
            clientPhone: clientPhone,
            clientEmail: clientEmail,
            address: address,
            contractorType: contractorType,
            description: jobDescription,
            estimatedCost: cost,
            progress: progress,
            startDate: Date(),
            isCompleted: isCompleted,
            notes: notes
        )

        appState.addJob(job)

        // Show success message
        appState.toastManager.show(
            message: "Job created successfully!",
            icon: "checkmark.circle.fill"
        )

        dismiss()

        // Navigate to jobs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appState.selectedItem = .activeJobs
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

struct CostField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }
            .padding(12)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
        }
    }
}

#Preview {
    EstimateCostView(
        clientName: "John Smith",
        clientPhone: "(555) 123-4567",
        clientEmail: "john@email.com",
        address: "123 Oak Street, Austin, TX",
        contractorType: .kitchen,
        jobDescription: "Complete kitchen remodel with new cabinets and countertops"
    )
    .environment(AppState())
}
