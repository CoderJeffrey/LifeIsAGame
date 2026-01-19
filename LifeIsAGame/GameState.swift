import SwiftUI

// MARK: - App Navigation State
enum AppScreen {
    case missionsList
    case game
}

// MARK: - Game State
class GameState: ObservableObject {
    // Navigation
    @Published var currentScreen: AppScreen = .missionsList

    // Mission management
    @Published var selectedMission: Mission?
    @Published var missions: [Mission] = [] // Start empty

    // Game state
    @Published var playerPosition: Int = 0
    @Published var isPlayerMoving: Bool = false
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalDaysCompleted: Int = 0

    // Flow states
    @Published var showProgressChoice: Bool = false
    @Published var showDiceOverlay: Bool = false
    @Published var currentDiceMode: DiceMode = .success
    @Published var lastRollResult: Int? = nil

    init() {
        // Start with empty missions list
    }

    // MARK: - Mission Management

    func addMission(_ mission: Mission) {
        missions.append(mission)
    }

    func selectMission(_ mission: Mission) {
        selectedMission = mission
        playerPosition = mission.currentDay
        currentScreen = .game
    }

    func goBackToMissionsList() {
        currentScreen = .missionsList
        selectedMission = nil
        // Reset game flow states
        showProgressChoice = false
        showDiceOverlay = false
        lastRollResult = nil
    }

    func deleteMission(_ mission: Mission) {
        missions.removeAll { $0.id == mission.id }
        if selectedMission?.id == mission.id {
            selectedMission = nil
        }
    }

    // MARK: - Game Actions

    func reportProgress() {
        guard selectedMission != nil else { return }
        showProgressChoice = true
    }

    func handleProgressChoice(_ madeIt: Bool) {
        showProgressChoice = false
        currentDiceMode = madeIt ? .success : .failure

        // Small delay before showing dice
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.lastRollResult = nil
            self.showDiceOverlay = true
        }
    }

    func handleDiceRollComplete(_ result: Int) {
        lastRollResult = result

        // Update player position with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.movePlayer(by: result)
        }
    }

    func movePlayer(by steps: Int) {
        guard let mission = selectedMission else { return }

        let maxPosition = mission.daysTotal
        isPlayerMoving = true

        // Animate step by step
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    let newPosition = self.playerPosition + 1
                    self.playerPosition = min(newPosition, maxPosition)
                }

                // Check if finished moving
                if step == steps {
                    self.isPlayerMoving = false

                    // Update mission progress
                    if var updatedMission = self.selectedMission {
                        updatedMission.currentDay = self.playerPosition
                        self.selectedMission = updatedMission

                        // Update in missions array
                        if let index = self.missions.firstIndex(where: { $0.id == updatedMission.id }) {
                            self.missions[index] = updatedMission
                        }
                    }

                    // Update streak if made it
                    if self.currentDiceMode == .success {
                        self.currentStreak += 1
                        self.totalDaysCompleted += 1
                        if self.currentStreak > self.longestStreak {
                            self.longestStreak = self.currentStreak
                        }
                    } else {
                        // Reset streak on miss
                        self.currentStreak = 0
                    }
                }
            }
        }
    }

    func resetGame() {
        playerPosition = 0
        currentStreak = 0
        if var mission = selectedMission {
            mission.currentDay = 0
            selectedMission = mission

            if let index = missions.firstIndex(where: { $0.id == mission.id }) {
                missions[index] = mission
            }
        }
    }
}

// MARK: - Movement Result View
struct MovementResultView: View {
    let steps: Int
    let isSuccess: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(isSuccess ? "✨" : "💫")
                    .font(.system(size: 24))

                Text("+\(steps)")
                    .pixelText(size: 32, color: isSuccess ? PixelColors.neonGreen : PixelColors.neonOrange)
                    .glow(color: isSuccess ? PixelColors.neonGreen : PixelColors.neonOrange, radius: 5)

                Text("STEPS")
                    .pixelText(size: 16, color: .white)
            }

            Text(isSuccess ?
                 "Great progress! Keep it up!" :
                 "Small steps still count!")
                .pixelText(size: 12, color: PixelColors.textSecondary)
        }
        .padding(20)
        .background(
            ZStack {
                Rectangle()
                    .fill(PixelColors.midnightBlue.opacity(0.95))

                Rectangle()
                    .stroke(
                        isSuccess ? PixelColors.neonGreen : PixelColors.neonOrange,
                        lineWidth: 2
                    )
            }
        )
    }
}
