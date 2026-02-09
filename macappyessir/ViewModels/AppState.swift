//
//  AppState.swift
//  macappyessir
//
//  Created by Jay Vora on 2/1/26.
//

import SwiftUI

@Observable
class AppState {
    var selectedItem: NavigationItem? = .dashboard
    var jobs: [Job] = [] {
        didSet {
            saveJobs()
        }
    }
    var toastManager = ToastManager()

    init() {
        loadJobs()
    }

    private func loadJobs() {
        let savedJobs = DataManager.shared.loadJobs()

        if savedJobs.isEmpty {
            // First time launch - load sample data
            self.jobs = [
            Job(
                clientName: "John Smith",
                clientPhone: "(555) 123-4567",
                clientEmail: "john.smith@email.com",
                address: "123 Oak Street, Austin, TX 78701",
                contractorType: .kitchen,
                description: "Complete kitchen remodel including new cabinets, granite countertops, stainless steel appliances, and tile backsplash.",
                estimatedCost: 35000,
                progress: 0.65,
                startDate: Date().addingTimeInterval(-86400 * 15),
                isCompleted: false,
                notes: "Client wants white shaker cabinets"
            ),
            Job(
                clientName: "Sarah Johnson",
                clientPhone: "(555) 234-5678",
                clientEmail: "sarah.j@email.com",
                address: "456 Maple Ave, Austin, TX 78702",
                contractorType: .bathroom,
                description: "Master bathroom renovation with walk-in shower, double vanity, and heated floors.",
                estimatedCost: 22000,
                progress: 0.30,
                startDate: Date().addingTimeInterval(-86400 * 8),
                isCompleted: false,
                notes: "Plumbing inspection scheduled for next week"
            ),
            Job(
                clientName: "Mike Davis",
                clientPhone: "(555) 345-6789",
                clientEmail: "mdavis@email.com",
                address: "789 Pine Road, Austin, TX 78703",
                contractorType: .fencing,
                description: "Install 200ft cedar privacy fence with two gates around backyard perimeter.",
                estimatedCost: 8500,
                actualCost: 8200,
                progress: 1.0,
                startDate: Date().addingTimeInterval(-86400 * 35),
                completionDate: Date().addingTimeInterval(-86400 * 5),
                isCompleted: true,
                notes: "Customer very satisfied"
            ),
            Job(
                clientName: "Emily Rodriguez",
                clientPhone: "(555) 456-7890",
                clientEmail: "emily.r@email.com",
                address: "321 Cedar Lane, Austin, TX 78704",
                contractorType: .painting,
                description: "Interior painting of entire 2-story home including walls, trim, and ceilings.",
                estimatedCost: 6500,
                actualCost: 6800,
                progress: 1.0,
                startDate: Date().addingTimeInterval(-86400 * 20),
                completionDate: Date().addingTimeInterval(-86400 * 2),
                isCompleted: true,
                notes: "Added extra coat in living room"
            ),
            Job(
                clientName: "Robert Chen",
                clientPhone: "(555) 567-8901",
                clientEmail: "rchen@email.com",
                address: "654 Birch Court, Austin, TX 78705",
                contractorType: .roofing,
                description: "Replace asphalt shingle roof, repair damaged decking, install new gutters.",
                estimatedCost: 18000,
                progress: 0.45,
                startDate: Date().addingTimeInterval(-86400 * 5),
                isCompleted: false,
                notes: "Weather dependent - rain delays possible"
            )
            ]
            print("ℹ️ Loaded sample data (first launch)")
        } else {
            self.jobs = savedJobs
            print("✅ Loaded \(savedJobs.count) jobs from storage")
        }
    }

    private func saveJobs() {
        DataManager.shared.saveJobs(jobs)
    }

    // MARK: - Job Management

    func addJob(_ job: Job) {
        jobs.append(job)
    }

    func updateJob(_ job: Job) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index] = job
        }
    }

    func deleteJob(_ job: Job) {
        jobs.removeAll { $0.id == job.id }
        DataManager.shared.deleteAllPhotosForJob(jobId: job.id)
    }

    var activeJobs: [Job] {
        jobs.filter { !$0.isCompleted }
    }

    var completedJobs: [Job] {
        jobs.filter { $0.isCompleted }
    }

    var totalRevenue: Double {
        completedJobs.compactMap { $0.actualCost ?? $0.estimatedCost }.reduce(0, +)
    }

    var totalActiveValue: Double {
        activeJobs.map { $0.estimatedCost }.reduce(0, +)
    }

    var totalFundsReceived: Double {
        jobs.reduce(0) { $0 + $1.totalPaid }
    }

    var outstandingBalance: Double {
        jobs.reduce(0) { $0 + $1.remainingBalance }
    }

    var completedJobsRevenue: Double {
        completedJobs.reduce(0) { $0 + $1.totalPaid }
    }
}
