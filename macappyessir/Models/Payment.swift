//
//  Payment.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//

import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var date: Date
    var paymentMethod: PaymentMethod
    var notes: String

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date(),
        paymentMethod: PaymentMethod = .check,
        notes: String = ""
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.paymentMethod = paymentMethod
        self.notes = notes
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "Cash"
    case check = "Check"
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case venmo = "Venmo"
    case zelle = "Zelle"
    case other = "Other"

    var icon: String {
        switch self {
        case .cash:
            return "banknote.fill"
        case .check:
            return "doc.text.fill"
        case .creditCard:
            return "creditcard.fill"
        case .bankTransfer:
            return "building.columns.fill"
        case .venmo:
            return "app.fill"
        case .zelle:
            return "app.fill"
        case .other:
            return "dollarsign.circle.fill"
        }
    }
}
