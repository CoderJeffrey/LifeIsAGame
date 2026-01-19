import SwiftUI

// MARK: - Report Progress Button
struct ReportProgressButton: View {
    let action: () -> Void
    @State private var isAnimating = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(PixelColors.neonYellow)
                        .frame(width: 40, height: 40)

                    Text("📋")
                        .font(.system(size: 22))
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("REPORT PROGRESS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Did you complete today's mission?")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(PixelColors.textSecondary)
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(PixelColors.neonCyan)
                    .font(.system(size: 16, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // Shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .offset(x: 4, y: 4)

                    // Main background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    PixelColors.neonPink.opacity(0.3),
                                    PixelColors.deepBlue.opacity(0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Border
                    Rectangle()
                        .stroke(PixelColors.neonPink, lineWidth: 2)

                    // Animated glow
                    Rectangle()
                        .stroke(
                            PixelColors.neonPink.opacity(isAnimating ? 0.8 : 0.3),
                            lineWidth: 3
                        )
                        .blur(radius: isAnimating ? 8 : 4)
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Progress Choice Modal
struct ProgressChoiceModal: View {
    @Binding var isPresented: Bool
    let missionTitle: String
    let onChoice: (Bool) -> Void // true = made it, false = not doing it

    @State private var selectedChoice: Bool? = nil
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 40, height: 40)

                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Question
                VStack(spacing: 16) {
                    Text("🎯 TODAY'S MISSION")
                        .pixelText(size: 14, color: PixelColors.neonCyan)

                    Text(missionTitle)
                        .pixelText(size: 20, color: .white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text("Did you complete it?")
                        .pixelText(size: 16, color: PixelColors.textSecondary)
                        .padding(.top, 10)
                }

                Spacer()

                // Choice buttons
                VStack(spacing: 20) {
                    // Made it button (Green)
                    ChoiceButton(
                        title: "MADE IT!",
                        subtitle: "I completed the mission",
                        emoji: "✅",
                        color: PixelColors.success,
                        isSelected: selectedChoice == true
                    ) {
                        withAnimation(.spring()) {
                            selectedChoice = true
                        }
                        triggerChoice(true)
                    }

                    // Not doing it button (Red)
                    ChoiceButton(
                        title: "NOT TODAY",
                        subtitle: "I didn't do it",
                        emoji: "❌",
                        color: PixelColors.danger,
                        isSelected: selectedChoice == false
                    ) {
                        withAnimation(.spring()) {
                            selectedChoice = false
                        }
                        triggerChoice(false)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Info text - Dice rules explanation
                VStack(spacing: 12) {
                    Text("🎲 DICE RULES")
                        .pixelText(size: 14, color: PixelColors.neonYellow)
                        .glow(color: PixelColors.neonYellow, radius: 3)

                    HStack(spacing: 24) {
                        // Made it - Higher rolls (reward)
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Text("✅")
                                    .font(.system(size: 16))
                                Text("MADE IT")
                                    .pixelText(size: 11, color: PixelColors.neonGreen)
                            }

                            // Mini dice faces showing 3,4,5,6
                            HStack(spacing: 3) {
                                ForEach([3, 4, 5, 6], id: \.self) { value in
                                    MiniDiceFace(value: value, color: PixelColors.neonGreen)
                                }
                            }

                            Text("Roll 3-6")
                                .pixelText(size: 10, color: PixelColors.neonGreen.opacity(0.8))
                            Text("Move further!")
                                .pixelText(size: 8, color: PixelColors.textSecondary)
                        }

                        // Divider
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color.white.opacity(0.3), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 1, height: 60)

                        // Not today - Lower rolls (penalty)
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Text("❌")
                                    .font(.system(size: 16))
                                Text("NOT TODAY")
                                    .pixelText(size: 11, color: PixelColors.neonOrange)
                            }

                            // Mini dice faces showing 1,2
                            HStack(spacing: 3) {
                                ForEach([1, 2], id: \.self) { value in
                                    MiniDiceFace(value: value, color: PixelColors.neonOrange)
                                }
                            }

                            Text("Roll 1-2")
                                .pixelText(size: 10, color: PixelColors.neonOrange.opacity(0.8))
                            Text("Small steps")
                                .pixelText(size: 8, color: PixelColors.textSecondary)
                        }
                    }
                }
                .padding(20)
                .background(
                    ZStack {
                        Rectangle()
                            .fill(PixelColors.midnightBlue.opacity(0.8))

                        Rectangle()
                            .stroke(
                                LinearGradient(
                                    colors: [PixelColors.neonGreen.opacity(0.4), PixelColors.neonOrange.opacity(0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    }
                )

                Spacer()
                    .frame(height: 30)
            }
        }
    }

    private func triggerChoice(_ choice: Bool) {
        // Small delay before proceeding to dice roll
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onChoice(choice)
        }
    }
}

// MARK: - Choice Button
struct ChoiceButton: View {
    let title: String
    let subtitle: String
    let emoji: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Emoji
                ZStack {
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Text(emoji)
                        .font(.system(size: 30))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(PixelColors.textSecondary)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)

                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .transition(.scale)
                }
            }
            .padding(16)
            .background(
                ZStack {
                    // Shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .offset(x: 4, y: 4)

                    // Main background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(isSelected ? 0.4 : 0.15),
                                    PixelColors.midnightBlue.opacity(0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Border
                    Rectangle()
                        .stroke(
                            isSelected ? color : color.opacity(0.5),
                            lineWidth: isSelected ? 3 : 2
                        )

                    // Glow when selected
                    if isSelected {
                        Rectangle()
                            .stroke(color.opacity(0.5), lineWidth: 4)
                            .blur(radius: 8)
                    }
                }
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mini Dice Face (for rules display)
struct MiniDiceFace: View {
    let value: Int
    let color: Color

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.9))
                .frame(width: 18, height: 18)

            // Border
            RoundedRectangle(cornerRadius: 2)
                .stroke(color.opacity(0.5), lineWidth: 1)
                .frame(width: 18, height: 18)

            // Dots
            miniDotsForValue(value)
        }
    }

    @ViewBuilder
    private func miniDotsForValue(_ value: Int) -> some View {
        let dotSize: CGFloat = 3
        let dot = Circle().fill(Color.black).frame(width: dotSize, height: dotSize)

        switch value {
        case 1:
            dot
        case 2:
            VStack(spacing: 6) {
                HStack { dot; Spacer() }
                HStack { Spacer(); dot }
            }
            .frame(width: 12, height: 12)
        case 3:
            VStack(spacing: 3) {
                HStack { dot; Spacer() }
                dot
                HStack { Spacer(); dot }
            }
            .frame(width: 12, height: 12)
        case 4:
            VStack(spacing: 6) {
                HStack { dot; Spacer(); dot }
                HStack { dot; Spacer(); dot }
            }
            .frame(width: 12, height: 12)
        case 5:
            VStack(spacing: 3) {
                HStack { dot; Spacer(); dot }
                dot
                HStack { dot; Spacer(); dot }
            }
            .frame(width: 12, height: 12)
        case 6:
            VStack(spacing: 2) {
                HStack { dot; Spacer(); dot }
                HStack { dot; Spacer(); dot }
                HStack { dot; Spacer(); dot }
            }
            .frame(width: 12, height: 12)
        default:
            EmptyView()
        }
    }
}

// MARK: - Daily Streak Display
struct DailyStreakView: View {
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        HStack(spacing: 20) {
            // Current streak
            VStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 24))

                Text("\(currentStreak)")
                    .pixelText(size: 24, color: PixelColors.neonOrange)
                    .glow(color: PixelColors.neonOrange, radius: 3)

                Text("STREAK")
                    .pixelText(size: 8, color: PixelColors.textSecondary)
            }
            .frame(width: 70)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(PixelColors.midnightBlue.opacity(0.8))
                    .overlay(Rectangle().stroke(PixelColors.neonOrange.opacity(0.5), lineWidth: 2))
            )

            // Best streak
            VStack(spacing: 4) {
                Text("🏆")
                    .font(.system(size: 24))

                Text("\(longestStreak)")
                    .pixelText(size: 24, color: PixelColors.neonYellow)
                    .glow(color: PixelColors.neonYellow, radius: 3)

                Text("BEST")
                    .pixelText(size: 8, color: PixelColors.textSecondary)
            }
            .frame(width: 70)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(PixelColors.midnightBlue.opacity(0.8))
                    .overlay(Rectangle().stroke(PixelColors.neonYellow.opacity(0.5), lineWidth: 2))
            )
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        PixelBackground()

        VStack(spacing: 20) {
            ReportProgressButton { }

            Spacer()

            DailyStreakView(currentStreak: 7, longestStreak: 15)
        }
        .padding()
    }
}

#Preview("Choice Modal") {
    ProgressChoiceModal(
        isPresented: .constant(true),
        missionTitle: "30 Days Workout"
    ) { choice in
        print("Choice: \(choice)")
    }
}
