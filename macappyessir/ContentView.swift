//
//  ContentView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/1/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var showCommandPalette = false

    var body: some View {
        ZStack(alignment: .top) {
            mainContent

            // Toast notification
            if appState.toastManager.showToast {
                toastNotification
            }

            // Command Palette (⌘K)
            if showCommandPalette {
                CommandPalette(isPresented: $showCommandPalette)
                    .transition(.opacity)
            }
        }
        .onAppear {
            setupKeyboardShortcuts()
        }
        .animation(.easeInOut(duration: 0.2), value: showCommandPalette)
    }

    private var mainContent: some View {
        HStack(spacing: 0) {
            // Main content area
            Group {
                switch appState.selectedItem {
                case .dashboard:
                    EnhancedDashboardView()
                case .newEstimate:
                    NewEstimateView()
                case .activeJobs:
                    ActiveJobsView()
                case .completed:
                    CompletedJobsView()
                case .settings:
                    SettingsView()
                case .none:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            RightSidebar()
                .frame(width: 70)
        }
    }

    private var toastNotification: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: appState.toastManager.toastIcon)
                    .font(.title3)
                    .foregroundColor(.white)

                Text(appState.toastManager.toastMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.green)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
        .padding(.top, 20)
    }

    private func setupKeyboardShortcuts() {
        // Set up global keyboard monitor for ⌘K
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Command+K for command palette
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "k" {
                showCommandPalette.toggle()
                return nil
            }
            // Command+N for new estimate
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "n" {
                appState.selectedItem = .newEstimate
                return nil
            }
            // Command+1-5 for navigation
            if event.modifierFlags.contains(.command) {
                switch event.charactersIgnoringModifiers {
                case "1": appState.selectedItem = .dashboard; return nil
                case "2": appState.selectedItem = .newEstimate; return nil
                case "3": appState.selectedItem = .activeJobs; return nil
                case "4": appState.selectedItem = .completed; return nil
                case "5", ",": appState.selectedItem = .settings; return nil
                default: break
                }
            }
            return event
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
