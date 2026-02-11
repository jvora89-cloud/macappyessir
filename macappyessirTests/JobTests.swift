//
//  JobTests.swift
//  macappyessirTests
//
//  Created by Jay Vora on 2/10/26.
//

import XCTest
@testable import macappyessir

final class JobTests: XCTestCase {

    // MARK: - Job Creation Tests

    func testJobCreation() {
        let job = Job(
            clientName: "John Doe",
            clientPhone: "(555) 123-4567",
            clientEmail: "john@example.com",
            address: "123 Main St",
            contractorType: .kitchen,
            description: "Kitchen remodel",
            estimatedCost: 25000,
            progress: 0.0,
            startDate: Date(),
            isCompleted: false,
            notes: "Test notes"
        )

        XCTAssertEqual(job.clientName, "John Doe")
        XCTAssertEqual(job.clientPhone, "(555) 123-4567")
        XCTAssertEqual(job.clientEmail, "john@example.com")
        XCTAssertEqual(job.address, "123 Main St")
        XCTAssertEqual(job.contractorType, .kitchen)
        XCTAssertEqual(job.estimatedCost, 25000)
        XCTAssertEqual(job.progress, 0.0)
        XCTAssertFalse(job.isCompleted)
    }

    // MARK: - Payment Tests

    func testAddPayment() {
        var job = Job(
            clientName: "Jane Smith",
            clientPhone: "(555) 987-6543",
            clientEmail: "jane@example.com",
            address: "456 Oak Ave",
            contractorType: .bathroom,
            description: "Bathroom renovation",
            estimatedCost: 15000,
            progress: 0.5,
            startDate: Date(),
            isCompleted: false,
            notes: ""
        )

        let payment = Payment(amount: 5000, paymentMethod: .check, notes: "Initial payment")
        job.payments.append(payment)

        XCTAssertEqual(job.payments.count, 1)
        XCTAssertEqual(job.totalPaid, 5000)
        XCTAssertEqual(job.remainingBalance, 10000)
    }

    func testMultiplePayments() {
        var job = Job(
            clientName: "Bob Johnson",
            clientPhone: "(555) 456-7890",
            clientEmail: "bob@example.com",
            address: "789 Pine Rd",
            contractorType: .roofing,
            description: "Roof replacement",
            estimatedCost: 12000,
            progress: 0.75,
            startDate: Date(),
            isCompleted: false,
            notes: ""
        )

        job.payments.append(Payment(amount: 4000, paymentMethod: .cash, notes: "Deposit"))
        job.payments.append(Payment(amount: 3000, paymentMethod: .check, notes: "Progress payment"))
        job.payments.append(Payment(amount: 5000, paymentMethod: .creditCard, notes: "Final payment"))

        XCTAssertEqual(job.payments.count, 3)
        XCTAssertEqual(job.totalPaid, 12000)
        XCTAssertEqual(job.remainingBalance, 0)
    }

    func testPaymentMethods() {
        let cashPayment = Payment(amount: 1000, paymentMethod: .cash, notes: "")
        let checkPayment = Payment(amount: 2000, paymentMethod: .check, notes: "")
        let cardPayment = Payment(amount: 3000, paymentMethod: .creditCard, notes: "")

        XCTAssertEqual(cashPayment.paymentMethod, .cash)
        XCTAssertEqual(checkPayment.paymentMethod, .check)
        XCTAssertEqual(cardPayment.paymentMethod, .creditCard)
    }

    // MARK: - Job Completion Tests

    func testJobCompletion() {
        var job = Job(
            clientName: "Alice Brown",
            clientPhone: "(555) 111-2222",
            clientEmail: "alice@example.com",
            address: "321 Elm St",
            contractorType: .painting,
            description: "Interior painting",
            estimatedCost: 5000,
            progress: 0.9,
            startDate: Date(),
            isCompleted: false,
            notes: ""
        )

        XCTAssertFalse(job.isCompleted)
        XCTAssertNil(job.completionDate)

        job.isCompleted = true
        job.completionDate = Date()
        job.progress = 1.0

        XCTAssertTrue(job.isCompleted)
        XCTAssertNotNil(job.completionDate)
        XCTAssertEqual(job.progress, 1.0)
    }

    // MARK: - Cost Tests

    func testEstimatedVsActualCost() {
        var job = Job(
            clientName: "Charlie Davis",
            clientPhone: "(555) 333-4444",
            clientEmail: "charlie@example.com",
            address: "654 Birch Ln",
            contractorType: .fencing,
            description: "Privacy fence installation",
            estimatedCost: 6000,
            progress: 1.0,
            startDate: Date(),
            isCompleted: true,
            notes: ""
        )

        job.actualCost = 6500
        job.completionDate = Date()

        XCTAssertEqual(job.estimatedCost, 6000)
        XCTAssertEqual(job.actualCost, 6500)
        XCTAssertEqual(job.actualCost! - job.estimatedCost, 500) // Over budget by $500
    }

    func testRemainingBalance() {
        var job = Job(
            clientName: "Diana Evans",
            clientPhone: "(555) 555-6666",
            clientEmail: "diana@example.com",
            address: "987 Cedar Dr",
            contractorType: .flooring,
            description: "Hardwood floor installation",
            estimatedCost: 8000,
            progress: 0.6,
            startDate: Date(),
            isCompleted: false,
            notes: ""
        )

        XCTAssertEqual(job.remainingBalance, 8000)

        job.payments.append(Payment(amount: 3000, paymentMethod: .check, notes: "Deposit"))
        XCTAssertEqual(job.remainingBalance, 5000)

        job.payments.append(Payment(amount: 2000, paymentMethod: .cash, notes: "Progress"))
        XCTAssertEqual(job.remainingBalance, 3000)
    }

    // MARK: - Progress Tests

    func testProgressBounds() {
        var job = Job(
            clientName: "Edward Foster",
            clientPhone: "(555) 777-8888",
            clientEmail: "edward@example.com",
            address: "147 Maple Ct",
            contractorType: .hvac,
            description: "HVAC system replacement",
            estimatedCost: 8000,
            progress: 0.0,
            startDate: Date(),
            isCompleted: false,
            notes: ""
        )

        XCTAssertGreaterThanOrEqual(job.progress, 0.0)
        XCTAssertLessThanOrEqual(job.progress, 1.0)

        job.progress = 0.5
        XCTAssertEqual(job.progress, 0.5)

        job.progress = 1.0
        XCTAssertEqual(job.progress, 1.0)
    }

    // MARK: - Contractor Type Tests

    func testContractorTypes() {
        let types: [ContractorType] = [
            .homeImprovement, .plumbing, .fencing, .remodeling,
            .kitchen, .bathroom, .painting, .flooring,
            .roofing, .landscaping, .electrical, .hvac
        ]

        XCTAssertEqual(types.count, 12)
        XCTAssertTrue(ContractorType.allCases.count >= 12)
    }

    // MARK: - Date Tests

    func testJobDates() {
        let startDate = Date()
        let job = Job(
            clientName: "Fiona Green",
            clientPhone: "(555) 999-0000",
            clientEmail: "fiona@example.com",
            address: "258 Willow Way",
            contractorType: .landscaping,
            description: "Deck construction",
            estimatedCost: 10000,
            progress: 0.4,
            startDate: startDate,
            isCompleted: false,
            notes: ""
        )

        XCTAssertEqual(job.startDate, startDate)
        XCTAssertNil(job.completionDate)
    }

    // MARK: - Notes Tests

    func testJobNotes() {
        let notes = "Client prefers eco-friendly materials. Weather-dependent timeline."
        let job = Job(
            clientName: "George Hill",
            clientPhone: "(555) 222-3333",
            clientEmail: "george@example.com",
            address: "369 Spruce Blvd",
            contractorType: .remodeling,
            description: "Home remodeling",
            estimatedCost: 50000,
            progress: 0.3,
            startDate: Date(),
            isCompleted: false,
            notes: notes
        )

        XCTAssertEqual(job.notes, notes)
        XCTAssertFalse(job.notes.isEmpty)
    }

    // MARK: - Formatted Values Tests

    func testFormattedCost() {
        let job = Job(
            clientName: "Helen Ives",
            clientPhone: "(555) 444-5555",
            clientEmail: "helen@example.com",
            address: "741 Aspen Ave",
            contractorType: .kitchen,
            description: "Kitchen renovation",
            estimatedCost: 25000,
            progress: 0.0,
            startDate: Date(),
            isCompleted: false,
            notes: ""
        )

        XCTAssertTrue(job.formattedEstimate.contains("25"))
        XCTAssertTrue(job.formattedEstimate.contains("000"))
    }
}
