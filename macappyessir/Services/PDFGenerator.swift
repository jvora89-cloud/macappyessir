//
//  PDFGenerator.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import Foundation
import PDFKit
import AppKit

class PDFGenerator {
    static let shared = PDFGenerator()

    private init() {}

    // MARK: - Generate Estimate PDF
    func generateEstimatePDF(for job: Job) -> URL? {
        let pageWidth: CGFloat = 612  // 8.5 inches
        let pageHeight: CGFloat = 792  // 11 inches
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!

        var mediaBox = pageRect

        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
            return nil
        }

        pdfContext.beginPDFPage(nil)

        // Transform coordinate system to match AppKit (origin at top-left)
        pdfContext.translateBy(x: 0, y: pageHeight)
        pdfContext.scaleBy(x: 1.0, y: -1.0)

        var yPosition: CGFloat = 50

        // Header
        yPosition = drawHeader(in: pdfContext, pageRect: pageRect, at: yPosition)

        // Title
        yPosition = drawTitle("ESTIMATE", in: pdfContext, pageRect: pageRect, at: yPosition)

        // Estimate Info
        yPosition = drawEstimateInfo(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)

        // Client Info
        yPosition = drawSectionHeader("BILL TO:", in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawClientInfo(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)

        // Job Details
        yPosition = drawSectionHeader("PROJECT DETAILS:", in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawJobDetails(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)

        // Cost Breakdown
        yPosition = drawSectionHeader("COST BREAKDOWN:", in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawCostBreakdown(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)

        // Total
        yPosition = drawTotal(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)

        // Terms
        if yPosition < pageHeight - 150 {
            yPosition = drawTerms(in: pdfContext, pageRect: pageRect, at: yPosition)
        }

        // Footer
        drawFooter(in: pdfContext, pageRect: pageRect)

        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return savePDF(data: pdfData as Data, filename: "Estimate_\(job.clientName)_\(Date().timeIntervalSince1970).pdf")
    }

    // MARK: - Generate Invoice PDF
    func generateInvoicePDF(for job: Job) -> URL? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!

        var mediaBox = pageRect

        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
            return nil
        }

        pdfContext.beginPDFPage(nil)
        pdfContext.translateBy(x: 0, y: pageHeight)
        pdfContext.scaleBy(x: 1.0, y: -1.0)

        var yPosition: CGFloat = 50

        yPosition = drawHeader(in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawTitle("INVOICE", in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawInvoiceInfo(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawSectionHeader("BILL TO:", in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawClientInfo(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawSectionHeader("PROJECT DETAILS:", in: pdfContext, pageRect: pageRect, at: yPosition)
        yPosition = drawJobDetails(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)

        if !job.payments.isEmpty {
            yPosition = drawSectionHeader("PAYMENT HISTORY:", in: pdfContext, pageRect: pageRect, at: yPosition)
            yPosition = drawPaymentHistory(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)
        }

        yPosition = drawBalanceSummary(job: job, in: pdfContext, pageRect: pageRect, at: yPosition)
        drawFooter(in: pdfContext, pageRect: pageRect)

        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return savePDF(data: pdfData as Data, filename: "Invoice_\(job.clientName)_\(Date().timeIntervalSince1970).pdf")
    }

    // MARK: - Drawing Methods
    private func drawHeader(in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        drawText("QuoteHub", font: NSFont.boldSystemFont(ofSize: 24), color: NSColor.systemBlue, at: CGPoint(x: 50, y: y), in: context)
        drawText("Professional Contractor Estimates", font: NSFont.systemFont(ofSize: 12), color: NSColor.gray, at: CGPoint(x: 50, y: y + 30), in: context)

        context.setStrokeColor(NSColor.systemBlue.cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: 50, y: y + 55))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: y + 55))
        context.strokePath()

        return y + 80
    }

    private func drawTitle(_ title: String, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        drawText(title, font: NSFont.boldSystemFont(ofSize: 28), at: CGPoint(x: 50, y: y), in: context)
        return y + 50
    }

    private func drawEstimateInfo(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        let rightX = pageRect.width - 250
        let estimateNumber = "EST-\(String(format: "%06d", abs(job.id.hashValue % 1000000)))"
        let dateString = job.startDate.formatted(date: .long, time: .omitted)

        drawText("Estimate #:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: rightX, y: y), in: context)
        drawText(estimateNumber, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX + 90, y: y), in: context)

        drawText("Date:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: rightX, y: y + 20), in: context)
        drawText(dateString, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX + 90, y: y + 20), in: context)

        return y + 60
    }

    private func drawInvoiceInfo(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        let rightX = pageRect.width - 250
        let invoiceNumber = "INV-\(String(format: "%06d", abs(job.id.hashValue % 1000000)))"

        drawText("Invoice #:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: rightX, y: y), in: context)
        drawText(invoiceNumber, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX + 80, y: y), in: context)

        drawText("Date:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: rightX, y: y + 20), in: context)
        drawText(Date().formatted(date: .long, time: .omitted), font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX + 80, y: y + 20), in: context)

        return y + 60
    }

    private func drawSectionHeader(_ text: String, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        drawText(text, font: NSFont.boldSystemFont(ofSize: 12), color: NSColor.darkGray, at: CGPoint(x: 50, y: y), in: context)
        return y + 30
    }

    private func drawClientInfo(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        var currentY = y

        drawText(job.clientName, font: NSFont.boldSystemFont(ofSize: 12), at: CGPoint(x: 50, y: currentY), in: context)
        currentY += 20

        if !job.clientPhone.isEmpty {
            drawText(job.clientPhone, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
            currentY += 18
        }

        if !job.clientEmail.isEmpty {
            drawText(job.clientEmail, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
            currentY += 18
        }

        drawText(job.address, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
        currentY += 18

        return currentY + 20
    }

    private func drawJobDetails(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        var currentY = y

        drawText("Project Type:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
        drawText(job.contractorType.rawValue, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 150, y: currentY), in: context)
        currentY += 25

        drawText("Description:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
        currentY += 20

        // Draw description with word wrap
        let descriptionLines = job.description.components(separatedBy: "\n")
        for line in descriptionLines.prefix(5) {
            drawText(line, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context, maxWidth: pageRect.width - 100)
            currentY += 18
        }

        return currentY + 20
    }

    private func drawCostBreakdown(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        var currentY = y

        // Header
        drawText("Description", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
        drawText("Amount", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: pageRect.width - 150, y: currentY), in: context)
        currentY += 25

        // Line items
        let materials = job.estimatedCost * 0.6
        let labor = job.estimatedCost * 0.4

        drawText("Materials & Supplies", font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
        drawText(formatCurrency(materials), font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: pageRect.width - 150, y: currentY), in: context)
        currentY += 20

        drawText("Labor", font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: 50, y: currentY), in: context)
        drawText(formatCurrency(labor), font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: pageRect.width - 150, y: currentY), in: context)
        currentY += 20

        return currentY + 20
    }

    private func drawTotal(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        context.setStrokeColor(NSColor.gray.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: pageRect.width - 200, y: y))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: y))
        context.strokePath()

        drawText("TOTAL:", font: NSFont.boldSystemFont(ofSize: 14), at: CGPoint(x: pageRect.width - 200, y: y + 10), in: context)
        drawText(job.formattedEstimate, font: NSFont.boldSystemFont(ofSize: 14), at: CGPoint(x: pageRect.width - 150, y: y + 10), in: context)

        return y + 50
    }

    private func drawPaymentHistory(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        var currentY = y

        for payment in job.payments.sorted(by: { $0.date < $1.date }) {
            drawText(payment.date.formatted(date: .abbreviated, time: .omitted), font: NSFont.systemFont(ofSize: 10), at: CGPoint(x: 50, y: currentY), in: context)
            drawText(payment.paymentMethod.rawValue, font: NSFont.systemFont(ofSize: 10), at: CGPoint(x: 150, y: currentY), in: context)
            drawText(payment.formattedAmount, font: NSFont.systemFont(ofSize: 10), at: CGPoint(x: 300, y: currentY), in: context)
            currentY += 18
        }

        return currentY + 20
    }

    private func drawBalanceSummary(job: Job, in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        var currentY = y
        let rightX = pageRect.width - 200

        drawText("Total Cost:", font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX, y: currentY), in: context)
        drawText(job.actualCost != nil ? job.formattedActual! : job.formattedEstimate, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX + 100, y: currentY), in: context)
        currentY += 20

        drawText("Total Paid:", font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX, y: currentY), in: context)
        drawText(job.formattedTotalPaid, font: NSFont.systemFont(ofSize: 11), at: CGPoint(x: rightX + 100, y: currentY), in: context)
        currentY += 20

        context.setStrokeColor(NSColor.gray.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: rightX, y: currentY))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: currentY))
        context.strokePath()
        currentY += 10

        let balanceColor = job.isFullyPaid ? NSColor.systemGreen : NSColor.systemOrange
        drawText("Balance Due:", font: NSFont.boldSystemFont(ofSize: 11), at: CGPoint(x: rightX, y: currentY), in: context)
        drawText(job.formattedRemainingBalance, font: NSFont.boldSystemFont(ofSize: 11), color: balanceColor, at: CGPoint(x: rightX + 100, y: currentY), in: context)

        return currentY + 40
    }

    private func drawTerms(in context: CGContext, pageRect: CGRect, at y: CGFloat) -> CGFloat {
        drawText("TERMS & CONDITIONS:", font: NSFont.boldSystemFont(ofSize: 9), at: CGPoint(x: 50, y: y), in: context)

        let terms = [
            "• This estimate is valid for 30 days from the date above.",
            "• A 50% deposit is required to begin work.",
            "• Final payment is due upon completion.",
            "• All work is guaranteed for 1 year from completion date."
        ]

        var currentY = y + 15
        for term in terms {
            drawText(term, font: NSFont.systemFont(ofSize: 9), at: CGPoint(x: 50, y: currentY), in: context)
            currentY += 12
        }

        return currentY + 20
    }

    private func drawFooter(in context: CGContext, pageRect: CGRect) {
        let footerY = pageRect.height - 30
        let footerText = "Generated by QuoteHub • \(Date().formatted(date: .abbreviated, time: .shortened))"
        drawText(footerText, font: NSFont.systemFont(ofSize: 9), color: NSColor.gray, at: CGPoint(x: 50, y: footerY), in: context)
    }

    // MARK: - Helper Methods
    private func drawText(_ text: String, font: NSFont, color: NSColor = .black, at point: CGPoint, in context: CGContext, maxWidth: CGFloat = 500) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)

        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: point.x, y: point.y)
        context.scaleBy(x: 1.0, y: -1.0)

        CTLineDraw(line, context)
        context.restoreGState()
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    private func savePDF(data: Data, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfPath = documentsPath.appendingPathComponent(filename)

        do {
            try data.write(to: pdfPath)
            print("✅ PDF saved to: \(pdfPath.path)")
            return pdfPath
        } catch {
            print("❌ Error saving PDF: \(error)")
            return nil
        }
    }
}
