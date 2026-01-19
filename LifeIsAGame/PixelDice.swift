import SwiftUI

// MARK: - Dice Mode
enum DiceMode {
    case success // Made it - shows 1 or 2 only
    case failure // Not doing it - shows 3, 4, 5, 6 (4 and 5 appear twice)

    var possibleValues: [Int] {
        switch self {
        case .success:
            return [1, 2, 1, 2, 1, 2] // Only 1s and 2s
        case .failure:
            return [3, 4, 4, 5, 5, 6] // 3, 4, 4, 5, 5, 6 (4 and 5 twice)
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
                // Glow effect when rolling
                if isRolling {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            RadialGradient(
                                colors: [
                                    PixelColors.neonYellow.opacity(0.5),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: diceSize * 1.5, height: diceSize * 1.5)
                        .blur(radius: 10)
                }

                // The dice
                DiceFaceView(value: displayValue, size: diceSize)
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
                        .pixelText(size: 48, color: mode == .success ? PixelColors.neonGreen : PixelColors.neonOrange)
                        .glow(color: mode == .success ? PixelColors.neonGreen : PixelColors.neonOrange, radius: 8)

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

            // Particle effects
            if isRolling {
                ParticleEffectView()
            }

            VStack(spacing: 30) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("🎲 ROLL THE DICE 🎲")
                        .pixelText(size: 24, color: PixelColors.neonCyan)
                        .glow(color: PixelColors.neonCyan, radius: 5)

                    Text(mode == .success ?
                         "Success mode: 1-2 only!" :
                         "Penalty mode: 3-6 only!")
                        .pixelText(size: 12, color: mode == .success ? PixelColors.neonGreen : PixelColors.neonOrange)
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
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var opacity: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
        }
    }

    private func createParticles() {
        let colors: [Color] = [
            PixelColors.neonPink,
            PixelColors.neonCyan,
            PixelColors.neonYellow,
            PixelColors.neonGreen
        ]

        for _ in 0..<30 {
            let particle = Particle(
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: 100...700),
                size: CGFloat.random(in: 4...12),
                color: colors.randomElement() ?? .white,
                opacity: Double.random(in: 0.3...0.8)
            )
            particles.append(particle)
        }

        // Animate particles
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation(.linear(duration: 0.1)) {
                for i in 0..<particles.count {
                    particles[i].y -= CGFloat.random(in: 2...8)
                    particles[i].x += CGFloat.random(in: -3...3)
                    particles[i].opacity -= 0.02

                    if particles[i].opacity <= 0 || particles[i].y < 0 {
                        particles[i].y = CGFloat.random(in: 600...800)
                        particles[i].opacity = Double.random(in: 0.3...0.8)
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
