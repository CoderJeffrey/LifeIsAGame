import SwiftUI

// MARK: - Dice Mode
enum DiceMode {
    case success  // Made It - completed mission - rolls 3,4,4,5,5,6 (higher values as reward)
    case failure  // Not Today - didn't complete - rolls 1,1,1,2,2,2 (lower values as penalty)

    var possibleValues: [Int] {
        switch self {
        case .success:
            return [3, 4, 4, 5, 5, 6] // Higher rolls: 3 once, 4 twice, 5 twice, 6 once
        case .failure:
            return [1, 1, 1, 2, 2, 2] // Lower rolls: 1 and 2, each appearing 3 times
        }
    }

    var diceColor: Color {
        switch self {
        case .success:
            return PixelColors.neonGreen
        case .failure:
            return PixelColors.neonOrange
        }
    }

    var glowColor: Color {
        switch self {
        case .success:
            return PixelColors.neonGreen
        case .failure:
            return PixelColors.neonOrange
        }
    }

    var displayRange: String {
        switch self {
        case .success:
            return "3-6"
        case .failure:
            return "1-2"
        }
    }
}

// MARK: - Dice Face View
struct DiceFaceView: View {
    let value: Int
    let size: CGFloat

    private var dotSize: CGFloat { size * 0.15 }
    private var dotSpacing: CGFloat { size * 0.25 }

    var body: some View {
        ZStack {
            // Dice background
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(PixelColors.diceWhite)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 3, y: 3)

            // Inner shadow/depth effect
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(
                    LinearGradient(
                        colors: [.white, Color(white: 0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(3)

            // Border
            RoundedRectangle(cornerRadius: size * 0.1)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)

            // Dots
            dotsForValue(value)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func dotsForValue(_ value: Int) -> some View {
        let dot = Circle()
            .fill(PixelColors.diceDot)
            .frame(width: dotSize, height: dotSize)

        switch value {
        case 1:
            dot
        case 2:
            VStack(spacing: dotSpacing * 2) {
                HStack {
                    dot
                    Spacer()
                }
                HStack {
                    Spacer()
                    dot
                }
            }
            .padding(size * 0.2)
        case 3:
            VStack(spacing: dotSpacing) {
                HStack {
                    dot
                    Spacer()
                }
                dot
                HStack {
                    Spacer()
                    dot
                }
            }
            .padding(size * 0.2)
        case 4:
            VStack(spacing: dotSpacing) {
                HStack(spacing: dotSpacing) {
                    dot
                    Spacer()
                    dot
                }
                Spacer()
                HStack(spacing: dotSpacing) {
                    dot
                    Spacer()
                    dot
                }
            }
            .padding(size * 0.2)
        case 5:
            VStack(spacing: dotSpacing * 0.5) {
                HStack {
                    dot
                    Spacer()
                    dot
                }
                dot
                HStack {
                    dot
                    Spacer()
                    dot
                }
            }
            .padding(size * 0.2)
        case 6:
            VStack(spacing: dotSpacing * 0.3) {
                HStack {
                    dot
                    Spacer()
                    dot
                }
                HStack {
                    dot
                    Spacer()
                    dot
                }
                HStack {
                    dot
                    Spacer()
                    dot
                }
            }
            .padding(size * 0.2)
        default:
            EmptyView()
        }
    }
}

// MARK: - Animated Dice View
struct PixelDiceView: View {
    let mode: DiceMode
    @Binding var isRolling: Bool
    @Binding var finalValue: Int?
    let onRollComplete: (Int) -> Void

    @State private var displayValue: Int = 1
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var bounce: CGFloat = 0

    private let diceSize: CGFloat = 120

    var body: some View {
        VStack(spacing: 20) {
            // Dice container
            ZStack {
                // Mode-specific glow effect when rolling
                if isRolling {
                    // Outer pulse glow
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            RadialGradient(
                                colors: [
                                    mode.glowColor.opacity(0.6),
                                    mode.glowColor.opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: diceSize * 1.8, height: diceSize * 1.8)
                        .blur(radius: 15)

                    // Inner intense glow
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    mode.glowColor.opacity(0.3),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: diceSize * 1.3, height: diceSize * 1.3)
                        .blur(radius: 8)
                }

                // Result glow when finished
                if finalValue != nil {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            RadialGradient(
                                colors: [
                                    mode.glowColor.opacity(0.5),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: diceSize * 1.5, height: diceSize * 1.5)
                        .blur(radius: 12)
                }

                // The dice with mode-colored border highlight
                ZStack {
                    DiceFaceView(value: displayValue, size: diceSize)

                    // Mode-colored overlay border when rolling
                    if isRolling || finalValue != nil {
                        RoundedRectangle(cornerRadius: diceSize * 0.1)
                            .stroke(mode.diceColor.opacity(0.7), lineWidth: 3)
                            .frame(width: diceSize, height: diceSize)
                            .blur(radius: 2)
                    }
                }
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 1, y: 1, z: 0)
                )
                .scaleEffect(scale)
                .offset(y: bounce)
            }
            .onTapGesture {
                if !isRolling && finalValue == nil {
                    rollDice()
                }
            }

            // Roll instruction
            if !isRolling && finalValue == nil {
                Text("TAP TO ROLL!")
                    .pixelText(size: 18, color: PixelColors.neonYellow)
                    .glow(color: PixelColors.neonYellow, radius: 5)
            }

            // Result display
            if let result = finalValue {
                VStack(spacing: 8) {
                    Text("YOU ROLLED")
                        .pixelText(size: 14, color: PixelColors.textSecondary)

                    Text("\(result)")
                        .pixelText(size: 48, color: mode.diceColor)
                        .glow(color: mode.glowColor, radius: 8)

                    Text(mode == .success ? "GREAT JOB! 🎉" : "KEEP TRYING! 💪")
                        .pixelText(size: 16, color: .white)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func rollDice() {
        isRolling = true
        let possibleValues = mode.possibleValues

        // Rolling animation
        let rollDuration: Double = 2.0
        let rollSteps = 20

        for i in 0..<rollSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (rollDuration / Double(rollSteps)) * Double(i)) {
                // Random value during roll
                displayValue = possibleValues.randomElement() ?? 1

                // Rotation animation
                withAnimation(.easeInOut(duration: 0.1)) {
                    rotation += Double.random(in: 30...90)
                    scale = CGFloat.random(in: 0.9...1.1)
                    bounce = CGFloat.random(in: -10...10)
                }
            }
        }

        // Final result
        DispatchQueue.main.asyncAfter(deadline: .now() + rollDuration) {
            let result = possibleValues.randomElement() ?? 1
            displayValue = result

            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                rotation = 0
                scale = 1.2
                bounce = -20
            }

            // Bounce back
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scale = 1.0
                    bounce = 0
                }
            }

            // Show result
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    finalValue = result
                    isRolling = false
                }
                onRollComplete(result)
            }
        }
    }
}

// MARK: - Dice Overlay View (Full screen modal)
struct DiceOverlayView: View {
    let mode: DiceMode
    @Binding var isPresented: Bool
    @Binding var rollResult: Int?
    let onComplete: (Int) -> Void

    @State private var isRolling = false
    @State private var finalValue: Int? = nil
    @State private var showContinueButton = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { } // Prevent dismiss on tap

            // Mode-specific particle effects
            if isRolling {
                ParticleEffectView(mode: mode)
            }

            VStack(spacing: 30) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("🎲 ROLL THE DICE 🎲")
                        .pixelText(size: 24, color: PixelColors.neonCyan)
                        .glow(color: PixelColors.neonCyan, radius: 5)

                    Text(mode == .success ?
                         "🏆 Reward mode: \(mode.displayRange)!" :
                         "⚠️ Penalty mode: \(mode.displayRange)")
                        .pixelText(size: 12, color: mode.diceColor)
                        .glow(color: mode.glowColor, radius: 3)
                }

                Spacer()

                // Dice
                PixelDiceView(
                    mode: mode,
                    isRolling: $isRolling,
                    finalValue: $finalValue
                ) { result in
                    rollResult = result
                    withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                        showContinueButton = true
                    }
                }

                Spacer()

                // Continue button
                if showContinueButton {
                    Button(action: {
                        if let result = finalValue {
                            onComplete(result)
                        }
                        isPresented = false
                    }) {
                        HStack {
                            Text("CONTINUE")
                                .pixelText(size: 18)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelColors.neonCyan))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                    .frame(height: 50)
            }
            .padding()
        }
    }
}

// MARK: - Particle Effect View
struct ParticleEffectView: View {
    let mode: DiceMode
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var opacity: Double
        var velocityY: CGFloat
        var velocityX: CGFloat
        var rotation: Double
    }

    // Mode-specific color palettes
    private var particleColors: [Color] {
        switch mode {
        case .success:
            return [
                PixelColors.neonGreen,
                PixelColors.neonGreen.opacity(0.7),
                PixelColors.neonCyan,
                Color.white,
                PixelColors.neonYellow
            ]
        case .failure:
            return [
                PixelColors.neonOrange,
                PixelColors.neonOrange.opacity(0.7),
                PixelColors.neonPink,
                Color.white,
                PixelColors.neonYellow
            ]
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    // Mix of shapes for variety
                    Group {
                        if particle.size > 8 {
                            // Larger particles as diamonds
                            Rectangle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .rotationEffect(.degrees(particle.rotation))
                        } else if particle.size > 5 {
                            // Medium particles as circles
                            Circle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                        } else {
                            // Small particles as dots with glow
                            Circle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .blur(radius: 1)
                        }
                    }
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                }
            }
        }
        .onAppear {
            createParticles()
        }
    }

    private func createParticles() {
        // Create initial burst of particles
        for _ in 0..<40 {
            let particle = Particle(
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: 200...600),
                size: CGFloat.random(in: 3...14),
                color: particleColors.randomElement() ?? .white,
                opacity: Double.random(in: 0.4...0.9),
                velocityY: CGFloat.random(in: 3...10),
                velocityX: CGFloat.random(in: -4...4),
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }

        // Animate particles with more dynamic movement
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            withAnimation(.linear(duration: 0.05)) {
                for i in 0..<particles.count {
                    // Move particles upward with slight horizontal drift
                    particles[i].y -= particles[i].velocityY
                    particles[i].x += particles[i].velocityX

                    // Add slight oscillation
                    particles[i].velocityX += CGFloat.random(in: -0.5...0.5)

                    // Rotate diamond particles
                    particles[i].rotation += Double.random(in: 5...15)

                    // Fade out gradually
                    particles[i].opacity -= 0.015

                    // Respawn particles that fade out or go off screen
                    if particles[i].opacity <= 0 || particles[i].y < 0 {
                        particles[i].y = CGFloat.random(in: 650...800)
                        particles[i].x = CGFloat.random(in: 50...350)
                        particles[i].opacity = Double.random(in: 0.4...0.9)
                        particles[i].size = CGFloat.random(in: 3...14)
                        particles[i].color = particleColors.randomElement() ?? .white
                        particles[i].velocityY = CGFloat.random(in: 3...10)
                        particles[i].velocityX = CGFloat.random(in: -4...4)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        PixelBackground()

        VStack(spacing: 40) {
            DiceFaceView(value: 1, size: 80)
            DiceFaceView(value: 5, size: 80)
        }
    }
}

#Preview("Dice Overlay") {
    DiceOverlayView(
        mode: .success,
        isPresented: .constant(true),
        rollResult: .constant(nil)
    ) { _ in }
}
