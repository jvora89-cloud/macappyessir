//
//  Job.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import Foundation

struct Job: Identifiable, Codable {
    let id: UUID
    var clientName: String
    var clientPhone: String
    var clientEmail: String
    var address: String
    var contractorType: ContractorType
    var description: String
    var estimatedCost: Double
    var actualCost: Double?
    var progress: Double // 0.0 to 1.0
    var startDate: Date
    var completionDate: Date?
    var photos: [String] // URLs or paths
    var isCompleted: Bool
    var notes: String
    var payments: [Payment]

    init(
        id: UUID = UUID(),
        clientName: String,
        clientPhone: String = "",
        clientEmail: String = "",
        address: String,
        contractorType: ContractorType,
        description: String,
        estimatedCost: Double,
        actualCost: Double? = nil,
        progress: Double = 0.0,
        startDate: Date = Date(),
        completionDate: Date? = nil,
        photos: [String] = [],
        isCompleted: Bool = false,
        notes: String = "",
        payments: [Payment] = []
    ) {
        self.id = id
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.address = address
        self.contractorType = contractorType
        self.description = description
        self.estimatedCost = estimatedCost
        self.actualCost = actualCost
        self.progress = progress
        self.startDate = startDate
        self.completionDate = completionDate
        self.photos = photos
        self.isCompleted = isCompleted
        self.notes = notes
        self.payments = payments
    }

    var formattedEstimate: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: estimatedCost)) ?? "$0"
    }

    var formattedActual: String? {
        guard let actualCost = actualCost else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: actualCost))
    }

    var daysInProgress: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }

    // MARK: - Payment Calculations

    var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }

    var remainingBalance: Double {
        let cost = actualCost ?? estimatedCost
        return max(0, cost - totalPaid)
    }

    var paymentProgress: Double {
        let cost = actualCost ?? estimatedCost
        guard cost > 0 else { return 0 }
        return min(1.0, totalPaid / cost)
    }

    var formattedTotalPaid: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalPaid)) ?? "$0"
    }

    var formattedRemainingBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: remainingBalance)) ?? "$0"
    }

    var isFullyPaid: Bool {
        remainingBalance <= 0
    }
}
