//
//  SampleDataGenerator.swift
//  macappyessir
//
//  Created for demo and testing purposes
//

import Foundation
import SwiftUI

@Observable
class SampleDataGenerator {

    static let shared = SampleDataGenerator()

    private init() {}

    // MARK: - Public API

    func generateSampleData(for appState: AppState) {
        // Clear existing data first (optional)
        // appState.jobs.removeAll()

        // Generate sample jobs with payments and photos
        let jobs = generateSampleJobs()

        for job in jobs {
            appState.jobs.append(job)
        }

        print("✅ Generated \(jobs.count) sample jobs")
    }

    // MARK: - Job Generation

    private func generateSampleJobs() -> [Job] {
        var jobs: [Job] = []

        // Job 1: Kitchen Renovation - High value, in progress
        jobs.append(Job(
            id: UUID(),
            clientName: "Sarah Johnson",
            clientAddress: "123 Maple Street, Portland, OR 97201",
            clientPhone: "(503) 555-0123",
            clientEmail: "sarah.johnson@email.com",
            contractorType: .general,
            estimatedCost: 24500,
            startDate: Date().addingTimeInterval(-14 * 24 * 3600), // 2 weeks ago
            description: "Complete kitchen renovation including new cabinets, countertops, appliances, flooring, and lighting. Custom tile backsplash and island installation.",
            status: .active,
            progress: 0.45,
            jobType: "Kitchen Renovation",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 8000,
                    date: Date().addingTimeInterval(-14 * 24 * 3600),
                    paymentMethod: .check,
                    referenceNumber: "CHK-1001",
                    notes: "Deposit payment"
                ),
                Payment(
                    id: UUID(),
                    amount: 8000,
                    date: Date().addingTimeInterval(-7 * 24 * 3600),
                    paymentMethod: .bankTransfer,
                    referenceNumber: "ACH-2394",
                    notes: "Progress payment after demolition"
                )
            ],
            photos: []
        ))

        // Job 2: Bathroom Remodel - Medium value, active
        jobs.append(Job(
            id: UUID(),
            clientName: "Michael Chen",
            clientAddress: "456 Oak Avenue, Portland, OR 97202",
            clientPhone: "(503) 555-0456",
            clientEmail: "m.chen@email.com",
            contractorType: .plumbing,
            estimatedCost: 12800,
            startDate: Date().addingTimeInterval(-10 * 24 * 3600),
            description: "Master bathroom remodel with walk-in shower, new vanity, tile work, and updated plumbing fixtures. Heated floors installation.",
            status: .active,
            progress: 0.60,
            jobType: "Bathroom Remodel",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 4266,
                    date: Date().addingTimeInterval(-10 * 24 * 3600),
                    paymentMethod: .card,
                    referenceNumber: "CC-4521",
                    notes: "33% deposit"
                )
            ],
            photos: []
        ))

        // Job 3: Deck Construction - High value, just started
        jobs.append(Job(
            id: UUID(),
            clientName: "Jennifer Davis",
            clientAddress: "789 Pine Road, Lake Oswego, OR 97034",
            clientPhone: "(503) 555-0789",
            clientEmail: "jen.davis@email.com",
            contractorType: .carpentry,
            estimatedCost: 18900,
            startDate: Date().addingTimeInterval(-3 * 24 * 3600),
            description: "Custom composite deck construction (24'x16') with built-in seating, railing system, and under-deck drainage. Includes pergola.",
            status: .active,
            progress: 0.15,
            jobType: "Deck Construction",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 6237,
                    date: Date().addingTimeInterval(-3 * 24 * 3600),
                    paymentMethod: .bankTransfer,
                    referenceNumber: "ACH-8821",
                    notes: "Initial payment"
                )
            ],
            photos: []
        ))

        // Job 4: HVAC Installation - Completed
        jobs.append(Job(
            id: UUID(),
            clientName: "Robert Martinez",
            clientAddress: "321 Cedar Lane, Beaverton, OR 97005",
            clientPhone: "(503) 555-0321",
            clientEmail: "r.martinez@email.com",
            contractorType: .hvac,
            estimatedCost: 8500,
            startDate: Date().addingTimeInterval(-30 * 24 * 3600),
            description: "Complete HVAC system replacement. New high-efficiency furnace and AC unit installation with smart thermostat.",
            status: .completed,
            progress: 1.0,
            jobType: "HVAC Installation",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 2833,
                    date: Date().addingTimeInterval(-30 * 24 * 3600),
                    paymentMethod: .check,
                    referenceNumber: "CHK-2101"
                ),
                Payment(
                    id: UUID(),
                    amount: 2834,
                    date: Date().addingTimeInterval(-23 * 24 * 3600),
                    paymentMethod: .check,
                    referenceNumber: "CHK-2102"
                ),
                Payment(
                    id: UUID(),
                    amount: 2833,
                    date: Date().addingTimeInterval(-16 * 24 * 3600),
                    paymentMethod: .card,
                    referenceNumber: "CC-9921",
                    notes: "Final payment"
                )
            ],
            photos: []
        ))

        // Job 5: Exterior Painting - Medium value, active
        jobs.append(Job(
            id: UUID(),
            clientName: "Amanda Wilson",
            clientAddress: "654 Birch Court, Tigard, OR 97223",
            clientPhone: "(503) 555-0654",
            clientEmail: "amanda.w@email.com",
            contractorType: .painting,
            estimatedCost: 6200,
            startDate: Date().addingTimeInterval(-5 * 24 * 3600),
            description: "Full exterior house painting. Pressure washing, scraping, priming, and two coats of premium paint. Includes trim and shutters.",
            status: .active,
            progress: 0.35,
            jobType: "Exterior Painting",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 2046,
                    date: Date().addingTimeInterval(-5 * 24 * 3600),
                    paymentMethod: .cash,
                    notes: "Deposit - materials purchased"
                )
            ],
            photos: []
        ))

        // Job 6: Roof Repair - Small job, completed
        jobs.append(Job(
            id: UUID(),
            clientName: "Thomas Anderson",
            clientAddress: "987 Elm Street, Portland, OR 97211",
            clientPhone: "(503) 555-0987",
            clientEmail: "t.anderson@email.com",
            contractorType: .roofing,
            estimatedCost: 3200,
            startDate: Date().addingTimeInterval(-45 * 24 * 3600),
            description: "Emergency roof leak repair. Replace damaged shingles, repair flashing around chimney, seal penetrations.",
            status: .completed,
            progress: 1.0,
            jobType: "Roof Repair",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 3200,
                    date: Date().addingTimeInterval(-44 * 24 * 3600),
                    paymentMethod: .check,
                    referenceNumber: "CHK-5501",
                    notes: "Full payment on completion"
                )
            ],
            photos: []
        ))

        // Job 7: Landscaping Project - Large job, active
        jobs.append(Job(
            id: UUID(),
            clientName: "Lisa Thompson",
            clientAddress: "234 Willow Drive, West Linn, OR 97068",
            clientPhone: "(503) 555-0234",
            clientEmail: "lisa.thompson@email.com",
            contractorType: .landscaping,
            estimatedCost: 15600,
            startDate: Date().addingTimeInterval(-8 * 24 * 3600),
            description: "Complete backyard landscaping. New patio installation, raised garden beds, irrigation system, native plants, and decorative lighting.",
            status: .active,
            progress: 0.28,
            jobType: "Landscaping",
            payments: [
                Payment(
                    id: UUID(),
                    amount: 5148,
                    date: Date().addingTimeInterval(-8 * 24 * 3600),
                    paymentMethod: .bankTransfer,
                    referenceNumber: "ACH-7734"
                )
            ],
            photos: []
        ))

        // Job 8: Electrical Upgrade - Medium value, just quoted
        jobs.append(Job(
            id: UUID(),
            clientName: "David Park",
            clientAddress: "567 Spruce Avenue, Milwaukie, OR 97222",
            clientPhone: "(503) 555-0567",
            clientEmail: "d.park@email.com",
            contractorType: .electrical,
            estimatedCost: 9400,
            startDate: Date().addingTimeInterval(-1 * 24 * 3600),
            description: "Electrical panel upgrade to 200 amp service. Add dedicated circuits for kitchen appliances, EV charger installation in garage.",
            status: .active,
            progress: 0.05,
            jobType: "Electrical Upgrade",
            payments: [],
            photos: []
        ))

        return jobs
    }

    // MARK: - Helper Methods

    func clearAllData(for appState: AppState) {
        appState.jobs.removeAll()
        print("🗑️ Cleared all sample data")
    }
}

// MARK: - Debug Menu Integration

#if DEBUG
extension AppState {
    func loadSampleData() {
        SampleDataGenerator.shared.generateSampleData(for: self)
    }

    func clearSampleData() {
        SampleDataGenerator.shared.clearAllData(for: self)
    }
}
#endif
