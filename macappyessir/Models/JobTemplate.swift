//
//  JobTemplate.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import Foundation

struct JobTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var contractorType: ContractorType
    var description: String
    var estimatedCost: Double
    var materialsCost: Double
    var laborCost: Double
    var estimatedDays: Int
    var notes: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        contractorType: ContractorType,
        description: String,
        estimatedCost: Double,
        materialsCost: Double = 0,
        laborCost: Double = 0,
        estimatedDays: Int = 7,
        notes: String = "",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.contractorType = contractorType
        self.description = description
        self.estimatedCost = estimatedCost
        self.materialsCost = materialsCost
        self.laborCost = laborCost
        self.estimatedDays = estimatedDays
        self.notes = notes
        self.createdDate = createdDate
    }

    /// Create template from existing job
    init(from job: Job, name: String) {
        self.id = UUID()
        self.name = name
        self.contractorType = job.contractorType
        self.description = job.description
        self.estimatedCost = job.estimatedCost
        self.materialsCost = job.estimatedCost * 0.6 // Default split
        self.laborCost = job.estimatedCost * 0.4
        self.estimatedDays = 7
        self.notes = job.notes
        self.createdDate = Date()
    }

    var formattedCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: estimatedCost)) ?? "$0"
    }
}

// MARK: - Default Templates

extension JobTemplate {
    static let defaultTemplates: [JobTemplate] = [
        // Kitchen Remodel
        JobTemplate(
            name: "Standard Kitchen Remodel",
            contractorType: .kitchen,
            description: "Complete kitchen renovation including new cabinets, countertops, appliances, and backsplash. Electrical and plumbing updates as needed.",
            estimatedCost: 25000,
            materialsCost: 15000,
            laborCost: 10000,
            estimatedDays: 14,
            notes: "Typically includes: \n• Cabinet installation\n• Countertop fabrication and install\n• Appliance installation\n• Backsplash tile work\n• Electrical and plumbing as needed"
        ),

        // Bathroom Remodel
        JobTemplate(
            name: "Full Bathroom Renovation",
            contractorType: .bathroom,
            description: "Complete bathroom remodel with new fixtures, tile, vanity, and lighting. Includes plumbing and electrical work.",
            estimatedCost: 15000,
            materialsCost: 9000,
            laborCost: 6000,
            estimatedDays: 10,
            notes: "Standard scope:\n• Tub/shower replacement\n• New vanity and sink\n• Tile flooring and walls\n• Fixture upgrades\n• Lighting updates"
        ),

        // Interior Painting
        JobTemplate(
            name: "Whole House Interior Painting",
            contractorType: .painting,
            description: "Complete interior painting of 2-3 bedroom home including walls, ceilings, and trim. Two coats of premium paint.",
            estimatedCost: 5000,
            materialsCost: 1500,
            laborCost: 3500,
            estimatedDays: 5,
            notes: "Includes:\n• Surface preparation\n• Primer if needed\n• Two coats paint\n• Trim painting\n• Touch-ups"
        ),

        // Roofing
        JobTemplate(
            name: "Asphalt Shingle Roof Replacement",
            contractorType: .roofing,
            description: "Complete roof tear-off and replacement with architectural shingles. Includes underlayment, flashing, and cleanup.",
            estimatedCost: 12000,
            materialsCost: 6000,
            laborCost: 6000,
            estimatedDays: 3,
            notes: "Standard residential roof:\n• Remove old shingles\n• Inspect and repair decking\n• New underlayment\n• Architectural shingles\n• Ridge cap and flashing\n• Complete cleanup"
        ),

        // Flooring
        JobTemplate(
            name: "Hardwood Floor Installation",
            contractorType: .flooring,
            description: "Install hardwood flooring in main living areas (approx. 1000 sq ft). Includes prep, installation, and finishing.",
            estimatedCost: 8000,
            materialsCost: 5000,
            laborCost: 3000,
            estimatedDays: 4,
            notes: "Typical project:\n• Floor preparation\n• Hardwood installation\n• Sanding and finishing\n• Trim and transitions\n• Final cleanup"
        ),

        // Fence Installation
        JobTemplate(
            name: "Privacy Fence Installation",
            contractorType: .fencing,
            description: "Install 6-foot privacy fence around backyard perimeter (approx. 150 linear feet). Includes posts, panels, and gates.",
            estimatedCost: 6000,
            materialsCost: 3500,
            laborCost: 2500,
            estimatedDays: 3,
            notes: "Standard cedar fence:\n• Post installation\n• Panel construction\n• Gate installation\n• Hardware and latch\n• Stain/seal (optional)"
        ),

        // HVAC
        JobTemplate(
            name: "HVAC System Replacement",
            contractorType: .hvac,
            description: "Replace existing HVAC system with new high-efficiency unit. Includes removal of old system and installation of new furnace and AC.",
            estimatedCost: 8000,
            materialsCost: 5500,
            laborCost: 2500,
            estimatedDays: 2,
            notes: "Includes:\n• Old system removal\n• New furnace installation\n• New AC unit\n• Ductwork inspection\n• Thermostat upgrade\n• System testing"
        ),

        // Deck Build
        JobTemplate(
            name: "Composite Deck Construction",
            contractorType: .landscaping,
            description: "Build 12x16 composite deck with stairs and railing. Includes foundation, framing, decking, and all hardware.",
            estimatedCost: 10000,
            materialsCost: 6500,
            laborCost: 3500,
            estimatedDays: 5,
            notes: "Project includes:\n• Deck foundation\n• Framing and joists\n• Composite decking\n• Stairs and railing\n• Hardware and fasteners"
        )
    ]
}
