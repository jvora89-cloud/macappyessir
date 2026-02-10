//
//  JobCard.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct JobCard: View {
    let job: Job
    @State private var showingPaymentHistory = false
    @State private var showingJobDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: job.contractorType.icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(job.clientName)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(job.contractorType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(job.formattedEstimate)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    if job.isCompleted, let actual = job.formattedActual {
                        Text(actual)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            // Address
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            // Description
            Text(job.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Payment Status
            if !job.payments.isEmpty || !job.isCompleted {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Payment")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        if job.isFullyPaid {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                Text("Paid in Full")
                                    .font(.caption)
                            }
                            .foregroundColor(.green)
                        } else {
                            Text("\(job.formattedTotalPaid) of \(job.actualCost != nil ? job.formattedActual! : job.formattedEstimate)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
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

            if !job.isCompleted {
                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(job.progress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(iconColor)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)

                            Rectangle()
                                .fill(iconColor)
                                .frame(width: geometry.size.width * job.progress, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }

            // Footer
            HStack(spacing: 16) {
                Label(dateText, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if job.photos.count > 0 {
                    Label("\(job.photos.count)", systemImage: "photo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { showingPaymentHistory = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                        Text("Payments")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)

                if job.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                } else {
                    Text("\(job.daysInProgress) days")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(iconColor)
                }
            }
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .onTapGesture {
            showingJobDetail = true
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(job.clientName), \(job.contractorType.rawValue)")
        .accessibilityValue(accessibilityDescription)
        .accessibilityHint("Double tap to view job details")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(AccessibilityID.jobCard)
        .sheet(isPresented: $showingPaymentHistory) {
            PaymentHistoryView(job: job)
        }
        .sheet(isPresented: $showingJobDetail) {
            JobDetailView(job: job)
        }
    }

    private var iconColor: Color {
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

    private var accessibilityDescription: String {
        var description = "\(job.formattedEstimate) estimate"
        if job.isCompleted {
            description += ", Completed"
        } else {
            description += ", \(Int(job.progress * 100))% complete"
        }
        if job.isFullyPaid {
            description += ", Paid in full"
        } else if !job.payments.isEmpty {
            description += ", \(job.formattedTotalPaid) paid"
        }
        return description
    }

    private var dateText: String {
        if job.isCompleted {
            return "Completed " + (job.completionDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
        } else {
            return "Started " + job.startDate.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

#Preview {
    JobCard(job: Job(
        clientName: "John Smith",
        address: "123 Oak Street, Austin, TX",
        contractorType: .kitchen,
        description: "Complete kitchen remodel with new cabinets and countertops",
        estimatedCost: 35000,
        progress: 0.65
    ))
    .padding()
    .frame(width: 450)
}
