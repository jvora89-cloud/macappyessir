//
//  ContractorType.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import Foundation

enum ContractorType: String, CaseIterable, Identifiable, Codable {
    case homeImprovement = "Home Improvement"
    case fencing = "Fencing"
    case remodeling = "Remodeling"
    case kitchen = "Kitchen Upgrade"
    case bathroom = "Bathroom Upgrade"
    case painting = "Painting"
    case flooring = "Flooring"
    case roofing = "Roofing"
    case landscaping = "Landscaping"
    case electrical = "Electrical"
    case plumbing = "Plumbing"
    case hvac = "HVAC"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .homeImprovement:
            return "house.fill"
        case .fencing:
            return "square.grid.3x1.fill"
        case .remodeling:
            return "hammer.fill"
        case .kitchen:
            return "refrigerator.fill"
        case .bathroom:
            return "drop.fill"
        case .painting:
            return "paintbrush.fill"
        case .flooring:
            return "square.stack.3d.up.fill"
        case .roofing:
            return "triangle.fill"
        case .landscaping:
            return "leaf.fill"
        case .electrical:
            return "bolt.fill"
        case .plumbing:
            return "wrench.adjustable.fill"
        case .hvac:
            return "fanblades.fill"
        }
    }

    var color: String {
        switch self {
        case .homeImprovement:
            return "blue"
        case .fencing:
            return "brown"
        case .remodeling:
            return "orange"
        case .kitchen:
            return "purple"
        case .bathroom:
            return "cyan"
        case .painting:
            return "pink"
        case .flooring:
            return "gray"
        case .roofing:
            return "red"
        case .landscaping:
            return "green"
        case .electrical:
            return "yellow"
        case .plumbing:
            return "blue"
        case .hvac:
            return "teal"
        }
    }
}
