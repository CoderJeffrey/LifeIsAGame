import SwiftUI

// MARK: - Pixel Color Palette
struct PixelColors {
    // Main background colors
    static let darkPurple = Color(red: 0.15, green: 0.10, blue: 0.25)
    static let deepBlue = Color(red: 0.12, green: 0.15, blue: 0.30)
    static let midnightBlue = Color(red: 0.08, green: 0.10, blue: 0.20)

    // Accent colors
    static let neonPink = Color(red: 1.0, green: 0.30, blue: 0.50)
    static let neonCyan = Color(red: 0.20, green: 0.90, blue: 0.90)
    static let neonGreen = Color(red: 0.30, green: 1.0, blue: 0.40)
    static let neonYellow = Color(red: 1.0, green: 0.90, blue: 0.20)
    static let neonOrange = Color(red: 1.0, green: 0.55, blue: 0.20)

    // UI colors
    static let success = Color(red: 0.20, green: 0.85, blue: 0.40)
    static let danger = Color(red: 0.95, green: 0.30, blue: 0.35)
    static let warning = Color(red: 1.0, green: 0.75, blue: 0.20)

    // Tile colors for game board
    static let tileBlue = Color(red: 0.25, green: 0.45, blue: 0.75)
    static let tilePurple = Color(red: 0.55, green: 0.35, blue: 0.75)
    static let tileGreen = Color(red: 0.30, green: 0.65, blue: 0.45)
    static let tileOrange = Color(red: 0.85, green: 0.50, blue: 0.25)
    static let tilePink = Color(red: 0.85, green: 0.40, blue: 0.60)
    static let tileYellow = Color(red: 0.90, green: 0.80, blue: 0.30)
    static let tileCyan = Color(red: 0.30, green: 0.75, blue: 0.80)

    // Dice colors
    static let diceWhite = Color(red: 0.95, green: 0.95, blue: 0.92)
    static let diceDot = Color(red: 0.15, green: 0.15, blue: 0.20)

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.70, green: 0.70, blue: 0.80)
}

// MARK: - Pixel Text Style Modifier
struct PixelTextStyle: ViewModifier {
    var size: CGFloat
    var color: Color
    var shadowColor: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .shadow(color: shadowColor, radius: 0, x: 2, y: 2)
    }
}

extension View {
    func pixelText(size: CGFloat = 16, color: Color = PixelColors.textPrimary, shadow: Color = .black.opacity(0.5)) -> some View {
        modifier(PixelTextStyle(size: size, color: color, shadowColor: shadow))
    }
}

// MARK: - Pixel Border Modifier
struct PixelBorder: ViewModifier {
    var color: Color
    var width: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .stroke(color, lineWidth: width)
            )
            .overlay(
                Rectangle()
                    .stroke(color.opacity(0.5), lineWidth: width)
                    .offset(x: 2, y: 2)
            )
    }
}

extension View {
    func pixelBorder(color: Color = PixelColors.neonCyan, width: CGFloat = 3) -> some View {
        modifier(PixelBorder(color: color, width: width))
    }
}

// MARK: - Pixel Button Style
struct PixelButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var pressedScale: CGFloat

    init(backgroundColor: Color = PixelColors.neonPink,
         foregroundColor: Color = .white,
         pressedScale: CGFloat = 0.95) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.pressedScale = pressedScale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // Shadow layer
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .offset(x: 4, y: 4)

                    // Main button
                    Rectangle()
                        .fill(backgroundColor)

                    // Highlight
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )

                    // Border
                    Rectangle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                }
            )
            .foregroundColor(foregroundColor)
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Glowing Effect
struct GlowEffect: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius)
            .shadow(color: color.opacity(0.5), radius: radius * 2)
    }
}

extension View {
    func glow(color: Color = PixelColors.neonCyan, radius: CGFloat = 5) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Scanline Effect
struct ScanlineEffect: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                ForEach(0..<Int(geometry.size.height / 4), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                    Spacer()
                        .frame(height: 3)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Animated Background
struct PixelBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                PixelColors.darkPurple,
                PixelColors.deepBlue,
                PixelColors.midnightBlue
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
        .overlay(ScanlineEffect().opacity(0.3))
    }
}

// MARK: - Pixel Grid Pattern
struct PixelGridPattern: View {
    let gridSize: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let columns = Int(geometry.size.width / gridSize) + 1
                let rows = Int(geometry.size.height / gridSize) + 1

                for col in 0...columns {
                    let x = CGFloat(col) * gridSize
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }

                for row in 0...rows {
                    let y = CGFloat(row) * gridSize
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
