import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var showWelcome = true

    var body: some View {
        ZStack {
            // Background
            PixelBackground()

            // Main content based on navigation state
            if showWelcome {
                WelcomeView(onStart: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcome = false
                    }
                })
            } else {
                // Navigation based on current screen
                switch gameState.currentScreen {
                case .missionsList:
                    MissionsListView()
                        .environmentObject(gameState)
                        .transition(.opacity)

                case .game:
                    if gameState.selectedMission != nil {
                        GameView()
                            .environmentObject(gameState)
                            .transition(.move(edge: .trailing))
                    }
                }
            }

            // Overlays for game flow
            if gameState.showProgressChoice {
                ProgressChoiceModal(
                    isPresented: $gameState.showProgressChoice,
                    missionTitle: gameState.selectedMission?.title ?? "Your Mission"
                ) { madeIt in
                    gameState.handleProgressChoice(madeIt)
                }
                .transition(.opacity)
                .zIndex(10)
            }

            if gameState.showDiceOverlay {
                DiceOverlayView(
                    mode: gameState.currentDiceMode,
                    isPresented: $gameState.showDiceOverlay,
                    rollResult: $gameState.lastRollResult
                ) { result in
                    gameState.handleDiceRollComplete(result)
                }
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameState.currentScreen)
        .animation(.easeInOut, value: gameState.showProgressChoice)
        .animation(.easeInOut, value: gameState.showDiceOverlay)
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onStart: () -> Void
    @State private var titleScale: CGFloat = 0.8
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Title
            VStack(spacing: 16) {
                Text("🎮")
                    .font(.system(size: 60))
                    .scaleEffect(titleScale)

                Text("LIFE IS A GAME")
                    .pixelText(size: 32, color: PixelColors.neonCyan)
                    .glow(color: PixelColors.neonCyan, radius: 10)
                    .scaleEffect(titleScale)

                Text("Level up your life, one day at a time")
                    .pixelText(size: 14, color: PixelColors.textSecondary)
            }

            // Features
            VStack(spacing: 20) {
                FeatureRow(icon: "🎯", text: "Set daily missions")
                FeatureRow(icon: "🎲", text: "Roll dice to progress")
                FeatureRow(icon: "🏆", text: "Build winning streaks")
            }
            .opacity(showButton ? 1 : 0)

            Spacer()

            // Start button
            if showButton {
                Button(action: onStart) {
                    HStack(spacing: 12) {
                        Text("START GAME")
                            .pixelText(size: 20)

                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PixelButtonStyle(backgroundColor: PixelColors.neonPink))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: 60)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                titleScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                showButton = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 40)

            Text(text)
                .pixelText(size: 14, color: .white)

            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Game View (Simplified - No Mission Selector)
struct GameView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button and mission info
            GameViewHeader()

            // Mission info bar
            if let mission = gameState.selectedMission {
                CurrentMissionBar(mission: mission)
            }

            // Game board
            GameBoardView(
                tiles: GameTile.createBoard(),
                playerPosition: gameState.playerPosition,
                playerMoving: $gameState.isPlayerMoving
            )

            // Bottom controls
            VStack(spacing: 12) {
                // Report progress button
                ReportProgressButton {
                    gameState.reportProgress()
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Game View Header
struct GameViewHeader: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        HStack {
            // Back button
            Button(action: {
                withAnimation {
                    gameState.goBackToMissionsList()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(PixelColors.neonCyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Rectangle()
                        .stroke(PixelColors.neonCyan.opacity(0.5), lineWidth: 1)
                )
            }

            Spacer()

            // Dynamic title based on mission name
            if let mission = gameState.selectedMission {
                HStack(spacing: 8) {
                    Text(mission.emoji)
                        .font(.system(size: 20))

                    Text(mission.title.uppercased())
                        .pixelText(size: 14, color: PixelColors.neonCyan)
                        .glow(color: PixelColors.neonCyan, radius: 3)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Placeholder for alignment
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
            }
            .font(.system(size: 14))
            .opacity(0)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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

// MARK: - Current Mission Bar
struct CurrentMissionBar: View {
    let mission: Mission

    var progressPercentage: Double {
        Double(mission.currentDay) / Double(mission.daysTotal)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [mission.color, mission.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 10)

                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(height: 10)
                }
            }
            .frame(height: 10)

            // Progress text
            HStack {
                Text("\(Int(progressPercentage * 100))% COMPLETE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(PixelColors.textSecondary)

                Spacer()

                Text("\(mission.daysTotal - mission.currentDay) DAYS LEFT")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(mission.color)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(PixelColors.midnightBlue.opacity(0.8))
        )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

#Preview("Welcome") {
    ZStack {
        PixelBackground()
        WelcomeView(onStart: {})
    }
}

#Preview("Game View") {
    let gameState = GameState()
    gameState.missions = [Mission(
        title: "30 Days Workout",
        emoji: "💪",
        color: PixelColors.neonPink,
        description: "Exercise daily",
        daysTotal: 30,
        currentDay: 7
    )]
    gameState.selectedMission = gameState.missions.first
    gameState.currentScreen = .game

    return ZStack {
        PixelBackground()
        GameView()
            .environmentObject(gameState)
    }
}
