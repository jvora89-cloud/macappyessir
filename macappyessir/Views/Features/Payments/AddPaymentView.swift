//
//  AddPaymentView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//

import SwiftUI

struct AddPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let job: Job

    @State private var amount: String = ""
    @State private var selectedMethod: PaymentMethod = .check
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var showValidationError = false
    @State private var showReceipt = false
    @State private var lastPayment: Payment?

    var remainingBalance: Double {
        job.remainingBalance
    }

    var isValidAmount: Bool {
        guard let amountValue = Double(amount) else { return false }
        return amountValue > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Payment")
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

            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Balance Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Remaining Balance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(job.formattedRemainingBalance)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total Cost")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(job.actualCost != nil ? job.formattedActual! : job.formattedEstimate)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                    }

                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Amount")
                            .font(.headline)

                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            TextField("0.00", text: $amount)
                                .textFieldStyle(.plain)
                                .font(.title2)
                        }
                        .padding(12)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)

                        if showValidationError && !isValidAmount {
                            Text("Please enter a valid amount")
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        HStack(spacing: 8) {
                            Button("25%") {
                                amount = String(format: "%.0f", remainingBalance * 0.25)
                            }
                            .buttonStyle(.bordered)

                            Button("50%") {
                                amount = String(format: "%.0f", remainingBalance * 0.5)
                            }
                            .buttonStyle(.bordered)

                            Button("Full") {
                                amount = String(format: "%.0f", remainingBalance)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .font(.caption)
                    }

                    // Payment Method
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Method")
                            .font(.headline)

                        Picker("Payment Method", selection: $selectedMethod) {
                            ForEach(PaymentMethod.allCases, id: \.self) { method in
                                HStack {
                                    Image(systemName: method.icon)
                                    Text(method.rawValue)
                                }
                                .tag(method)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Received")
                            .font(.headline)

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.field)
                            .labelsHidden()
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
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
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Add Payment") {
                    addPayment()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!isValidAmount)
            }
            .padding(24)
        }
        .frame(width: 500, height: 650)
        .sheet(isPresented: $showReceipt) {
            if let payment = lastPayment {
                PaymentReceiptView(payment: payment, job: job)
            }
        }
    }

    private func addPayment() {
        guard isValidAmount, let amountValue = Double(amount) else {
            showValidationError = true
            return
        }

        let payment = Payment(
            amount: amountValue,
            date: date,
            paymentMethod: selectedMethod,
            notes: notes
        )

        var updatedJob = job
        updatedJob.payments.append(payment)
        appState.updateJob(updatedJob)

        appState.toastManager.show(
            message: "Payment added successfully!",
            icon: "checkmark.circle.fill"
        )

        // Option to show receipt
        lastPayment = payment
        showReceipt = true
    }
}

#Preview {
    AddPaymentView(job: Job(
        clientName: "John Smith",
        clientPhone: "(555) 123-4567",
        clientEmail: "john.smith@email.com",
        address: "123 Oak Street",
        contractorType: .kitchen,
        description: "Kitchen remodel",
        estimatedCost: 35000,
        payments: [
            Payment(amount: 10000, paymentMethod: .check, notes: "Deposit")
        ]
    ))
    .environment(AppState())
}
