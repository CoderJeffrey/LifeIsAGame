import SwiftUI

// MARK: - Add Mission View
struct AddMissionView: View {
    @EnvironmentObject var gameState: GameState
    @Binding var isPresented: Bool

    @State private var missionTitle: String = ""
    @State private var selectedEmoji: String = "🎯"
    @FocusState private var isFocused: Bool

    private let emojiOptions = ["🎯", "💪", "📚", "🧘", "💻", "🏃", "✍️", "🎨", "🎵", "💰", "🥗", "💤", "🚀", "⭐", "🔥"]

    var isValid: Bool {
        !missionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            // Background
            PixelBackground()

            VStack(spacing: 0) {
                // Header
                AddMissionHeader(
                    onClose: { isPresented = false }
                )

                ScrollView {
                    VStack(spacing: 28) {
                        // Question
                        VStack(spacing: 8) {
                            Text("🎮")
                                .font(.system(size: 40))

                            Text("WHAT'S YOUR MISSION?")
                                .pixelText(size: 20, color: PixelColors.neonCyan)
                                .glow(color: PixelColors.neonCyan, radius: 3)

                            Text("Set a goal you want to achieve")
                                .pixelText(size: 12, color: PixelColors.textSecondary)
                        }
                        .padding(.top, 20)

                        // Mission name input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("MISSION NAME")
                                .pixelText(size: 12, color: PixelColors.textSecondary)

                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.4))
                                    .offset(x: 3, y: 3)

                                Rectangle()
                                    .fill(PixelColors.midnightBlue.opacity(0.9))

                                Rectangle()
                                    .stroke(
                                        isFocused ? PixelColors.neonCyan : Color.white.opacity(0.3),
                                        lineWidth: isFocused ? 2 : 1
                                    )

                                TextField("", text: $missionTitle, prompt: Text("e.g., 30 Days Workout")
                                    .foregroundColor(PixelColors.textSecondary.opacity(0.5)))
                                    .font(.system(size: 16, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .focused($isFocused)
                            }
                            .frame(height: 52)
                        }
                        .padding(.horizontal, 20)

                        // Emoji selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CHOOSE AN ICON")
                                .pixelText(size: 12, color: PixelColors.textSecondary)
                                .padding(.horizontal, 20)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    EmojiOptionButton(
                                        emoji: emoji,
                                        isSelected: selectedEmoji == emoji
                                    ) {
                                        selectedEmoji = emoji
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Preview
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PREVIEW")
                                .pixelText(size: 12, color: PixelColors.textSecondary)

                            MissionPreviewCard(
                                title: missionTitle.isEmpty ? "Your Mission" : missionTitle,
                                emoji: selectedEmoji
                            )
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 100)
                    }
                }

                // Submit button
                VStack {
                    Button(action: submitMission) {
                        HStack(spacing: 10) {
                            Text("START MISSION")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .offset(x: 4, y: 4)

                                Rectangle()
                                    .fill(
                                        isValid ?
                                        LinearGradient(
                                            colors: [PixelColors.neonGreen, PixelColors.neonGreen.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )

                                Rectangle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            }
                        )
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(
                    Rectangle()
                        .fill(PixelColors.midnightBlue.opacity(0.95))
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .onTapGesture {
            isFocused = false
        }
    }

    private func submitMission() {
        let newMission = Mission(
            title: missionTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: selectedEmoji,
            color: PixelColors.neonCyan,
            description: "",
            daysTotal: 30,
            currentDay: 0
        )
        gameState.addMission(newMission)
        isPresented = false
    }
}

// MARK: - Add Mission Header
struct AddMissionHeader: View {
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))

                    Text("BACK")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundColor(PixelColors.textSecondary)
            }

            Spacer()

            Text("NEW MISSION")
                .pixelText(size: 16, color: .white)

            Spacer()

            // Spacer for alignment
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                Text("BACK")
            }
            .font(.system(size: 12))
            .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(PixelColors.midnightBlue.opacity(0.9))
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Emoji Option Button
struct EmojiOptionButton: View {
    let emoji: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(emoji)
                .font(.system(size: 24))
                .frame(width: 50, height: 50)
                .background(
                    ZStack {
                        if isSelected {
                            Rectangle()
                                .fill(Color.black.opacity(0.4))
                                .offset(x: 2, y: 2)
                        }

                        Rectangle()
                            .fill(isSelected ? PixelColors.neonPink.opacity(0.3) : Color.white.opacity(0.05))

                        Rectangle()
                            .stroke(
                                isSelected ? PixelColors.neonPink : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
                )
        }
    }
}

// MARK: - Mission Preview Card
struct MissionPreviewCard: View {
    let title: String
    let emoji: String

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Rectangle()
                    .fill(PixelColors.neonCyan.opacity(0.2))
                    .frame(width: 56, height: 56)

                Rectangle()
                    .stroke(PixelColors.neonCyan.opacity(0.5), lineWidth: 2)
                    .frame(width: 56, height: 56)

                Text(emoji)
                    .font(.system(size: 28))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .offset(x: 3, y: 3)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                PixelColors.neonCyan.opacity(0.15),
                                PixelColors.midnightBlue.opacity(0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Rectangle()
                    .stroke(PixelColors.neonCyan.opacity(0.4), lineWidth: 2)
            }
        )
    }
}

// MARK: - Preview
#Preview {
    AddMissionView(isPresented: .constant(true))
        .environmentObject(GameState())
}
