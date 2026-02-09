//
//  PaymentHistoryView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//

import SwiftUI

struct PaymentHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let job: Job
    @State private var showingAddPayment = false

    var sortedPayments: [Payment] {
        job.payments.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment History")
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

            // Payment Summary
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    PaymentSummaryCard(
                        title: "Total Cost",
                        amount: job.actualCost != nil ? job.formattedActual! : job.formattedEstimate,
                        color: .blue
                    )

                    PaymentSummaryCard(
                        title: "Total Paid",
                        amount: job.formattedTotalPaid,
                        color: .green
                    )

                    PaymentSummaryCard(
                        title: "Remaining",
                        amount: job.formattedRemainingBalance,
                        color: job.isFullyPaid ? .green : .orange
                    )
                }

                // Payment Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Payment Progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(job.paymentProgress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(job.isFullyPaid ? .green : .orange)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(nsColor: .separatorColor))
                                .frame(height: 8)
                                .cornerRadius(4)

                            Rectangle()
                                .fill(job.isFullyPaid ? Color.green : Color.orange)
                                .frame(width: geometry.size.width * job.paymentProgress, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(24)

            Divider()

            // Payments List
            ScrollableContentView {
                if sortedPayments.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No payments recorded")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Add the first payment to track funds")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        ForEach(sortedPayments) { payment in
                            PaymentRow(payment: payment, job: job)
                        }
                    }
                    .padding(24)
                }
            }

            Divider()

            // Footer
            HStack {
                Button("Close") {
                    dismiss()
                }

                Spacer()

                if !job.isFullyPaid {
                    Button(action: { showingAddPayment = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Payment")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
        }
        .frame(width: 600, height: 700)
        .sheet(isPresented: $showingAddPayment) {
            AddPaymentView(job: job)
        }
    }
}

struct PaymentSummaryCard: View {
    let title: String
    let amount: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(amount)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct PaymentRow: View {
    let payment: Payment
    let job: Job
    @Environment(AppState.self) private var appState
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: payment.paymentMethod.icon)
                    .font(.title3)
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(payment.formattedAmount)
                        .font(.headline)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(payment.paymentMethod.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(payment.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !payment.notes.isEmpty {
                    Text(payment.notes)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: { showDeleteConfirmation = true }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .alert("Delete Payment", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePayment()
            }
        } message: {
            Text("Are you sure you want to delete this payment of \(payment.formattedAmount)?")
        }
    }

    private func deletePayment() {
        var updatedJob = job
        updatedJob.payments.removeAll { $0.id == payment.id }
        appState.updateJob(updatedJob)
    }
}

#Preview {
    PaymentHistoryView(job: Job(
        clientName: "John Smith",
        clientPhone: "(555) 123-4567",
        clientEmail: "john.smith@email.com",
        address: "123 Oak Street",
        contractorType: .kitchen,
        description: "Kitchen remodel",
        estimatedCost: 35000,
        payments: [
            Payment(amount: 10000, date: Date().addingTimeInterval(-86400 * 30), paymentMethod: .check, notes: "Initial deposit"),
            Payment(amount: 15000, date: Date().addingTimeInterval(-86400 * 10), paymentMethod: .bankTransfer, notes: "Mid-project payment"),
            Payment(amount: 5000, date: Date(), paymentMethod: .creditCard, notes: "Progress payment")
        ]
    ))
    .environment(AppState())
}
