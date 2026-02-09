//
//  DataManager.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import Foundation
import AppKit

class DataManager {
    static let shared = DataManager()

    private let jobsFileName = "jobs.json"
    private let photosDirectoryName = "JobPhotos"

    private init() {
        createPhotosDirectoryIfNeeded()
    }

    // MARK: - Directory Management

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var jobsFileURL: URL {
        documentsDirectory.appendingPathComponent(jobsFileName)
    }

    private var photosDirectory: URL {
        documentsDirectory.appendingPathComponent(photosDirectoryName)
    }

    private func createPhotosDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Save Jobs

    func saveJobs(_ jobs: [Job]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(jobs)
            try data.write(to: jobsFileURL)

            print("✅ Saved \(jobs.count) jobs to: \(jobsFileURL.path)")
        } catch {
            print("❌ Error saving jobs: \(error)")
        }
    }

    // MARK: - Load Jobs

    func loadJobs() -> [Job] {
        guard FileManager.default.fileExists(atPath: jobsFileURL.path) else {
            print("ℹ️ No saved jobs file found")
            return []
        }

        do {
            let data = try Data(contentsOf: jobsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let jobs = try decoder.decode([Job].self, from: data)
            print("✅ Loaded \(jobs.count) jobs from disk")
            return jobs
        } catch {
            print("❌ Error loading jobs: \(error)")
            return []
        }
    }

    // MARK: - Photo Management

    func savePhoto(_ image: NSImage, forJobId jobId: UUID) -> String? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            print("❌ Failed to convert image to PNG")
            return nil
        }

        let fileName = "\(jobId.uuidString)_\(UUID().uuidString).png"
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        do {
            try pngData.write(to: fileURL)
            print("✅ Saved photo: \(fileName)")
            return fileName
        } catch {
            print("❌ Error saving photo: \(error)")
            return nil
        }
    }

    func loadPhoto(named fileName: String) -> NSImage? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        return NSImage(contentsOf: fileURL)
    }

    func savePhoto(from sourceURL: URL, forJobId jobId: UUID) -> String? {
        guard let image = NSImage(contentsOf: sourceURL) else {
            print("❌ Failed to load image from URL")
            return nil
        }

        return savePhoto(image, forJobId: jobId)
    }

    func deletePhoto(at path: String) {
        let fileURL = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: fileURL)
        print("🗑️ Deleted photo at: \(path)")
    }

    func deletePhoto(named fileName: String) {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
        print("🗑️ Deleted photo: \(fileName)")
    }

    func deleteAllPhotosForJob(jobId: UUID) {
        guard let photos = try? FileManager.default.contentsOfDirectory(atPath: photosDirectory.path) else {
            return
        }

        let jobPhotos = photos.filter { $0.hasPrefix(jobId.uuidString) }
        for photo in jobPhotos {
            deletePhoto(named: photo)
        }
    }

    // MARK: - Data Path Info

    func getDataDirectoryPath() -> String {
        documentsDirectory.path
    }

    func getPhotosDirectoryPath() -> String {
        photosDirectory.path
    }
}
