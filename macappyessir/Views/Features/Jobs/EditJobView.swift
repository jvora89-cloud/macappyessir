//
//  EditJobView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import SwiftUI

struct EditJobView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let job: Job

    @State private var clientName: String
    @State private var clientPhone: String
    @State private var clientEmail: String
    @State private var address: String
    @State private var selectedType: ContractorType
    @State private var jobDescription: String
    @State private var estimatedCost: String
    @State private var actualCost: String
    @State private var notes: String
    @State private var showValidation = false

    init(job: Job) {
        self.job = job
        _clientName = State(initialValue: job.clientName)
        _clientPhone = State(initialValue: job.clientPhone)
        _clientEmail = State(initialValue: job.clientEmail)
        _address = State(initialValue: job.address)
        _selectedType = State(initialValue: job.contractorType)
        _jobDescription = State(initialValue: job.description)
        _estimatedCost = State(initialValue: String(format: "%.0f", job.estimatedCost))
        _actualCost = State(initialValue: job.actualCost != nil ? String(format: "%.0f", job.actualCost!) : "")
        _notes = State(initialValue: job.notes)
    }

    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 12)
    ]

    var isValidForm: Bool {
        !clientName.isEmpty && !address.isEmpty && !jobDescription.isEmpty &&
        Double(estimatedCost) != nil && Double(estimatedCost)! > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Edit Job")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(job.clientName)
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

            // Form Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Client Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Client Information")
                            .font(.headline)

                        FormField(title: "Client Name *", placeholder: "John Smith", text: $clientName)
                        FormField(title: "Phone", placeholder: "(555) 123-4567", text: $clientPhone)
                        FormField(title: "Email", placeholder: "client@email.com", text: $clientEmail)
                        FormField(title: "Job Address *", placeholder: "123 Main St", text: $address)
                    }

                    Divider()

                    // Job Type
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Job Type")
                            .font(.headline)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(ContractorType.allCases) { type in
                                ContractorTypeCard(
                                    type: type,
                                    isSelected: selectedType == type,
                                    action: { selectedType = type }
                                )
                            }
                        }
                    }

                    Divider()

                    // Job Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Job Details")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextEditor(text: $jobDescription)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(8)
                                .font(.body)
                        }

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Estimated Cost *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                HStack {
                                    Text("$")
                                        .foregroundColor(.secondary)
                                    TextField("0.00", text: $estimatedCost)
                                        .textFieldStyle(.plain)
                                }
                                .padding(12)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Actual Cost")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                HStack {
                                    Text("$")
                                        .foregroundColor(.secondary)
                                    TextField("0.00", text: $actualCost)
                                        .textFieldStyle(.plain)
                                }
                                .padding(12)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(8)
                            }
                        }
                    }

                    Divider()

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        TextEditor(text: $notes)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .font(.body)
                    }

                    // Validation Message
                    if showValidation && !isValidForm {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Please fill in all required fields (*)")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
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

                Button("Save Changes") {
                    saveChanges()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!isValidForm)
            }
            .padding(24)
        }
        .frame(width: 700, height: 750)
    }

    private func saveChanges() {
        guard isValidForm else {
            showValidation = true
            return
        }

        guard let estimate = Double(estimatedCost) else { return }

        var updatedJob = job
        updatedJob.clientName = clientName
        updatedJob.clientPhone = clientPhone
        updatedJob.clientEmail = clientEmail
        updatedJob.address = address
        updatedJob.contractorType = selectedType
        updatedJob.description = jobDescription
        updatedJob.estimatedCost = estimate
        updatedJob.actualCost = !actualCost.isEmpty ? Double(actualCost) : nil
        updatedJob.notes = notes

        appState.updateJob(updatedJob)
        appState.toastManager.show(message: "Job updated successfully!", icon: "checkmark.circle.fill")

        dismiss()
    }
}

#Preview {
    EditJobView(job: Job(
        clientName: "John Smith",
        clientPhone: "(555) 123-4567",
        clientEmail: "john@email.com",
        address: "123 Oak Street, Austin, TX",
        contractorType: .kitchen,
        description: "Complete kitchen remodel",
        estimatedCost: 35000
    ))
    .environment(AppState())
}
