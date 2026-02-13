//
//  AnimationSystem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Comprehensive animation and transition system
//

import SwiftUI

// MARK: - Animation Presets

extension Animation {
    static let smooth = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let gentle = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeOut(duration: 0.2)
}

// MARK: - View Modifiers

extension View {
    /// Adds a smooth scale animation on hover
    func hoverScale(scale: CGFloat = 1.05) -> some View {
        modifier(HoverScaleModifier(scale: scale))
    }

    /// Adds a subtle lift effect on hover
    func hoverLift() -> some View {
        modifier(HoverLiftModifier())
    }

    /// Fades in when view appears
    func fadeInOnAppear(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }

    /// Slides in from direction
    func slideIn(from edge: Edge = .leading, distance: CGFloat = 20, delay: Double = 0) -> some View {
        modifier(SlideInModifier(edge: edge, distance: distance, delay: delay))
    }

    /// Bounces in with spring animation
    func bounceIn(delay: Double = 0) -> some View {
        modifier(BounceInModifier(delay: delay))
    }

    /// Shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }

    /// Success animation (scale + checkmark)
    func successPulse(isActive: Bool) -> some View {
        modifier(SuccessPulseModifier(isActive: isActive))
    }

    /// Shake animation for errors
    func shake(times: Int = 2) -> some View {
        modifier(ShakeModifier(times: times))
    }
}

// MARK: - Hover Scale Modifier

struct HoverScaleModifier: ViewModifier {
    let scale: CGFloat
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(.smooth, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Hover Lift Modifier

struct HoverLiftModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .offset(y: isHovered ? -2 : 0)
            .shadow(
                color: isHovered ? .black.opacity(0.15) : .black.opacity(0.05),
                radius: isHovered ? 8 : 2,
                y: isHovered ? 4 : 1
            )
            .animation(.smooth, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Fade In Modifier

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.gentle.delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Slide In Modifier

struct SlideInModifier: ViewModifier {
    let edge: Edge
    let distance: CGFloat
    let delay: Double
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? offset : (edge == .trailing ? -offset : 0),
                y: edge == .top ? offset : (edge == .bottom ? -offset : 0)
            )
            .opacity(offset == 0 ? 1 : 0)
            .onAppear {
                offset = distance
                withAnimation(.smooth.delay(delay)) {
                    offset = 0
                }
            }
    }
}

// MARK: - Bounce In Modifier

struct BounceInModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.bouncy.delay(delay)) {
                    scale = 1
                }
            }
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                            .mask(content)
                    }
                }
            )
            .onAppear {
                if isActive {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
            }
    }
}

// MARK: - Success Pulse Modifier

struct SuccessPulseModifier: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        scale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            scale = 1.0
                        }
                    }
                }
            }
    }
}

// MARK: - Shake Modifier

struct ShakeModifier: ViewModifier {
    let times: Int
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onAppear {
                let duration = 0.1
                for i in 0..<times {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * duration * 2) {
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = 10
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation(.easeInOut(duration: duration)) {
                                offset = 0
                            }
                        }
                    }
                }
            }
    }
}

// MARK: - Page Transition

enum PageTransition {
    case fade
    case slide
    case scale
    case push

    var insertion: AnyTransition {
        switch self {
        case .fade:
            return .opacity
        case .slide:
            return .move(edge: .trailing).combined(with: .opacity)
        case .scale:
            return .scale.combined(with: .opacity)
        case .push:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        }
    }

    var removal: AnyTransition {
        switch self {
        case .fade:
            return .opacity
        case .slide:
            return .move(edge: .leading).combined(with: .opacity)
        case .scale:
            return .scale.combined(with: .opacity)
        case .push:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        }
    }
}

// MARK: - Animated Card

struct AnimatedCard<Content: View>: View {
    let content: Content
    @State private var isVisible = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .hoverLift()
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.smooth) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Loading Animation Views

struct AnimatedPulsingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct RotatingCircle: View {
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.blue, lineWidth: 3)
            .frame(width: 30, height: 30)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct SuccessCheckmark: View {
    @State private var show = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green)
                .frame(width: 60, height: 60)
                .scaleEffect(show ? 1 : 0)

            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(show ? 1 : 0)
        }
        .onAppear {
            withAnimation(.bouncy.delay(0.1)) {
                show = true
            }
        }
    }
}

// MARK: - Transition Container

struct TransitionContainer<Content: View>: View {
    let content: Content
    let transition: PageTransition
    @Binding var id: AnyHashable

    init(id: Binding<AnyHashable>, transition: PageTransition = .fade, @ViewBuilder content: () -> Content) {
        self._id = id
        self.transition = transition
        self.content = content()
    }

    var body: some View {
        content
            .id(id)
            .transition(transition.insertion)
            .animation(.smooth, value: id)
    }
}

// MARK: - Staggered Animation

struct StaggeredAnimation<Content: View>: View {
    let items: [AnyHashable]
    let content: (AnyHashable, Int) -> Content
    let delay: Double

    init(items: [AnyHashable], delay: Double = 0.1, @ViewBuilder content: @escaping (AnyHashable, Int) -> Content) {
        self.items = items
        self.delay = delay
        self.content = content
    }

    var body: some View {
        ForEach(Array(items.enumerated()), id: \.element) { index, item in
            content(item, index)
                .fadeInOnAppear(delay: Double(index) * delay)
        }
    }
}

// MARK: - Interactive Button

struct InteractiveButton<Label: View>: View {
    let action: () -> Void
    let label: Label

    @State private var isPressed = false

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.smooth, value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }) {
            // Won't be called
        }
    }
}

// MARK: - Skeleton Loading

struct SkeletonView: View {
    @State private var animating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.5),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: animating ? 500 : -500)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
    }
}

// MARK: - Number Counter Animation

struct AnimatedCounter: View {
    let value: Double
    let formatter: NumberFormatter

    @State private var displayValue: Double = 0

    init(value: Double, formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()) {
        self.value = value
        self.formatter = formatter
    }

    var body: some View {
        Text(formatter.string(from: NSNumber(value: displayValue)) ?? "0")
            .onAppear {
                withAnimation(.smooth.speed(0.5)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.smooth) {
                    displayValue = newValue
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("Hover Effects")
            .font(.headline)

        HStack(spacing: 20) {
            Text("Scale")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .hoverScale()

            Text("Lift")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .hoverLift()
        }

        Text("Loading States")
            .font(.headline)

        HStack(spacing: 40) {
            AnimatedPulsingDots()
            RotatingCircle()
            SuccessCheckmark()
        }

        Text("Skeleton Loading")
            .font(.headline)

        SkeletonView()
            .frame(height: 60)
            .padding()

        Text("Animated Counter")
            .font(.headline)

        AnimatedCounter(value: 12345)
            .font(.largeTitle)
    }
    .padding()
}
