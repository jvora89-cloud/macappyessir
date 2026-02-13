//
//  NewEstimateWizard.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Multi-step wizard for creating estimates
//

import SwiftUI

// MARK: - Wizard Step Enum

enum EstimateWizardStep: Int, CaseIterable {
    case method = 0
    case client = 1
    case jobDetails = 2
    case pricing = 3
    case review = 4

    var title: String {
        switch self {
        case .method: return "Choose Method"
        case .client: return "Client Info"
        case .jobDetails: return "Job Details"
        case .pricing: return "Pricing"
        case .review: return "Review"
        }
    }

    var icon: String {
        switch self {
        case .method: return "square.grid.2x2"
        case .client: return "person.fill"
        case .jobDetails: return "doc.text.fill"
        case .pricing: return "dollarsign.circle.fill"
        case .review: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Creation Method

enum EstimateCreationMethod {
    case aiCamera
    case template
    case manual
}

// MARK: - Draft System

struct EstimateDraft: Codable {
    var clientName: String = ""
    var clientPhone: String = ""
    var clientEmail: String = ""
    var address: String = ""
    var contractorType: ContractorType = .homeImprovement
    var jobDescription: String = ""
    var estimatedCost: Double = 0
    var laborCost: Double = 0
    var materialCost: Double = 0
    var notes: String = ""
    var lastModified: Date = Date()
}

// MARK: - Main Wizard View

struct NewEstimateWizard: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep: EstimateWizardStep = .method
    @State private var creationMethod: EstimateCreationMethod = .manual
    @State private var draft = EstimateDraft()
    @State private var showCamera = false
    @State private var showTemplatePicker = false
    @State private var autoSaveTimer: Timer?

    // Suggestions from existing jobs
    @State private var clientSuggestions: [String] = []
    @State private var addressSuggestions: [String] = []
    @State private var showClientSuggestions = false
    @State private var showAddressSuggestions = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with progress
            wizardHeader

            Divider()

            // Step content
            ScrollView {
                stepContent
                    .padding(32)
            }

            Divider()

            // Navigation buttons
            navigationButtons
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            loadSuggestions()
            startAutoSave()
        }
        .onDisappear {
            autoSaveTimer?.invalidate()
        }
        .sheet(isPresented: $showCamera) {
            WorkingCameraView(isPresented: $showCamera)
        }
        .sheet(isPresented: $showTemplatePicker) {
            TemplatePickerView { template in
                applyTemplate(template)
            }
        }
    }

    // MARK: - Header

    private var wizardHeader: some View {
        VStack(spacing: 16) {
            Text("New Estimate Wizard")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Progress indicator
            HStack(spacing: 12) {
                ForEach(EstimateWizardStep.allCases, id: \.self) { step in
                    stepIndicator(for: step)

                    if step != .review {
                        Rectangle()
                            .fill(step.rawValue < currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(24)
    }

    private func stepIndicator(for step: EstimateWizardStep) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(stepColor(for: step))
                    .frame(width: 40, height: 40)

                if step.rawValue < currentStep.rawValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: step.icon)
                        .font(.system(size: 16))
                        .foregroundColor(step == currentStep ? .white : .gray)
                }
            }

            Text(step.title)
                .font(.caption)
                .fontWeight(step == currentStep ? .semibold : .regular)
                .foregroundColor(step == currentStep ? .primary : .secondary)
        }
    }

    private func stepColor(for step: EstimateWizardStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return .green
        } else if step == currentStep {
            return .blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .method:
            methodStep
        case .client:
            clientStep
        case .jobDetails:
            jobDetailsStep
        case .pricing:
            pricingStep
        case .review:
            reviewStep
        }
    }

    // MARK: - Step 1: Method Selection

    private var methodStep: some View {
        VStack(spacing: 32) {
            Text("How would you like to create this estimate?")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                methodCard(
                    icon: "camera.fill",
                    title: "AI Camera",
                    description: "Take photos and let AI generate the estimate",
                    gradient: [.orange, .blue],
                    method: .aiCamera
                )

                methodCard(
                    icon: "doc.text.fill",
                    title: "Use Template",
                    description: "Start from a pre-made template",
                    gradient: [.purple, .pink],
                    method: .template
                )

                methodCard(
                    icon: "pencil.circle.fill",
                    title: "Manual Entry",
                    description: "Enter all details manually",
                    gradient: [.green, .blue],
                    method: .manual
                )
            }
        }
    }

    private func methodCard(icon: String, title: String, description: String, gradient: [Color], method: EstimateCreationMethod) -> some View {
        Button(action: {
            creationMethod = method
            if method == .aiCamera {
                showCamera = true
            } else if method == .template {
                showTemplatePicker = true
            }
        }) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(creationMethod == method ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: Client Information

    private var clientStep: some View {
        VStack(spacing: 24) {
            Text("Client Information")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Enter the client's contact information")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 20) {
                // Client Name with autocomplete
                VStack(alignment: .leading, spacing: 8) {
                    Text("Client Name *")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextField("John Smith", text: $draft.clientName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .onChange(of: draft.clientName) { _, newValue in
                            updateClientSuggestions(query: newValue)
                        }

                    if showClientSuggestions && !clientSuggestions.isEmpty {
                        suggestionsList(suggestions: clientSuggestions) { suggestion in
                            draft.clientName = suggestion
                            showClientSuggestions = false
                        }
                    }
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("(555) 123-4567", text: $draft.clientPhone)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("client@email.com", text: $draft.clientEmail)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                    }
                }

                // Address with autocomplete
                VStack(alignment: .leading, spacing: 8) {
                    Text("Job Address *")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextField("123 Main St, City, State", text: $draft.address)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .onChange(of: draft.address) { _, newValue in
                            updateAddressSuggestions(query: newValue)
                        }

                    if showAddressSuggestions && !addressSuggestions.isEmpty {
                        suggestionsList(suggestions: addressSuggestions) { suggestion in
                            draft.address = suggestion
                            showAddressSuggestions = false
                        }
                    }
                }
            }

            // Validation helper
            if !draft.clientName.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Required fields completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func suggestionsList(suggestions: [String], onSelect: @escaping (String) -> Void) -> some View {
        VStack(spacing: 0) {
            ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                Button(action: { onSelect(suggestion) }) {
                    HStack {
                        Text(suggestion)
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.turn.down.left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(Color(nsColor: .controlBackgroundColor))

                if suggestion != suggestions.prefix(5).last {
                    Divider()
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Step 3: Job Details

    private var jobDetailsStep: some View {
        VStack(spacing: 24) {
            Text("Job Details")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Describe the work to be done")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 20) {
                // Job Type
                VStack(alignment: .leading, spacing: 12) {
                    Text("Job Type *")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    let columns = [
                        GridItem(.adaptive(minimum: 120), spacing: 12)
                    ]

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ContractorType.allCases) { type in
                            jobTypeCard(type: type)
                        }
                    }
                }

                // Job Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Job Description *")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Describe the scope of work, materials needed, and timeline")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $draft.jobDescription)
                        .font(.body)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .scrollContentBackground(.hidden)
                }

                // Smart suggestions based on job type
                if !draft.jobDescription.isEmpty {
                    smartSuggestionsCard
                }
            }
        }
    }

    private func jobTypeCard(type: ContractorType) -> some View {
        Button(action: { draft.contractorType = type }) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(draft.contractorType == type ? .white : typeColor(for: type))

                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(draft.contractorType == type ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.vertical, 8)
            .background(draft.contractorType == type ? typeColor(for: type) : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private func typeColor(for type: ContractorType) -> Color {
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

    private var smartSuggestionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Smart Suggestions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("Based on similar \(draft.contractorType.rawValue) jobs:")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                suggestionChip(text: "Include permits and inspection fees")
                suggestionChip(text: "Plan for 10-15% contingency")
                suggestionChip(text: "Specify warranty period")
            }
        }
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }

    private func suggestionChip(text: String) -> some View {
        HStack {
            Text("•")
                .foregroundColor(.blue)
            Text(text)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Step 4: Pricing

    private var pricingStep: some View {
        VStack(spacing: 24) {
            Text("Estimate Pricing")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Break down the costs for this job")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 20) {
                // Labor Cost
                VStack(alignment: .leading, spacing: 8) {
                    Text("Labor Cost")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", value: $draft.laborCost, format: .number)
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }

                // Material Cost
                VStack(alignment: .leading, spacing: 8) {
                    Text("Material Cost")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", value: $draft.materialCost, format: .number)
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }

                Divider()

                // Total
                HStack {
                    Text("Total Estimate")
                        .font(.headline)
                    Spacer()
                    Text(formatCurrency(draft.laborCost + draft.materialCost))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding(16)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                // Quick calculator
                calculatorCard

                // Additional notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Notes")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextEditor(text: $draft.notes)
                        .font(.body)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .scrollContentBackground(.hidden)
                }
            }
        }
        .onChange(of: draft.laborCost) { _, _ in
            draft.estimatedCost = draft.laborCost + draft.materialCost
        }
        .onChange(of: draft.materialCost) { _, _ in
            draft.estimatedCost = draft.laborCost + draft.materialCost
        }
    }

    private var calculatorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calculator.fill")
                    .foregroundColor(.green)
                Text("Quick Calculator")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            HStack(spacing: 12) {
                quickCalcButton(label: "+10%", multiplier: 1.1)
                quickCalcButton(label: "+15%", multiplier: 1.15)
                quickCalcButton(label: "+20%", multiplier: 1.2)
                quickCalcButton(label: "Round Up", multiplier: nil)
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }

    private func quickCalcButton(label: String, multiplier: Double?) -> some View {
        Button(action: {
            if let mult = multiplier {
                let total = draft.laborCost + draft.materialCost
                let newTotal = total * mult
                let difference = newTotal - total
                // Split difference proportionally
                draft.laborCost += difference * (draft.laborCost / total)
                draft.materialCost += difference * (draft.materialCost / total)
            } else {
                // Round up to nearest 100
                let total = draft.laborCost + draft.materialCost
                let rounded = ceil(total / 100) * 100
                let difference = rounded - total
                draft.laborCost += difference / 2
                draft.materialCost += difference / 2
            }
        }) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 5: Review

    private var reviewStep: some View {
        VStack(spacing: 24) {
            Text("Review Estimate")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Review all details before creating the estimate")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                reviewSection(title: "Client", icon: "person.fill", color: .blue) {
                    reviewRow(label: "Name", value: draft.clientName)
                    if !draft.clientPhone.isEmpty {
                        reviewRow(label: "Phone", value: draft.clientPhone)
                    }
                    if !draft.clientEmail.isEmpty {
                        reviewRow(label: "Email", value: draft.clientEmail)
                    }
                    reviewRow(label: "Address", value: draft.address)
                }

                reviewSection(title: "Job Details", icon: "doc.text.fill", color: .orange) {
                    reviewRow(label: "Type", value: draft.contractorType.rawValue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(draft.jobDescription)
                            .font(.body)
                    }
                }

                reviewSection(title: "Pricing", icon: "dollarsign.circle.fill", color: .green) {
                    reviewRow(label: "Labor", value: formatCurrency(draft.laborCost))
                    reviewRow(label: "Materials", value: formatCurrency(draft.materialCost))
                    Divider()
                    HStack {
                        Text("Total Estimate")
                            .font(.headline)
                        Spacer()
                        Text(formatCurrency(draft.estimatedCost))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }

    private func reviewSection<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Spacer()
                Button(action: { goToRelevantStep(for: title) }) {
                    Text("Edit")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            content()
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
    }

    private func goToRelevantStep(for section: String) {
        switch section {
        case "Client":
            currentStep = .client
        case "Job Details":
            currentStep = .jobDetails
        case "Pricing":
            currentStep = .pricing
        default:
            break
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Cancel
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .keyboardShortcut(.cancelAction)

            Spacer()

            // Back
            if currentStep != .method {
                Button(action: goToPreviousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("[", modifiers: .command)
            }

            // Next/Finish
            Button(action: goToNextStep) {
                HStack {
                    Text(currentStep == .review ? "Create Estimate" : "Next")
                    if currentStep != .review {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canProceed)
            .keyboardShortcut(currentStep == .review ? .return : .init("]"), modifiers: .command)
        }
        .padding(20)
    }

    private var canProceed: Bool {
        switch currentStep {
        case .method:
            return true
        case .client:
            return !draft.clientName.isEmpty && !draft.address.isEmpty
        case .jobDetails:
            return !draft.jobDescription.isEmpty
        case .pricing:
            return draft.estimatedCost > 0
        case .review:
            return true
        }
    }

    private func goToPreviousStep() {
        if currentStep != .method {
            currentStep = EstimateWizardStep(rawValue: currentStep.rawValue - 1) ?? .method
        }
    }

    private func goToNextStep() {
        if currentStep == .review {
            createEstimate()
        } else {
            currentStep = EstimateWizardStep(rawValue: currentStep.rawValue + 1) ?? .method
        }
    }

    // MARK: - Helper Functions

    private func loadSuggestions() {
        // Get unique client names from existing jobs
        let allJobs = appState.activeJobs + appState.completedJobs
        clientSuggestions = Array(Set(allJobs.map { $0.clientName })).sorted()
        addressSuggestions = Array(Set(allJobs.map { $0.address })).sorted()
    }

    private func updateClientSuggestions(query: String) {
        if query.isEmpty {
            showClientSuggestions = false
            return
        }

        let filtered = clientSuggestions.filter {
            $0.lowercased().contains(query.lowercased())
        }
        clientSuggestions = filtered
        showClientSuggestions = !filtered.isEmpty
    }

    private func updateAddressSuggestions(query: String) {
        if query.isEmpty {
            showAddressSuggestions = false
            return
        }

        let allJobs = appState.activeJobs + appState.completedJobs
        let filtered = Array(Set(allJobs.map { $0.address })).filter {
            $0.lowercased().contains(query.lowercased())
        }.sorted()
        addressSuggestions = filtered
        showAddressSuggestions = !filtered.isEmpty
    }

    private func applyTemplate(_ template: JobTemplate) {
        draft.contractorType = template.contractorType
        draft.jobDescription = template.description
        currentStep = .client
        appState.toastManager.show(message: "Template applied", icon: "doc.text.fill")
    }

    private func startAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            saveDraft()
        }
    }

    private func saveDraft() {
        draft.lastModified = Date()
        // Save to UserDefaults or file system
        if let encoded = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(encoded, forKey: "estimateDraft")
        }
    }

    private func createEstimate() {
        let newJob = Job(
            clientName: draft.clientName,
            clientPhone: draft.clientPhone,
            clientEmail: draft.clientEmail,
            address: draft.address,
            contractorType: draft.contractorType,
            description: draft.jobDescription,
            estimatedCost: draft.estimatedCost,
            progress: 0,
            startDate: Date(),
            notes: draft.notes
        )

        appState.addJob(newJob)
        appState.toastManager.show(
            message: "Estimate created successfully!",
            icon: "checkmark.circle.fill"
        )

        // Clear draft
        UserDefaults.standard.removeObject(forKey: "estimateDraft")

        dismiss()
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

#Preview {
    NewEstimateWizard()
        .environment(AppState())
}
