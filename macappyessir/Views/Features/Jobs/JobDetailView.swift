//
//  JobDetailView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import SwiftUI
import PDFKit

struct JobDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let job: Job

    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    @State private var showCompleteConfirmation = false
    @State private var showAddPayment = false
    @State private var selectedTab: DetailTab = .overview

    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case progress = "Progress"
        case payments = "Payments"
        case photos = "Photos"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Tab Navigation
            HStack(spacing: 0) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))

            Divider()

            // Content
            ScrollableContentView {
                VStack(spacing: 24) {
                    switch selectedTab {
                    case .overview:
                        OverviewTab(job: job)
                    case .progress:
                        ProgressTab(job: job)
                    case .payments:
                        PaymentsTab(job: job, showAddPayment: $showAddPayment)
                    case .photos:
                        PhotosTab(job: job)
                    }
                }
                .padding(24)
            }

            Divider()

            // Footer Actions
            footerView
        }
        .frame(width: 900, height: 700)
        .sheet(isPresented: $isEditing) {
            EditJobView(job: job)
        }
        .sheet(isPresented: $showAddPayment) {
            AddPaymentView(job: job)
        }
        .alert("Delete Job", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteJob()
            }
        } message: {
            Text("Are you sure you want to delete this job? This action cannot be undone.")
        }
        .alert("Complete Job", isPresented: $showCompleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Mark Complete", role: .none) {
                completeJob()
            }
        } message: {
            Text("Mark this job as completed? You can still add payments and update details later.")
        }
    }

    private var headerView: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(jobColor.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: job.contractorType.icon)
                    .font(.title)
                    .foregroundColor(jobColor)
            }

            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(job.clientName)
                        .font(.title)
                        .fontWeight(.bold)

                    if job.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Completed")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(12)
                    } else if job.isFullyPaid {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Paid")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }

                Text(job.contractorType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    Label(job.address, systemImage: "mappin.circle.fill")
                    Label(job.clientPhone, systemImage: "phone.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
    }

    private var footerView: some View {
        HStack(spacing: 12) {
            if !job.isCompleted {
                Button(action: { showCompleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark Complete")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            Button(action: { isEditing = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
            }
            .buttonStyle(.bordered)

            Menu {
                Button(action: { exportEstimatePDF() }) {
                    Label("Export Estimate", systemImage: "doc.text")
                }

                Button(action: { exportInvoicePDF() }) {
                    Label("Export Invoice", systemImage: "doc.text.fill")
                }

                Divider()

                Button(action: { printJob() }) {
                    Label("Print", systemImage: "printer")
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
            }
            .buttonStyle(.bordered)

            Spacer()

            Button(action: { showDeleteConfirmation = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding(24)
    }

    private func exportEstimatePDF() {
        if let pdfURL = PDFGenerator.shared.generateEstimatePDF(for: job) {
            NSWorkspace.shared.open(pdfURL)
            appState.toastManager.show(message: "Estimate exported!", icon: "doc.text")
        } else {
            appState.toastManager.show(message: "Export failed", icon: "exclamationmark.triangle")
        }
    }

    private func exportInvoicePDF() {
        if let pdfURL = PDFGenerator.shared.generateInvoicePDF(for: job) {
            NSWorkspace.shared.open(pdfURL)
            appState.toastManager.show(message: "Invoice exported!", icon: "doc.text.fill")
        } else {
            appState.toastManager.show(message: "Export failed", icon: "exclamationmark.triangle")
        }
    }

    private func printJob() {
        if let pdfURL = PDFGenerator.shared.generateEstimatePDF(for: job) {
            let printInfo = NSPrintInfo.shared
            printInfo.horizontalPagination = .fit
            printInfo.verticalPagination = .fit

            if let pdfDocument = PDFDocument(url: pdfURL) {
                let printOperation = pdfDocument.printOperation(for: printInfo, scalingMode: .pageScaleToFit, autoRotate: true)
                printOperation?.runModal(for: NSApp.keyWindow!, delegate: nil, didRun: nil, contextInfo: nil)
            }
        }
    }

    private var jobColor: Color {
        switch job.contractorType {
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

    private func completeJob() {
        var updatedJob = job
        updatedJob.isCompleted = true
        updatedJob.completionDate = Date()
        updatedJob.progress = 1.0

        appState.updateJob(updatedJob)
        appState.toastManager.show(message: "Job marked as completed!", icon: "checkmark.circle.fill")

        dismiss()
    }

    private func deleteJob() {
        appState.deleteJob(job)
        appState.toastManager.show(message: "Job deleted", icon: "trash.fill")
        dismiss()
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .blue : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    Color.blue.opacity(0.1) : Color.clear
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Quick Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatBox(
                    title: "Estimate",
                    value: job.formattedEstimate,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                StatBox(
                    title: job.isCompleted ? "Final Cost" : "Progress",
                    value: job.isCompleted ? (job.formattedActual ?? job.formattedEstimate) : "\(Int(job.progress * 100))%",
                    icon: job.isCompleted ? "checkmark.circle.fill" : "chart.bar.fill",
                    color: job.isCompleted ? .green : .orange
                )

                StatBox(
                    title: "Payments",
                    value: job.formattedTotalPaid,
                    icon: "banknote.fill",
                    color: job.isFullyPaid ? .green : .orange
                )
            }

            // Client Information
            SectionHeader(title: "Client Information", icon: "person.fill")

            InfoCard {
                VStack(spacing: 12) {
                    DetailRow(label: "Name", value: job.clientName, icon: "person.fill")
                    if !job.clientPhone.isEmpty {
                        DetailRow(label: "Phone", value: job.clientPhone, icon: "phone.fill")
                    }
                    if !job.clientEmail.isEmpty {
                        DetailRow(label: "Email", value: job.clientEmail, icon: "envelope.fill")
                    }
                    DetailRow(label: "Address", value: job.address, icon: "mappin.circle.fill")
                }
            }

            // Job Details
            SectionHeader(title: "Job Details", icon: "doc.text.fill")

            InfoCard {
                VStack(spacing: 12) {
                    DetailRow(label: "Type", value: job.contractorType.rawValue, icon: job.contractorType.icon)
                    DetailRow(label: "Started", value: job.startDate.formatted(date: .long, time: .omitted), icon: "calendar")

                    if let completionDate = job.completionDate {
                        DetailRow(label: "Completed", value: completionDate.formatted(date: .long, time: .omitted), icon: "checkmark.circle")
                    } else {
                        DetailRow(label: "Days Active", value: "\(job.daysInProgress) days", icon: "clock")
                    }
                }
            }

            // Description
            if !job.description.isEmpty {
                SectionHeader(title: "Description", icon: "text.alignleft")

                InfoCard {
                    Text(job.description)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }

            // Notes
            if !job.notes.isEmpty {
                SectionHeader(title: "Notes", icon: "note.text")

                InfoCard {
                    Text(job.notes)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - Progress Tab
struct ProgressTab: View {
    @Environment(AppState.self) private var appState
    let job: Job
    @State private var newProgress: Double
    @State private var progressNotes: String = ""

    init(job: Job) {
        self.job = job
        _newProgress = State(initialValue: job.progress)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Progress Overview
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline)

                    Spacer()

                    Text("\(Int(job.progress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                            .cornerRadius(10)

                        Rectangle()
                            .fill(progressGradient)
                            .frame(width: geometry.size.width * job.progress, height: 20)
                            .cornerRadius(10)
                    }
                }
                .frame(height: 20)
            }
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)

            // Update Progress
            if !job.isCompleted {
                SectionHeader(title: "Update Progress", icon: "arrow.up.circle.fill")

                InfoCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("New Progress:")
                                .font(.subheadline)

                            Spacer()

                            Text("\(Int(newProgress * 100))%")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        Slider(value: $newProgress, in: 0...1)
                            .tint(.blue)

                        HStack(spacing: 12) {
                            Button("25%") { newProgress = 0.25 }
                                .buttonStyle(.bordered)
                            Button("50%") { newProgress = 0.50 }
                                .buttonStyle(.bordered)
                            Button("75%") { newProgress = 0.75 }
                                .buttonStyle(.bordered)
                            Button("100%") { newProgress = 1.0 }
                                .buttonStyle(.bordered)
                        }
                        .font(.caption)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress Notes (Optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextEditor(text: $progressNotes)
                                .frame(height: 80)
                                .padding(8)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(8)
                                .font(.body)
                        }

                        Button(action: updateProgress) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Update Progress")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newProgress == job.progress)
                    }
                }
            }

            // Timeline
            SectionHeader(title: "Timeline", icon: "clock.fill")

            VStack(spacing: 12) {
                TimelineItem(
                    title: "Job Started",
                    date: job.startDate,
                    icon: "play.circle.fill",
                    color: .blue
                )

                if job.isCompleted, let completionDate = job.completionDate {
                    TimelineItem(
                        title: "Job Completed",
                        date: completionDate,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
            }
        }
    }

    private var progressColor: Color {
        if job.progress < 0.33 {
            return .red
        } else if job.progress < 0.66 {
            return .orange
        } else {
            return .green
        }
    }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [progressColor.opacity(0.7), progressColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func updateProgress() {
        var updatedJob = job
        updatedJob.progress = newProgress

        if !progressNotes.isEmpty {
            updatedJob.notes += (updatedJob.notes.isEmpty ? "" : "\n\n") + "Progress Update (\(Date().formatted(date: .abbreviated, time: .shortened))): \(progressNotes)"
        }

        if newProgress >= 1.0 {
            updatedJob.isCompleted = true
            updatedJob.completionDate = Date()
        }

        appState.updateJob(updatedJob)
        appState.toastManager.show(message: "Progress updated!", icon: "checkmark.circle.fill")

        progressNotes = ""
    }
}

// MARK: - Payments Tab
struct PaymentsTab: View {
    let job: Job
    @Binding var showAddPayment: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Payment Summary
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatBox(
                    title: "Total Cost",
                    value: job.actualCost != nil ? job.formattedActual! : job.formattedEstimate,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                StatBox(
                    title: "Paid",
                    value: job.formattedTotalPaid,
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatBox(
                    title: "Remaining",
                    value: job.formattedRemainingBalance,
                    icon: "clock.fill",
                    color: job.isFullyPaid ? .green : .orange
                )
            }

            // Payment Progress
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Payment Progress")
                        .font(.headline)

                    Spacer()

                    Text("\(Int(job.paymentProgress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(job.isFullyPaid ? .green : .orange)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)

                        Rectangle()
                            .fill(job.isFullyPaid ? Color.green : Color.orange)
                            .frame(width: geometry.size.width * job.paymentProgress, height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)

            // Add Payment Button
            if !job.isFullyPaid {
                Button(action: { showAddPayment = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Payment")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            // Payment History
            if job.payments.isEmpty {
                EmptyPaymentsView()
            } else {
                SectionHeader(title: "Payment History", icon: "list.bullet")

                VStack(spacing: 12) {
                    ForEach(job.payments.sorted(by: { $0.date > $1.date })) { payment in
                        PaymentHistoryRow(payment: payment, job: job)
                    }
                }
            }
        }
    }
}

// MARK: - Photos Tab
struct PhotosTab: View {
    let job: Job

    var body: some View {
        PhotoGalleryView(job: job)
    }
}

// MARK: - Supporting Views
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
        }
    }
}

struct InfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct TimelineItem: View {
    let title: String
    let date: Date
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct PaymentHistoryRow: View {
    @Environment(AppState.self) private var appState
    let payment: Payment
    let job: Job
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: payment.paymentMethod.icon)
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(payment.formattedAmount)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(payment.paymentMethod.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(payment.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !payment.notes.isEmpty {
                    Text(payment.notes)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: { showDeleteConfirmation = true }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .alert("Delete Payment", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                var updatedJob = job
                updatedJob.payments.removeAll { $0.id == payment.id }
                appState.updateJob(updatedJob)
            }
        } message: {
            Text("Are you sure you want to delete this payment of \(payment.formattedAmount)?")
        }
    }
}

struct EmptyPaymentsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Payments Yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Add your first payment to start tracking funds")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct EmptyPhotosView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Photos Yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Photo management coming in next update")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

#Preview {
    JobDetailView(job: Job(
        clientName: "John Smith",
        clientPhone: "(555) 123-4567",
        clientEmail: "john@email.com",
        address: "123 Oak Street, Austin, TX",
        contractorType: .kitchen,
        description: "Complete kitchen remodel with new cabinets and countertops",
        estimatedCost: 35000,
        progress: 0.65,
        payments: [
            Payment(amount: 10000, paymentMethod: .check, notes: "Deposit"),
            Payment(amount: 15000, paymentMethod: .bankTransfer, notes: "Progress payment")
        ]
    ))
    .environment(AppState())
}
