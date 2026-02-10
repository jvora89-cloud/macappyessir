//
//  TemplateManager.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import Foundation

class TemplateManager {
    static let shared = TemplateManager()

    private let templatesFileName = "job_templates.json"

    private init() {}

    // MARK: - File URLs

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var templatesFileURL: URL {
        documentsDirectory.appendingPathComponent(templatesFileName)
    }

    // MARK: - Load Templates

    func loadTemplates() -> [JobTemplate] {
        // Check if custom templates file exists
        if FileManager.default.fileExists(atPath: templatesFileURL.path) {
            do {
                let data = try Data(contentsOf: templatesFileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let customTemplates = try decoder.decode([JobTemplate].self, from: data)
                print("✅ Loaded \(customTemplates.count) custom templates")

                // Merge with default templates
                return customTemplates + JobTemplate.defaultTemplates
            } catch {
                print("❌ Error loading custom templates: \(error)")
                return JobTemplate.defaultTemplates
            }
        } else {
            print("ℹ️ No custom templates found, using defaults")
            return JobTemplate.defaultTemplates
        }
    }

    // MARK: - Save Templates

    func saveTemplates(_ templates: [JobTemplate]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(templates)
            try data.write(to: templatesFileURL)

            print("✅ Saved \(templates.count) templates to: \(templatesFileURL.path)")
        } catch {
            print("❌ Error saving templates: \(error)")
        }
    }

    // MARK: - Add Template

    func addTemplate(_ template: JobTemplate) {
        var templates = loadCustomTemplatesOnly()
        templates.append(template)
        saveTemplates(templates)
    }

    // MARK: - Delete Template

    func deleteTemplate(_ template: JobTemplate) {
        var templates = loadCustomTemplatesOnly()
        templates.removeAll { $0.id == template.id }
        saveTemplates(templates)
    }

    // MARK: - Update Template

    func updateTemplate(_ template: JobTemplate) {
        var templates = loadCustomTemplatesOnly()
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates(templates)
        }
    }

    // MARK: - Create Template from Job

    func createTemplate(from job: Job, name: String) -> JobTemplate {
        return JobTemplate(from: job, name: name)
    }

    // MARK: - Get Templates by Type

    func getTemplates(for type: ContractorType) -> [JobTemplate] {
        return loadTemplates().filter { $0.contractorType == type }
    }

    // MARK: - Private Helpers

    private func loadCustomTemplatesOnly() -> [JobTemplate] {
        guard FileManager.default.fileExists(atPath: templatesFileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: templatesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([JobTemplate].self, from: data)
        } catch {
            print("❌ Error loading custom templates: \(error)")
            return []
        }
    }
}
