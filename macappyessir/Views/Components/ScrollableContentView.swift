//
//  ScrollableContentView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//

import SwiftUI

struct ScrollableContentView<Content: View>: View {
    let content: Content
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollButtons = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ZStack(alignment: .bottomTrailing) {
                    // Standard SwiftUI ScrollView
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0) {
                            // Top anchor
                            Color.clear
                                .frame(height: 1)
                                .id("scrollTop")

                            content

                            // Bottom anchor
                            Color.clear
                                .frame(height: 1)
                                .id("scrollBottom")
                        }
                        .background(
                            GeometryReader { contentGeometry in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: contentGeometry.frame(in: .named("scrollSpace")).minY
                                    )
                            }
                        )
                    }
                    .coordinateSpace(name: "scrollSpace")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        showScrollButtons = abs(value) > 100
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScrollToTop"))) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scrollProxy.scrollTo("scrollTop", anchor: .top)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScrollToBottom"))) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scrollProxy.scrollTo("scrollBottom", anchor: .bottom)
                        }
                    }
                    .background(KeyboardScrollHandler())

                    // Scroll buttons overlay
                    if showScrollButtons {
                        VStack(spacing: 12) {
                            ScrollButton(
                                icon: "arrow.up",
                                tooltip: "Scroll to Top (⌘↑)"
                            ) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    scrollProxy.scrollTo("scrollTop", anchor: .top)
                                }
                            }

                            ScrollButton(
                                icon: "arrow.down",
                                tooltip: "Scroll to Bottom (⌘↓)"
                            ) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    scrollProxy.scrollTo("scrollBottom", anchor: .bottom)
                                }
                            }
                        }
                        .padding(24)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
}

// Scroll button component
struct ScrollButton: View {
    let icon: String
    let tooltip: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: .black.opacity(isHovered ? 0.3 : 0.2), radius: isHovered ? 10 : 8, x: 0, y: 2)
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isHovered ? .blue.opacity(0.8) : .blue)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .help(tooltip)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// Keyboard handler for arrow key scrolling
struct KeyboardScrollHandler: NSViewRepresentable {
    func makeNSView(context: Context) -> KeyHandlerView {
        let view = KeyHandlerView()
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyHandlerView, context: Context) {}

    class KeyHandlerView: NSView {
        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 126, 125, 116, 121, 115, 119: // Arrow keys, Page Up/Down, Home/End
                // Let the scroll view handle these
                super.keyDown(with: event)
            default:
                super.keyDown(with: event)
            }
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            window?.makeFirstResponder(self)
        }
    }
}

// Preference key for scroll offset tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ScrollableContentView {
        VStack(spacing: 20) {
            ForEach(0..<50) { i in
                Text("Item \(i)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
