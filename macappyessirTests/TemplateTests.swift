//
//  TemplateTests.swift
//  macappyessirTests
//
//  Created by Jay Vora on 2/10/26.
//

import XCTest
@testable import macappyessir

final class TemplateTests: XCTestCase {

    // MARK: - Template Creation Tests

    func testTemplateCreation() {
        let template = JobTemplate(
            name: "Standard Kitchen Remodel",
            contractorType: .kitchen,
            description: "Complete kitchen renovation",
            estimatedCost: 25000,
            materialsCost: 15000,
            laborCost: 10000,
            estimatedDays: 14,
            notes: "Includes cabinets and countertops"
        )

        XCTAssertEqual(template.name, "Standard Kitchen Remodel")
        XCTAssertEqual(template.contractorType, .kitchen)
        XCTAssertEqual(template.estimatedCost, 25000)
        XCTAssertEqual(template.materialsCost, 15000)
        XCTAssertEqual(template.laborCost, 10000)
        XCTAssertEqual(template.estimatedDays, 14)
    }

    func testTemplateFromJob() {
        let job = Job(
            clientName: "Test Client",
            clientPhone: "(555) 123-4567",
            clientEmail: "test@example.com",
            address: "123 Test St",
            contractorType: .bathroom,
            description: "Bathroom renovation with new fixtures",
            estimatedCost: 15000,
            progress: 0.0,
            startDate: Date(),
            isCompleted: false,
            notes: "Client wants modern fixtures"
        )

        let template = JobTemplate(from: job, name: "My Custom Bathroom Template")

        XCTAssertEqual(template.name, "My Custom Bathroom Template")
        XCTAssertEqual(template.contractorType, .bathroom)
        XCTAssertEqual(template.description, job.description)
        XCTAssertEqual(template.estimatedCost, job.estimatedCost)
        XCTAssertEqual(template.notes, job.notes)
    }

    // MARK: - Default Templates Tests

    func testDefaultTemplatesExist() {
        let templates = JobTemplate.defaultTemplates

        XCTAssertGreaterThan(templates.count, 0, "Should have default templates")
        XCTAssertTrue(templates.count >= 8, "Should have at least 8 default templates")
    }

    func testDefaultTemplateTypes() {
        let templates = JobTemplate.defaultTemplates
        let types = Set(templates.map { $0.contractorType })

        XCTAssertTrue(types.contains(.kitchen), "Should have kitchen template")
        XCTAssertTrue(types.contains(.bathroom), "Should have bathroom template")
        XCTAssertTrue(types.contains(.painting), "Should have painting template")
        XCTAssertTrue(types.contains(.roofing), "Should have roofing template")
    }

    func testDefaultTemplateHasValidCosts() {
        let templates = JobTemplate.defaultTemplates

        for template in templates {
            XCTAssertGreaterThan(template.estimatedCost, 0, "\(template.name) should have valid estimated cost")
            XCTAssertGreaterThan(template.materialsCost, 0, "\(template.name) should have valid materials cost")
            XCTAssertGreaterThan(template.laborCost, 0, "\(template.name) should have valid labor cost")
            XCTAssertEqual(
                template.estimatedCost,
                template.materialsCost + template.laborCost,
                accuracy: 0.01,
                "\(template.name) cost breakdown should add up"
            )
        }
    }

    func testDefaultTemplateHasValidDays() {
        let templates = JobTemplate.defaultTemplates

        for template in templates {
            XCTAssertGreaterThan(template.estimatedDays, 0, "\(template.name) should have valid estimated days")
            XCTAssertLessThan(template.estimatedDays, 100, "\(template.name) estimated days should be realistic")
        }
    }

    // MARK: - Template Manager Tests

    func testTemplateManagerSingleton() {
        let manager1 = TemplateManager.shared
        let manager2 = TemplateManager.shared

        XCTAssertTrue(manager1 === manager2, "TemplateManager should be a singleton")
    }

    func testLoadTemplates() {
        let manager = TemplateManager.shared
        let templates = manager.loadTemplates()

        XCTAssertGreaterThan(templates.count, 0, "Should load at least default templates")
    }

    func testGetTemplatesByType() {
        let manager = TemplateManager.shared
        let kitchenTemplates = manager.getTemplates(for: .kitchen)

        XCTAssertGreaterThan(kitchenTemplates.count, 0, "Should have kitchen templates")

        for template in kitchenTemplates {
            XCTAssertEqual(template.contractorType, .kitchen)
        }
    }

    func testCreateTemplateFromJob() {
        let manager = TemplateManager.shared

        let job = Job(
            clientName: "Test Client",
            clientPhone: "(555) 999-8888",
            clientEmail: "test@example.com",
            address: "789 Test Ave",
            contractorType: .flooring,
            description: "Hardwood floor installation",
            estimatedCost: 8000,
            progress: 0.5,
            startDate: Date(),
            isCompleted: false,
            notes: "Oak hardwood"
        )

        let template = manager.createTemplate(from: job, name: "Custom Flooring Template")

        XCTAssertEqual(template.name, "Custom Flooring Template")
        XCTAssertEqual(template.contractorType, job.contractorType)
        XCTAssertEqual(template.description, job.description)
    }

    // MARK: - Formatted Values Tests

    func testFormattedCost() {
        let template = JobTemplate(
            name: "Test Template",
            contractorType: .kitchen,
            description: "Test description",
            estimatedCost: 25000,
            materialsCost: 15000,
            laborCost: 10000,
            estimatedDays: 10
        )

        XCTAssertTrue(template.formattedCost.contains("25"))
        XCTAssertTrue(template.formattedCost.contains("$"))
    }

    // MARK: - Template Equality Tests

    func testTemplateIdentifiable() {
        let template1 = JobTemplate(
            id: UUID(),
            name: "Template 1",
            contractorType: .kitchen,
            description: "Test",
            estimatedCost: 10000
        )

        let template2 = JobTemplate(
            id: UUID(),
            name: "Template 2",
            contractorType: .kitchen,
            description: "Test",
            estimatedCost: 10000
        )

        XCTAssertNotEqual(template1.id, template2.id, "Different templates should have different IDs")
    }

    // MARK: - Cost Breakdown Tests

    func testMaterialsToLaborRatio() {
        let template = JobTemplate(
            name: "Test Template",
            contractorType: .bathroom,
            description: "Test",
            estimatedCost: 10000,
            materialsCost: 6000,
            laborCost: 4000
        )

        let materialsRatio = template.materialsCost / template.estimatedCost
        let laborRatio = template.laborCost / template.estimatedCost

        XCTAssertEqual(materialsRatio, 0.6, accuracy: 0.01)
        XCTAssertEqual(laborRatio, 0.4, accuracy: 0.01)
        XCTAssertEqual(materialsRatio + laborRatio, 1.0, accuracy: 0.01)
    }

    // MARK: - Description Tests

    func testTemplateDescription() {
        let template = JobTemplate(
            name: "Full Bathroom Renovation",
            contractorType: .bathroom,
            description: "Complete bathroom remodel with new fixtures, tile, vanity, and lighting.",
            estimatedCost: 15000
        )

        XCTAssertFalse(template.description.isEmpty)
        XCTAssertTrue(template.description.count > 20, "Description should be detailed")
    }
}
