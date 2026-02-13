//
//  EnhancedPaymentSystem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Enhanced payment features: schedules, milestones, receipts, analytics
//

import SwiftUI

// MARK: - Payment Milestone Model

struct PaymentMilestone: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var dueDate: Date?
    var isPaid: Bool
    var paymentId: UUID? // Link to actual payment when paid

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        dueDate: Date? = nil,
        isPaid: Bool = false,
        paymentId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.paymentId = paymentId
    }

    static let commonMilestones: [(String, Double)] = [
        ("Deposit", 0.33),
        ("Midpoint", 0.33),
        ("Final Payment", 0.34)
    ]

    static func generateMilestones(totalCost: Double) -> [PaymentMilestone] {
        commonMilestones.map { (title, percentage) in
            PaymentMilestone(
                title: title,
                amount: totalCost * percentage,
                dueDate: nil
            )
        }
    }
}

// MARK: - Payment Schedule View

struct PaymentScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let job: Job
    @State private var milestones: [PaymentMilestone] = []
    @State private var showAddMilestone = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment Schedule")
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

            ScrollView {
                VStack(spacing: 20) {
                    // Summary
                    paymentSummaryCard

                    // Milestones
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Milestones")
                                .font(.headline)
                            Spacer()
                            Button(action: { showAddMilestone = true }) {
                                Label("Add", systemImage: "plus.circle.fill")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        if milestones.isEmpty {
                            emptyMilestonesView
                        } else {
                            ForEach(milestones) { milestone in
                                milestoneRow(milestone: milestone)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }
                .padding(24)
            }

            Divider()

            // Footer
            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save Schedule") {
                    saveSchedule()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .frame(width: 600, height: 700)
        .onAppear {
            loadMilestones()
        }
        .sheet(isPresented: $showAddMilestone) {
            AddMilestoneView(totalCost: job.estimatedCost) { milestone in
                milestones.append(milestone)
            }
        }
    }

    private var paymentSummaryCard: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Cost")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.formattedEstimate)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Divider()
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Paid")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.formattedTotalPaid)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Divider()
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.formattedRemainingBalance)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }

    private var emptyMilestonesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No milestones yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Create from Template") {
                milestones = PaymentMilestone.generateMilestones(totalCost: job.estimatedCost)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func milestoneRow(milestone: PaymentMilestone) -> some View {
        HStack(spacing: 16) {
            // Status icon
            ZStack {
                Circle()
                    .fill(milestone.isPaid ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: milestone.isPaid ? "checkmark" : "dollarsign")
                    .foregroundColor(milestone.isPaid ? .white : .gray)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.headline)
                    .strikethrough(milestone.isPaid)

                if let dueDate = milestone.dueDate {
                    Text("Due: \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Amount
            Text(formatCurrency(milestone.amount))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(milestone.isPaid ? .green : .primary)

            // Actions
            if !milestone.isPaid {
                Button("Mark Paid") {
                    markMilestonePaid(milestone)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(16)
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(10)
    }

    private func loadMilestones() {
        // Load from job metadata if exists
        // For now, start empty
    }

    private func saveSchedule() {
        // Save milestones to job
        dismiss()
    }

    private func markMilestonePaid(_ milestone: PaymentMilestone) {
        if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
            milestones[index].isPaid = true
            // TODO: Create actual payment
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Add Milestone View

struct AddMilestoneView: View {
    @Environment(\.dismiss) private var dismiss

    let totalCost: Double
    let onAdd: (PaymentMilestone) -> Void

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Milestone")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("e.g., Deposit, Progress Payment", text: $title)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                }

                // Amount
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack {
                        Text("$")
                        TextField("0.00", text: $amount)
                            .textFieldStyle(.plain)
                    }
                    .padding(10)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(6)

                    HStack(spacing: 8) {
                        Button("25%") { amount = String(format: "%.0f", totalCost * 0.25) }
                        Button("33%") { amount = String(format: "%.0f", totalCost * 0.33) }
                        Button("50%") { amount = String(format: "%.0f", totalCost * 0.50) }
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }

                // Due Date
                Toggle("Set Due Date", isOn: $hasDueDate)
                    .toggleStyle(.switch)

                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            .padding(20)

            Spacer()

            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Spacer()

                Button("Add Milestone") {
                    addMilestone()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty || amount.isEmpty)
            }
            .padding(20)
        }
        .frame(width: 400, height: 400)
    }

    private func addMilestone() {
        guard let amountValue = Double(amount) else { return }

        let milestone = PaymentMilestone(
            title: title,
            amount: amountValue,
            dueDate: hasDueDate ? dueDate : nil
        )

        onAdd(milestone)
        dismiss()
    }
}

// MARK: - Payment Analytics Dashboard

struct PaymentAnalyticsView: View {
    @Environment(AppState.self) private var appState

    var allPayments: [Payment] {
        appState.jobs.flatMap { $0.payments }
    }

    var thisMonthPayments: [Payment] {
        let calendar = Calendar.current
        let now = Date()
        return allPayments.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
    }

    var totalReceived: Double {
        allPayments.reduce(0) { $0 + $1.amount }
    }

    var totalOutstanding: Double {
        appState.jobs.reduce(0) { $0 + $1.remainingBalance }
    }

    var paymentMethodBreakdown: [(PaymentMethod, Double)] {
        Dictionary(grouping: allPayments, by: { $0.paymentMethod })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .sorted { $0.value > $1.value }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Payment Analytics")
                    .font(.system(size: 32, weight: .bold))

                // Summary Cards
                HStack(spacing: 16) {
                    analyticsCard(
                        title: "Total Received",
                        value: formatCurrency(totalReceived),
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    analyticsCard(
                        title: "Outstanding",
                        value: formatCurrency(totalOutstanding),
                        icon: "exclamationmark.circle.fill",
                        color: .orange
                    )

                    analyticsCard(
                        title: "This Month",
                        value: formatCurrency(thisMonthPayments.reduce(0) { $0 + $1.amount }),
                        icon: "calendar.circle.fill",
                        color: .blue
                    )
                }

                // Payment Methods Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Payment Methods")
                        .font(.headline)

                    ForEach(paymentMethodBreakdown, id: \.0) { method, total in
                        HStack {
                            Image(systemName: method.icon)
                                .foregroundColor(.blue)
                            Text(method.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(total))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }

                // Recent Payments
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Payments")
                        .font(.headline)

                    ForEach(allPayments.sorted { $0.date > $1.date }.prefix(10)) { payment in
                        recentPaymentRow(payment: payment)
                    }
                }
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func analyticsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }

    private func recentPaymentRow(payment: Payment) -> some View {
        HStack {
            Image(systemName: payment.paymentMethod.icon)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(payment.paymentMethod.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(payment.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(payment.formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Payment Receipt View

struct PaymentReceiptView: View {
    let payment: Payment
    let job: Job
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Payment Receipt")
                    .font(.title2)
                    .fontWeight(.semibold)
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

            ScrollView {
                VStack(spacing: 24) {
                    // Receipt content
                    VStack(alignment: .leading, spacing: 20) {
                        // Business info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Company Name")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("123 Business St")
                                .font(.caption)
                            Text("City, State 12345")
                                .font(.caption)
                        }

                        Divider()

                        // Receipt details
                        receiptRow(label: "Receipt Date", value: payment.formattedDate)
                        receiptRow(label: "Payment Method", value: payment.paymentMethod.rawValue)

                        Divider()

                        // Client info
                        Text("Bill To:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(job.clientName)
                            .font(.body)
                        Text(job.address)
                            .font(.caption)

                        Divider()

                        // Payment amount
                        HStack {
                            Text("Amount Paid")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(payment.formattedAmount)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }

                        if !payment.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(payment.notes)
                                    .font(.caption)
                            }
                        }

                        Divider()

                        Text("Thank you for your payment!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(32)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(24)
            }
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button("Print") {
                    printReceipt()
                }
                .buttonStyle(.bordered)

                Button("Save PDF") {
                    savePDF()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .frame(width: 600, height: 700)
    }

    private func receiptRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private func printReceipt() {
        // TODO: Implement print
    }

    private func savePDF() {
        // TODO: Implement PDF save
    }
}

#Preview {
    PaymentAnalyticsView()
        .environment(AppState())
}
