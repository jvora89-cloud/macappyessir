//
//  PerformanceOptimizer.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Performance optimization utilities
//

import Foundation
import SwiftUI

// MARK: - Image Cache

@Observable
class ImageCache {
    static let shared = ImageCache()

    private var cache: [String: NSImage] = [:]
    private let maxCacheSize = 50 // Maximum number of images in cache

    private init() {}

    func getImage(forPath path: String) -> NSImage? {
        return cache[path]
    }

    func setImage(_ image: NSImage, forPath path: String) {
        // Remove oldest if cache is full
        if cache.count >= maxCacheSize {
            let firstKey = cache.keys.first
            if let key = firstKey {
                cache.removeValue(forKey: key)
            }
        }
        cache[path] = image
    }

    func clearCache() {
        cache.removeAll()
    }

    func cacheSize() -> Int {
        return cache.count
    }
}

// MARK: - Debouncer

class Debouncer {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }

    func cancel() {
        workItem?.cancel()
    }
}

// MARK: - Lazy Loading Helper

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

// MARK: - Cached Image View

struct CachedImageView: View {
    let imagePath: String
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forPath: imagePath) {
            image = cachedImage
            return
        }

        // Load from disk in background
        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedImage = NSImage(contentsOfFile: imagePath) {
                // Cache it
                ImageCache.shared.setImage(loadedImage, forPath: imagePath)

                DispatchQueue.main.async {
                    image = loadedImage
                }
            }
        }
    }
}

// MARK: - Performance Monitor Extension

extension PerformanceMonitor {
    /// Measure execution time of a block
    static func measure<T>(name: String, block: () -> T) -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = block()
        let end = CFAbsoluteTimeGetCurrent()
        let duration = (end - start) * 1000 // Convert to ms

        print("⏱️ \(name): \(String(format: "%.2f", duration))ms")
        return result
    }

    /// Async version
    static func measureAsync<T>(name: String, block: () async -> T) async -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = await block()
        let end = CFAbsoluteTimeGetCurrent()
        let duration = (end - start) * 1000

        print("⏱️ \(name): \(String(format: "%.2f", duration))ms")
        return result
    }
}

// MARK: - Batch Operations

struct BatchProcessor {
    static func processBatch<T>(items: [T], batchSize: Int = 50, processor: @escaping (T) -> Void) {
        let batches = items.chunked(into: batchSize)

        for batch in batches {
            DispatchQueue.global(qos: .userInitiated).async {
                batch.forEach(processor)
            }
        }
    }
}

// MARK: - Array Extension for Chunking

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Memory Monitor

class MemoryMonitor {
    static let shared = MemoryMonitor()

    private init() {}

    func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        return 0
    }

    func getFormattedMemoryUsage() -> String {
        let bytes = getCurrentMemoryUsage()
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1f MB", mb)
    }

    func logMemoryUsage(label: String = "") {
        let usage = getFormattedMemoryUsage()
        print("💾 Memory\(label.isEmpty ? "" : " [\(label)]"): \(usage)")
    }
}

// MARK: - View Extension for Performance

extension View {
    /// Add this to views to measure their render time
    func measurePerformance(label: String) -> some View {
        self.onAppear {
            print("🎨 View appeared: \(label)")
        }
    }

    /// Lazy load expensive views
    func lazyLoad() -> some View {
        LazyView(self)
    }
}

// MARK: - Search Optimization

class SearchOptimizer {
    private let debouncer = Debouncer(delay: 0.3)

    func debouncedSearch(query: String, action: @escaping (String) -> Void) {
        debouncer.debounce {
            action(query)
        }
    }

    func fuzzyMatch(query: String, in text: String) -> Bool {
        let queryLower = query.lowercased()
        let textLower = text.lowercased()

        // Exact match
        if textLower.contains(queryLower) {
            return true
        }

        // Fuzzy match - each character in query must appear in order
        var textIndex = textLower.startIndex
        for char in queryLower {
            guard let index = textLower[textIndex...].firstIndex(of: char) else {
                return false
            }
            textIndex = textLower.index(after: index)
        }
        return true
    }
}

// MARK: - Data Loading Optimization

actor DataLoader {
    private var loadingTasks: [String: Task<Void, Never>] = [:]

    func loadData(key: String, load: @escaping () async -> Void) async {
        // Cancel existing task if any
        loadingTasks[key]?.cancel()

        // Create new task
        let task = Task {
            await load()
        }

        loadingTasks[key] = task
        await task.value

        loadingTasks.removeValue(forKey: key)
    }

    func cancelAll() {
        for task in loadingTasks.values {
            task.cancel()
        }
        loadingTasks.removeAll()
    }
}

// MARK: - Pagination Helper

struct PaginationState {
    var currentPage: Int = 1
    var pageSize: Int = 50
    var totalItems: Int = 0
    var isLoading: Bool = false

    var totalPages: Int {
        (totalItems + pageSize - 1) / pageSize
    }

    var hasNextPage: Bool {
        currentPage < totalPages
    }

    var hasPreviousPage: Bool {
        currentPage > 1
    }

    var startIndex: Int {
        (currentPage - 1) * pageSize
    }

    var endIndex: Int {
        min(startIndex + pageSize, totalItems)
    }

    mutating func nextPage() {
        if hasNextPage {
            currentPage += 1
        }
    }

    mutating func previousPage() {
        if hasPreviousPage {
            currentPage -= 1
        }
    }

    mutating func reset() {
        currentPage = 1
        isLoading = false
    }
}

// MARK: - Throttler

class Throttler {
    private var lastExecutionTime: Date?
    private let minInterval: TimeInterval

    init(minInterval: TimeInterval) {
        self.minInterval = minInterval
    }

    func throttle(action: @escaping () -> Void) {
        let now = Date()

        if let lastTime = lastExecutionTime {
            let timeSinceLastExecution = now.timeIntervalSince(lastTime)
            if timeSinceLastExecution < minInterval {
                return // Skip execution
            }
        }

        lastExecutionTime = now
        action()
    }
}

// MARK: - Background Task Manager

actor BackgroundTaskManager {
    private var tasks: [UUID: Task<Void, Error>] = [:]

    func runTask(_ work: @escaping () async throws -> Void) -> UUID {
        let id = UUID()
        let task = Task {
            try await work()
        }
        tasks[id] = task
        return id
    }

    func cancelTask(id: UUID) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
    }

    func cancelAll() {
        for task in tasks.values {
            task.cancel()
        }
        tasks.removeAll()
    }

    func taskCount() -> Int {
        tasks.count
    }
}
