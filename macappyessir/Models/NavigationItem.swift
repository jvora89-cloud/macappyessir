//
//  NavigationItem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/1/26.
//

import Foundation

enum NavigationItem: String, Identifiable, CaseIterable {
    case dashboard
    case newEstimate
    case activeJobs
    case completed
    case settings

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard:
            return "chart.bar.fill"
        case .newEstimate:
            return "camera.fill"
        case .activeJobs:
            return "hammer.fill"
        case .completed:
            return "checkmark.seal.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

    var title: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .newEstimate:
            return "New Estimate"
        case .activeJobs:
            return "Active Jobs"
        case .completed:
            return "Completed"
        case .settings:
            return "Settings"
        }
    }
}
