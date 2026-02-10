//
//  CSVExporter.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import Foundation
import AppKit

class CSVExporter {
    static let shared = CSVExporter()

    private init() {}

    // MARK: - Export Jobs

    /// Export all jobs to CSV file
    func exportJobs(_ jobs: [Job], filename: String = "QuoteHub_Jobs") -> URL? {
        var csvString = "Client Name,Phone,Email,Address,Type,Description,Estimated Cost,Actual Cost,Progress,Status,Start Date,Completion Date,Total Paid,Remaining Balance,Photos Count,Payments Count,Notes\n"

        for job in jobs {
            let row = [
                escapeCSV(job.clientName),
                escapeCSV(job.clientPhone),
                escapeCSV(job.clientEmail),
                escapeCSV(job.address),
                escapeCSV(job.contractorType.rawValue),
                escapeCSV(job.description),
                String(job.estimatedCost),
                job.actualCost != nil ? String(job.actualCost!) : "",
                String(format: "%.0f%%", job.progress * 100),
                job.isCompleted ? "Completed" : "Active",
                job.startDate.formatted(date: .numeric, time: .omitted),
                job.completionDate?.formatted(date: .numeric, time: .omitted) ?? "",
                String(job.totalPaid),
                String(job.remainingBalance),
                String(job.photos.count),
                String(job.payments.count),
                escapeCSV(job.notes)
            ].joined(separator: ",")

            csvString.append(row + "\n")
        }

        return saveCSV(csvString, filename: filename)
    }

    /// Export active jobs only
    func exportActiveJobs(_ jobs: [Job]) -> URL? {
        let activeJobs = jobs.filter { !$0.isCompleted }
        return exportJobs(activeJobs, filename: "QuoteHub_Active_Jobs")
    }

    /// Export completed jobs only
    func exportCompletedJobs(_ jobs: [Job]) -> URL? {
        let completedJobs = jobs.filter { $0.isCompleted }
        return exportJobs(completedJobs, filename: "QuoteHub_Completed_Jobs")
    }

    // MARK: - Export Payments

    /// Export all payments across all jobs
    func exportPayments(_ jobs: [Job], filename: String = "QuoteHub_Payments") -> URL? {
        var csvString = "Client Name,Job Type,Payment Date,Amount,Method,Total Job Cost,Total Paid,Balance Remaining,Notes\n"

        for job in jobs {
            for payment in job.payments.sorted(by: { $0.date < $1.date }) {
                let row = [
                    escapeCSV(job.clientName),
                    escapeCSV(job.contractorType.rawValue),
                    payment.date.formatted(date: .numeric, time: .omitted),
                    String(format: "%.2f", payment.amount),
                    escapeCSV(payment.paymentMethod.rawValue),
                    String(format: "%.2f", job.actualCost ?? job.estimatedCost),
                    String(format: "%.2f", job.totalPaid),
                    String(format: "%.2f", job.remainingBalance),
                    escapeCSV(payment.notes)
                ].joined(separator: ",")

                csvString.append(row + "\n")
            }
        }

        return saveCSV(csvString, filename: filename)
    }

    // MARK: - Export Financial Summary

    /// Export financial summary/revenue report
    func exportFinancialSummary(_ jobs: [Job], filename: String = "QuoteHub_Financial_Summary") -> URL? {
        let activeJobs = jobs.filter { !$0.isCompleted }
        let completedJobs = jobs.filter { $0.isCompleted }

        let totalRevenue = completedJobs.reduce(0) { $0 + ($1.actualCost ?? $1.estimatedCost) }
        let totalPaid = jobs.reduce(0) { $0 + $1.totalPaid }
        let totalOutstanding = jobs.reduce(0) { $0 + $1.remainingBalance }
        let activeValue = activeJobs.reduce(0) { $0 + $1.estimatedCost }

        var csvString = "Metric,Value\n"
        csvString.append("Total Active Jobs,\(activeJobs.count)\n")
        csvString.append("Total Completed Jobs,\(completedJobs.count)\n")
        csvString.append("Total Revenue (Completed),\(String(format: "%.2f", totalRevenue))\n")
        csvString.append("Total Funds Received,\(String(format: "%.2f", totalPaid))\n")
        csvString.append("Outstanding Balance,\(String(format: "%.2f", totalOutstanding))\n")
        csvString.append("Active Jobs Value,\(String(format: "%.2f", activeValue))\n")
        csvString.append("\n")

        csvString.append("\nCompleted Jobs Detail\n")
        csvString.append("Client Name,Type,Cost,Paid,Balance,Completion Date\n")

        for job in completedJobs.sorted(by: { $0.completionDate ?? Date() > $1.completionDate ?? Date() }) {
            let row = [
                escapeCSV(job.clientName),
                escapeCSV(job.contractorType.rawValue),
                String(format: "%.2f", job.actualCost ?? job.estimatedCost),
                String(format: "%.2f", job.totalPaid),
                String(format: "%.2f", job.remainingBalance),
                job.completionDate?.formatted(date: .numeric, time: .omitted) ?? ""
            ].joined(separator: ",")

            csvString.append(row + "\n")
        }

        return saveCSV(csvString, filename: filename)
    }

    // MARK: - Export by Date Range

    /// Export jobs within a date range
    func exportJobsByDateRange(
        _ jobs: [Job],
        from startDate: Date,
        to endDate: Date,
        filename: String = "QuoteHub_Jobs_Date_Range"
    ) -> URL? {
        let filteredJobs = jobs.filter { job in
            job.startDate >= startDate && job.startDate <= endDate
        }

        return exportJobs(filteredJobs, filename: filename)
    }

    // MARK: - Export by Contractor Type

    /// Export jobs grouped by contractor type
    func exportJobsByType(_ jobs: [Job]) -> URL? {
        var csvString = "Contractor Type,Number of Jobs,Total Value,Total Paid,Outstanding\n"

        let groupedJobs = Dictionary(grouping: jobs, by: { $0.contractorType })

        for (type, typeJobs) in groupedJobs.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let totalValue = typeJobs.reduce(0) { $0 + ($1.actualCost ?? $1.estimatedCost) }
            let totalPaid = typeJobs.reduce(0) { $0 + $1.totalPaid }
            let outstanding = typeJobs.reduce(0) { $0 + $1.remainingBalance }

            let row = [
                escapeCSV(type.rawValue),
                String(typeJobs.count),
                String(format: "%.2f", totalValue),
                String(format: "%.2f", totalPaid),
                String(format: "%.2f", outstanding)
            ].joined(separator: ",")

            csvString.append(row + "\n")
        }

        return saveCSV(csvString, filename: "QuoteHub_Jobs_By_Type")
    }

    // MARK: - Helper Methods

    /// Escape special characters in CSV
    private func escapeCSV(_ string: String) -> String {
        let escaped = string.replacingOccurrences(of: "\"", with: "\"\"")

        // If string contains comma, quote, or newline, wrap in quotes
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }

        return escaped
    }

    /// Save CSV string to file
    private func saveCSV(_ csvString: String, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(filename)_\(timestamp).csv"
        let fileURL = documentsPath.appendingPathComponent(filename)

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ CSV exported to: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Error saving CSV: \(error)")
            return nil
        }
    }

    // MARK: - Quick Export

    /// Quick export with user selection
    func quickExport(jobs: [Job], type: ExportType) -> URL? {
        switch type {
        case .allJobs:
            return exportJobs(jobs)
        case .activeJobs:
            return exportActiveJobs(jobs)
        case .completedJobs:
            return exportCompletedJobs(jobs)
        case .payments:
            return exportPayments(jobs)
        case .financialSummary:
            return exportFinancialSummary(jobs)
        case .byType:
            return exportJobsByType(jobs)
        }
    }
}

// MARK: - Export Types

enum ExportType: String, CaseIterable, Identifiable {
    case allJobs = "All Jobs"
    case activeJobs = "Active Jobs"
    case completedJobs = "Completed Jobs"
    case payments = "All Payments"
    case financialSummary = "Financial Summary"
    case byType = "Jobs by Type"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .allJobs: return "doc.text"
        case .activeJobs: return "hammer"
        case .completedJobs: return "checkmark.seal"
        case .payments: return "dollarsign.circle"
        case .financialSummary: return "chart.bar"
        case .byType: return "folder"
        }
    }

    var description: String {
        switch self {
        case .allJobs: return "Export all jobs with full details"
        case .activeJobs: return "Export only active/in-progress jobs"
        case .completedJobs: return "Export only completed jobs"
        case .payments: return "Export all payment records"
        case .financialSummary: return "Export revenue and financial summary"
        case .byType: return "Export jobs grouped by contractor type"
        }
    }
}
