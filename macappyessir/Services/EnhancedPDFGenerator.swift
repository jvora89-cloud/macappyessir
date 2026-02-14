//
//  EnhancedPDFGenerator.swift
//  macappyessir
//
//  Enhanced PDF generation with invoices, photos, and more options
//

import Foundation
import PDFKit
import AppKit

enum PDFType {
    case estimate
    case invoice
    case receipt
}

class EnhancedPDFGenerator {
    static let shared = EnhancedPDFGenerator()

    private init() {}

    // MARK: - Invoice Generation

    func generateInvoice(
        for job: Job,
        invoiceNumber: String,
        invoiceDate: Date,
        dueDate: Date,
        includePhotos: Bool = false,
        template: PDFTemplateStyle = .modern
    ) -> PDFDocument? {
        let pdfMetadata = [
            kCGPDFContextTitle: "Invoice #\(invoiceNumber)",
            kCGPDFContextAuthor: "Lakshami Contractors",
            kCGPDFContextCreator: "Lakshami Contractors v1.0"
        ]

        let format = NSMutableData()
        UIGraphicsBeginPDFContextToData(format, CGRect(x: 0, y: 0, width: 612, height: 792), pdfMetadata as CFDictionary)

        // Draw invoice content
        drawInvoicePage(
            job: job,
            invoiceNumber: invoiceNumber,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
            template: template
        )

        // Add photos if requested
        if includePhotos && !job.photos.isEmpty {
            drawPhotoPages(photos: job.photos)
        }

        UIGraphicsEndPDFContext()

        return PDFDocument(data: format as Data)
    }

    // MARK: - Receipt Generation

    func generateReceipt(for payment: Payment, job: Job) -> PDFDocument? {
        let pdfMetadata = [
            kCGPDFContextTitle: "Receipt",
            kCGPDFContextAuthor: "Lakshami Contractors",
            kCGPDFContextCreator: "Lakshami Contractors v1.0"
        ]

        let format = NSMutableData()
        UIGraphicsBeginPDFContextToData(format, CGRect(x: 0, y: 0, width: 612, height: 792), pdfMetadata as CFDictionary)

        drawReceiptPage(payment: payment, job: job)

        UIGraphicsEndPDFContext()

        return PDFDocument(data: format as Data)
    }

    // MARK: - Enhanced Estimate with Options

    func generateEstimate(
        for job: Job,
        includePhotos: Bool = false,
        includeTerms: Bool = true,
        includeSignatureLine: Bool = true,
        template: PDFTemplateStyle = .modern
    ) -> PDFDocument? {
        let pdfMetadata = [
            kCGPDFContextTitle: "Estimate - \(job.clientName)",
            kCGPDFContextAuthor: "Lakshami Contractors",
            kCGPDFContextCreator: "Lakshami Contractors v1.0"
        ]

        let format = NSMutableData()
        UIGraphicsBeginPDFContextToData(format, CGRect(x: 0, y: 0, width: 612, height: 792), pdfMetadata as CFDictionary)

        // Main estimate page
        drawEstimatePage(
            job: job,
            includeTerms: includeTerms,
            includeSignatureLine: includeSignatureLine,
            template: template
        )

        // Photo appendix
        if includePhotos && !job.photos.isEmpty {
            drawPhotoPages(photos: job.photos)
        }

        UIGraphicsEndPDFContext()

        return PDFDocument(data: format as Data)
    }

    // MARK: - Private Drawing Methods

    private func drawInvoicePage(
        job: Job,
        invoiceNumber: String,
        invoiceDate: Date,
        dueDate: Date,
        template: PDFTemplateStyle
    ) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        UIGraphicsBeginPDFPage()

        let preferences = AppPreferences.shared
        let pageWidth: CGFloat = 612
        let margin: CGFloat = 50
        var yPosition: CGFloat = 50

        // Header
        drawHeader(context: context, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, template: template)

        // Invoice Title
        yPosition += 30
        let invoiceTitle = "INVOICE"
        invoiceTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 28),
            .foregroundColor: template.primaryColor
        ])

        // Invoice details
        yPosition += 40
        let invoiceDetails = [
            "Invoice #: \(invoiceNumber)",
            "Invoice Date: \(preferences.dateFormat.format(invoiceDate))",
            "Due Date: \(preferences.dateFormat.format(dueDate))"
        ]

        for detail in invoiceDetails {
            detail.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.black
            ])
            yPosition += 20
        }

        // Bill To section
        yPosition += 20
        drawClientInfo(context: context, job: job, yPosition: &yPosition, margin: margin)

        // Line items table
        yPosition += 30
        drawLineItemsTable(context: context, job: job, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, template: template)

        // Payment summary
        yPosition += 30
        drawPaymentSummary(context: context, job: job, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, template: template)

        // Footer
        drawFooter(context: context, pageWidth: pageWidth, margin: margin)
    }

    private func drawReceiptPage(payment: Payment, job: Job) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        UIGraphicsBeginPDFPage()

        let pageWidth: CGFloat = 612
        let margin: CGFloat = 50
        var yPosition: CGFloat = 50

        // Header
        "Lakshami Contractors".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 24)
        ])

        // Receipt Title
        yPosition += 40
        "PAYMENT RECEIPT".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 28),
            .foregroundColor: NSColor.systemGreen
        ])

        // Receipt details
        yPosition += 50
        let receiptDetails = [
            "Receipt Date: \(AppPreferences.shared.dateFormat.format(payment.date))",
            "Payment Method: \(payment.paymentMethod.rawValue)",
            "Reference: \(payment.referenceNumber ?? "N/A")",
            "",
            "Received From:",
            job.clientName,
            job.clientAddress ?? "",
            "",
            "For: \(job.jobType)",
            "",
            "Amount Paid: \(AppPreferences.shared.currencySymbol)\(String(format: "%.2f", payment.amount))"
        ]

        for detail in receiptDetails {
            detail.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: detail.isEmpty ? NSFont.systemFont(ofSize: 1) : NSFont.systemFont(ofSize: 12),
                .foregroundColor: NSColor.black
            ])
            yPosition += detail.isEmpty ? 5 : 20
        }

        // Thank you message
        yPosition += 40
        "Thank you for your payment!".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.systemGray
        ])

        // Signature line (optional)
        yPosition += 80
        context.setStrokeColor(NSColor.black.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: margin, y: yPosition))
        context.addLine(to: CGPoint(x: margin + 200, y: yPosition))
        context.strokePath()

        "Authorized Signature".draw(at: CGPoint(x: margin, y: yPosition + 10), withAttributes: [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.systemGray
        ])
    }

    private func drawEstimatePage(
        job: Job,
        includeTerms: Bool,
        includeSignatureLine: Bool,
        template: PDFTemplateStyle
    ) {
        // Similar to existing estimate generation but with new options
        // Implementation would go here
    }

    private func drawPhotoPages(photos: [JobPhoto]) {
        for (index, photo) in photos.enumerated() {
            UIGraphicsBeginPDFPage()

            guard let context = UIGraphicsGetCurrentContext() else { continue }

            let pageWidth: CGFloat = 612
            let pageHeight: CGFloat = 792
            let margin: CGFloat = 50

            // Page title
            let title = "Photo Documentation - Page \(index + 1)"
            title.draw(at: CGPoint(x: margin, y: 50), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 16)
            ])

            // Load and draw photo
            if let imageURL = URL(string: photo.filePath),
               let image = NSImage(contentsOf: imageURL) {

                // Calculate image size to fit page
                let availableWidth = pageWidth - (margin * 2)
                let availableHeight = pageHeight - 150

                let imageSize = image.size
                let aspectRatio = imageSize.width / imageSize.height

                var drawWidth = availableWidth
                var drawHeight = drawWidth / aspectRatio

                if drawHeight > availableHeight {
                    drawHeight = availableHeight
                    drawWidth = drawHeight * aspectRatio
                }

                let xPos = (pageWidth - drawWidth) / 2
                let yPos: CGFloat = 100

                let drawRect = CGRect(x: xPos, y: yPos, width: drawWidth, height: drawHeight)
                image.draw(in: drawRect)

                // Photo caption
                if let caption = photo.caption {
                    caption.draw(at: CGPoint(x: margin, y: yPos + drawHeight + 10), withAttributes: [
                        .font: NSFont.systemFont(ofSize: 12),
                        .foregroundColor: NSColor.systemGray
                    ])
                }
            }
        }
    }

    private func drawHeader(context: CGContext, yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, template: PDFTemplateStyle) {
        // Company name
        "Lakshami Contractors".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 20)
        ])

        // Contact info (right-aligned)
        let contactInfo = "jvora89@yahoo.com"
        let contactSize = contactInfo.size(withAttributes: [.font: NSFont.systemFont(ofSize: 10)])
        contactInfo.draw(at: CGPoint(x: pageWidth - margin - contactSize.width, y: yPosition), withAttributes: [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.systemGray
        ])

        yPosition += 25
    }

    private func drawClientInfo(context: CGContext, job: Job, yPosition: inout CGFloat, margin: CGFloat) {
        "BILL TO:".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 12)
        ])

        yPosition += 20

        let clientInfo = [
            job.clientName,
            job.clientAddress ?? "",
            job.clientPhone ?? "",
            job.clientEmail ?? ""
        ].filter { !$0.isEmpty }

        for info in clientInfo {
            info.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: NSFont.systemFont(ofSize: 11)
            ])
            yPosition += 18
        }
    }

    private func drawLineItemsTable(context: CGContext, job: Job, yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, template: PDFTemplateStyle) {
        // Table header
        let headerY = yPosition
        context.setFillColor(template.primaryColor.withAlphaComponent(0.1).cgColor)
        context.fill(CGRect(x: margin, y: headerY, width: pageWidth - margin * 2, height: 25))

        ["Description", "Amount"].enumerated().forEach { index, header in
            header.draw(at: CGPoint(x: margin + CGFloat(index * 300) + 10, y: headerY + 7), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 11),
                .foregroundColor: template.primaryColor
            ])
        }

        yPosition += 30

        // Line items
        let items = [
            (job.jobType, job.estimatedCost)
        ]

        for item in items {
            let itemY = yPosition
            item.0.draw(at: CGPoint(x: margin + 10, y: itemY), withAttributes: [
                .font: NSFont.systemFont(ofSize: 11)
            ])

            let amountStr = "\(AppPreferences.shared.currencySymbol)\(String(format: "%.2f", item.1))"
            amountStr.draw(at: CGPoint(x: margin + 310, y: itemY), withAttributes: [
                .font: NSFont.systemFont(ofSize: 11)
            ])

            yPosition += 25
        }
    }

    private func drawPaymentSummary(context: CGContext, job: Job, yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, template: PDFTemplateStyle) {
        let totalPaid = job.payments.reduce(0) { $0 + $1.amount }
        let balance = job.estimatedCost - totalPaid

        let summaryItems = [
            ("Subtotal:", job.estimatedCost),
            ("Total Paid:", totalPaid),
            ("Balance Due:", balance)
        ]

        for (label, amount) in summaryItems {
            label.draw(at: CGPoint(x: pageWidth - margin - 200, y: yPosition), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 12)
            ])

            let amountStr = "\(AppPreferences.shared.currencySymbol)\(String(format: "%.2f", amount))"
            amountStr.draw(at: CGPoint(x: pageWidth - margin - 100, y: yPosition), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 12),
                .foregroundColor: label.contains("Balance") ? NSColor.systemRed : NSColor.black
            ])

            yPosition += 25
        }
    }

    private func drawFooter(context: CGContext, pageWidth: CGFloat, margin: CGFloat) {
        let footer = "Generated by Lakshami Contractors"
        let footerY: CGFloat = 750

        footer.draw(at: CGPoint(x: (pageWidth - footer.size(withAttributes: [.font: NSFont.systemFont(ofSize: 9)]).width) / 2, y: footerY), withAttributes: [
            .font: NSFont.systemFont(ofSize: 9),
            .foregroundColor: NSColor.systemGray
        ])
    }
}

// MARK: - Extensions

extension String {
    func size(withAttributes attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let nsString = self as NSString
        return nsString.size(withAttributes: attributes)
    }
}

extension PDFTemplateStyle {
    var primaryColor: NSColor {
        switch self {
        case .modern: return NSColor.systemBlue
        case .classic: return NSColor.systemGreen
        case .minimal: return NSColor.black
        }
    }
}
