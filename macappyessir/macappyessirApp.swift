//
//  macappyessirApp.swift
//  macappyessir
//
//  Created by Jay Vora on 2/1/26.
//

import SwiftUI

@main
struct macappyessirApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .focusedSceneValue(\.appState, $appState)
                .preferredColorScheme(appState.theme.colorScheme)
        }
        .commands {
            AppCommands()
        }
        .defaultSize(width: 1200, height: 800)
    }
}
