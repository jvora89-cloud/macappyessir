//
//  KeyboardShortcutsView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct KeyboardShortcutsView: View {
    @Environment(\.dismiss) var dismiss

    let shortcuts = [
        ShortcutSection(title: "Navigation", shortcuts: [
            Shortcut(key: "⌘1", description: "Go to Dashboard"),
            Shortcut(key: "⌘2", description: "New Estimate"),
            Shortcut(key: "⌘3", description: "Active Jobs"),
            Shortcut(key: "⌘4", description: "Completed Jobs"),
            Shortcut(key: "⌘,", description: "Settings")
        ]),
        ShortcutSection(title: "Actions", shortcuts: [
            Shortcut(key: "⌘N", description: "New Estimate"),
            Shortcut(key: "⌘S", description: "Save"),
            Shortcut(key: "⌘E", description: "Export PDF"),
            Shortcut(key: "⌘F", description: "Find Jobs")
        ]),
        ShortcutSection(title: "General", shortcuts: [
            Shortcut(key: "⌘Q", description: "Quit QuoteHub"),
            Shortcut(key: "⌘W", description: "Close Window"),
            Shortcut(key: "⌘M", description: "Minimize"),
            Shortcut(key: "⌘?", description: "Help")
        ])
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(shortcuts) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            VStack(spacing: 8) {
                                ForEach(section.shortcuts) { shortcut in
                                    HStack {
                                        Text(shortcut.description)
                                            .font(.subheadline)

                                        Spacer()

                                        Text(shortcut.key)
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(Color(nsColor: .controlBackgroundColor))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct ShortcutSection: Identifiable {
    let id = UUID()
    let title: String
    let shortcuts: [Shortcut]
}

struct Shortcut: Identifiable {
    let id = UUID()
    let key: String
    let description: String
}

#Preview {
    KeyboardShortcutsView()
}
