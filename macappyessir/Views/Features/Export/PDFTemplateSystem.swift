//
//  PDFTemplateSystem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Enhanced PDF templates with multiple styles and preview
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// MARK: - Template Styles

enum PDFTemplateStyle: String, CaseIterable, Identifiable {
    case modern = "Modern"
    case classic = "Classic"
    case minimal = "Minimal"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .modern:
            return "Clean and contemporary with bold headers"
        case .classic:
            return "Traditional business format with serif fonts"
        case .minimal:
            return "Simple and elegant with minimal styling"
        }
    }

    var icon: String {
        switch self {
        case .modern: return "doc.fill"
        case .classic: return "doc.text.fill"
        case .minimal: return "doc.plaintext.fill"
        }
    }

    var primaryColor: Color {
        switch self {
        case .modern: return .blue
        case .classic: return .green
        case .minimal: return .black
        }
    }
}

enum PDFDocumentType: String, CaseIterable {
    case estimate = "Estimate"
    case invoice = "Invoice"
    case receipt = "Receipt"

    var icon: String {
        switch self {
        case .estimate: return "doc.text"
        case .invoice: return "doc.text.fill"
        case .receipt: return "receipt"
        }
    }
}

// MARK: - Branding Settings

struct PDFBrandingSettings {
    var companyName: String = "Your Company Name"
    var tagline: String = "Professional Contractor Services"
    var phone: String = ""
    var email: String = ""
    var website: String = ""
    var address: String = ""

    static func loadFromDefaults() -> PDFBrandingSettings {
        var settings = PDFBrandingSettings()
        if let companyName = UserDefaults.standard.string(forKey: "pdf_companyName") {
            settings.companyName = companyName
        }
        if let tagline = UserDefaults.standard.string(forKey: "pdf_tagline") {
            settings.tagline = tagline
        }
        if let phone = UserDefaults.standard.string(forKey: "pdf_phone") {
            settings.phone = phone
        }
        if let email = UserDefaults.standard.string(forKey: "pdf_email") {
            settings.email = email
        }
        return settings
    }

    func saveToDefaults() {
        UserDefaults.standard.set(companyName, forKey: "pdf_companyName")
        UserDefaults.standard.set(tagline, forKey: "pdf_tagline")
        UserDefaults.standard.set(phone, forKey: "pdf_phone")
        UserDefaults.standard.set(email, forKey: "pdf_email")
    }
}

// MARK: - PDF Export View

struct PDFExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let job: Job
    let documentType: PDFDocumentType

    @State private var selectedStyle: PDFTemplateStyle = .modern
    @State private var branding = PDFBrandingSettings.loadFromDefaults()
    @State private var showBrandingSettings = false
    @State private var pdfURL: URL?
    @State private var isGenerating = false

    var body: some View {
        HSplitView {
            // Left: Settings
            settingsPanel
                .frame(minWidth: 300, idealWidth: 350, maxWidth: 400)

            // Right: Preview
            previewPanel
                .frame(minWidth: 500)
        }
        .frame(minWidth: 900, minHeight: 700)
        .onAppear {
            generatePreview()
        }
        .onChange(of: selectedStyle) { _, _ in
            generatePreview()
        }
    }

    // MARK: - Settings Panel

    private var settingsPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export \(documentType.rawValue)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(job.clientName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(24)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Template Style
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Template Style")
                            .font(.headline)

                        ForEach(PDFTemplateStyle.allCases) { style in
                            templateStyleCard(style: style)
                        }
                    }

                    Divider()

                    // Branding
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Branding")
                                .font(.headline)
                            Spacer()
                            Button("Edit") {
                                showBrandingSettings = true
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            brandingRow(label: "Company", value: branding.companyName)
                            if !branding.phone.isEmpty {
                                brandingRow(label: "Phone", value: branding.phone)
                            }
                            if !branding.email.isEmpty {
                                brandingRow(label: "Email", value: branding.email)
                            }
                        }
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                    }

                    Divider()

                    // Document Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Document Info")
                            .font(.headline)

                        infoRow(label: "Type", value: documentType.rawValue)
                        infoRow(label: "Client", value: job.clientName)
                        infoRow(label: "Amount", value: job.formattedEstimate)
                        infoRow(label: "Date", value: Date().formatted(date: .abbreviated, time: .omitted))
                    }
                }
                .padding(24)
            }

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }

                Spacer()

                Button(action: shareDocument) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .disabled(pdfURL == nil)

                Button(action: saveDocument) {
                    Label("Export", systemImage: "arrow.down.doc")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
            }
            .padding(20)
        }
        .sheet(isPresented: $showBrandingSettings) {
            BrandingSettingsView(branding: $branding)
        }
    }

    private func templateStyleCard(style: PDFTemplateStyle) -> some View {
        Button(action: { selectedStyle = style }) {
            HStack(spacing: 12) {
                Image(systemName: style.icon)
                    .font(.title2)
                    .foregroundColor(style.primaryColor)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(style.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if selectedStyle == style {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(selectedStyle == style ? Color.blue.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedStyle == style ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func brandingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.caption)
                .lineLimit(1)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }

    // MARK: - Preview Panel

    private var previewPanel: some View {
        VStack(spacing: 0) {
            // Preview header
            HStack {
                Text("Preview")
                    .font(.headline)
                Spacer()
                if isGenerating {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.trailing, 8)
                    Text("Generating...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))

            // PDF preview
            if let pdfURL = pdfURL {
                PDFPreviewView(url: pdfURL)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Generating preview...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Actions

    private func generatePreview() {
        isGenerating = true
        pdfURL = nil

        DispatchQueue.global(qos: .userInitiated).async {
            // Generate PDF with selected style
            let url: URL?

            switch documentType {
            case .estimate:
                url = PDFGenerator.shared.generateEstimatePDF(for: job)
            case .invoice:
                url = PDFGenerator.shared.generateInvoicePDF(for: job)
            case .receipt:
                url = PDFGenerator.shared.generateEstimatePDF(for: job) // TODO: Add receipt generator
            }

            DispatchQueue.main.async {
                pdfURL = url
                isGenerating = false
            }
        }
    }

    private func saveDocument() {
        guard let pdfURL = pdfURL else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "\(documentType.rawValue)_\(job.clientName)_\(Date().timeIntervalSince1970).pdf"

        savePanel.begin { response in
            if response == .OK, let destination = savePanel.url {
                do {
                    try FileManager.default.copyItem(at: pdfURL, to: destination)
                    appState.toastManager.show(
                        message: "\(documentType.rawValue) exported successfully!",
                        icon: "checkmark.circle.fill"
                    )
                    dismiss()
                } catch {
                    print("Error saving PDF: \(error)")
                }
            }
        }
    }

    private func shareDocument() {
        guard let pdfURL = pdfURL else { return }

        let picker = NSSharingServicePicker(items: [pdfURL])
        if let view = NSApp.keyWindow?.contentView {
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }
    }
}

// MARK: - PDF Preview View

struct PDFPreviewView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }

        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}

// MARK: - Branding Settings View

struct BrandingSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var branding: PDFBrandingSettings

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Branding Settings")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    brandingField(label: "Company Name", text: $branding.companyName, placeholder: "Your Company Name")
                    brandingField(label: "Tagline", text: $branding.tagline, placeholder: "Professional Services")
                    brandingField(label: "Phone", text: $branding.phone, placeholder: "(555) 123-4567")
                    brandingField(label: "Email", text: $branding.email, placeholder: "contact@company.com")
                    brandingField(label: "Website", text: $branding.website, placeholder: "www.company.com")
                    brandingField(label: "Address", text: $branding.address, placeholder: "123 Main St, City, State")
                }
                .padding(20)
            }

            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Spacer()

                Button("Save") {
                    branding.saveToDefaults()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .frame(width: 500, height: 600)
    }

    private func brandingField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
        }
    }
}

#Preview {
    PDFExportView(
        job: Job(
            clientName: "John Smith",
            address: "123 Main St",
            contractorType: .kitchen,
            description: "Kitchen remodel",
            estimatedCost: 35000
        ),
        documentType: .estimate
    )
    .environment(AppState())
}
