//
//  RightSidebar.swift
//  macappyessir
//
//  Created by Jay Vora on 2/1/26.
//

import SwiftUI

struct RightSidebar: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 8) {
            ForEach(NavigationItem.allCases) { item in
                Button(action: {
                    appState.selectedItem = item
                }) {
                    Image(systemName: item.icon)
                        .font(.system(size: 22))
                        .frame(width: 44, height: 44)
                        .background(
                            appState.selectedItem == item
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help(item.title)
                .accessibilityLabel(item.title)
                .accessibilityHint("Navigate to \(item.title)")
                .accessibilityAddTraits(appState.selectedItem == item ? [.isButton, .isSelected] : .isButton)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .frame(width: 70)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

#Preview {
    RightSidebar()
        .environment(AppState())
}
