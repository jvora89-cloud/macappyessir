//
//  AppCommands.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct AppCommands: Commands {
    @FocusedBinding(\.appState) var appState

    var body: some Commands {
        // Replace default "New Window" command with our actions
        CommandGroup(replacing: .newItem) {
            Button("New Estimate") {
                appState?.selectedItem = .newEstimate
            }
            .keyboardShortcut("n", modifiers: .command)
        }

        // File menu additions
        CommandGroup(after: .newItem) {
            Button("Save") {
                // Jobs auto-save, but this provides user feedback
                NotificationCenter.default.post(name: NSNotification.Name("SaveTriggered"), object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)

            Divider()

            Button("Export Estimate as PDF...") {
                // Will implement in Step 4
                print("Export PDF - Coming in Step 4")
            }
            .keyboardShortcut("e", modifiers: .command)
            .disabled(true)
        }

        // Edit menu
        CommandGroup(after: .pasteboard) {
            Divider()

            Button("Find Jobs...") {
                appState?.selectedItem = .activeJobs
                NotificationCenter.default.post(name: NSNotification.Name("FocusSearch"), object: nil)
            }
            .keyboardShortcut("f", modifiers: .command)
        }

        // View menu
        CommandMenu("View") {
            Button("Dashboard") {
                appState?.selectedItem = .dashboard
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("New Estimate") {
                appState?.selectedItem = .newEstimate
            }
            .keyboardShortcut("2", modifiers: .command)

            Button("Active Jobs") {
                appState?.selectedItem = .activeJobs
            }
            .keyboardShortcut("3", modifiers: .command)

            Button("Completed Jobs") {
                appState?.selectedItem = .completed
            }
            .keyboardShortcut("4", modifiers: .command)

            Divider()

            Button("Scroll to Top") {
                NotificationCenter.default.post(name: NSNotification.Name("ScrollToTop"), object: nil)
            }
            .keyboardShortcut(.upArrow, modifiers: [.command])

            Button("Scroll to Bottom") {
                NotificationCenter.default.post(name: NSNotification.Name("ScrollToBottom"), object: nil)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command])

            Divider()

            Button("Settings") {
                appState?.selectedItem = .settings
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        // Help menu additions
        CommandGroup(replacing: .help) {
            Button("QuoteHub Help") {
                if let url = URL(string: "https://proestimate.app/help") {
                    NSWorkspace.shared.open(url)
                }
            }
            .keyboardShortcut("?", modifiers: .command)

            Button("Contact Support") {
                if let url = URL(string: "mailto:support@proestimate.app") {
                    NSWorkspace.shared.open(url)
                }
            }

            Divider()

            Button("Show Data Directory") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: DataManager.shared.getDataDirectoryPath())
            }

            Button("Show Photos Directory") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: DataManager.shared.getPhotosDirectoryPath())
            }
        }
    }
}

// FocusedValue key for AppState
struct AppStateFocusedValueKey: FocusedValueKey {
    typealias Value = Binding<AppState>
}

extension FocusedValues {
    var appState: Binding<AppState>? {
        get { self[AppStateFocusedValueKey.self] }
        set { self[AppStateFocusedValueKey.self] = newValue }
    }
}
