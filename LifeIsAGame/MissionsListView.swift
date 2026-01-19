import SwiftUI

// MARK: - Missions List View (Main Entry Page)
struct MissionsListView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showAddMission = false

    var body: some View {
        ZStack {
            // Background
            PixelBackground()

            VStack(spacing: 0) {
                // Header
                MissionsHeader(onAddTapped: {
                    showAddMission = true
                })

                // Content
                if gameState.missions.isEmpty {
                    EmptyMissionsView(onAddTapped: {
                        showAddMission = true
                    })
                } else {
                    MissionsListContent()
                }
            }
        }
        .fullScreenCover(isPresented: $showAddMission) {
            AddMissionView(isPresented: $showAddMission)
                .environmentObject(gameState)
        }
    }
}

// MARK: - Missions Header
struct MissionsHeader: View {
    let onAddTapped: () -> Void

    var body: some View {
        HStack {
            // Title
            HStack(spacing: 10) {
                Text("🎮")
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text("LIFE IS A GAME")
                        .pixelText(size: 20, color: PixelColors.neonCyan)
                        .glow(color: PixelColors.neonCyan, radius: 3)

                    Text("Your Missions")
                        .pixelText(size: 12, color: PixelColors.textSecondary)
                }
            }

            Spacer()

            // Add button
            Button(action: onAddTapped) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))

                    Text("ADD")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.4))
                            .offset(x: 2, y: 2)

                        Rectangle()
                            .fill(PixelColors.neonPink)

                        Rectangle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                )
            }
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

// MARK: - Empty Missions View
struct EmptyMissionsView: View {
    let onAddTapped: () -> Void
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(PixelColors.neonCyan.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .stroke(PixelColors.neonCyan.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0 : 1)

                Text("🎯")
                    .font(.system(size: 50))
            }

            // Text
            VStack(spacing: 12) {
                Text("NO MISSIONS YET")
                    .pixelText(size: 22, color: .white)

                Text("Create your first mission to\nstart your journey!")
                    .pixelText(size: 14, color: PixelColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Add button
            Button(action: onAddTapped) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))

                    Text("CREATE MISSION")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .offset(x: 4, y: 4)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [PixelColors.neonPink, PixelColors.neonPink.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Rectangle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    }
                )
            }
            .glow(color: PixelColors.neonPink, radius: 5)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Missions List Content
struct MissionsListContent: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gameState.missions) { mission in
                    MissionRowCard(mission: mission) {
                        gameState.selectMission(mission)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Mission Row Card
struct MissionRowCard: View {
    let mission: Mission
    let onTap: () -> Void

    var progressPercentage: Double {
        Double(mission.currentDay) / Double(mission.daysTotal)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Emoji icon
                ZStack {
                    Rectangle()
                        .fill(mission.color.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Rectangle()
                        .stroke(mission.color.opacity(0.5), lineWidth: 2)
                        .frame(width: 56, height: 56)

                    Text(mission.emoji)
                        .font(.system(size: 28))
                }

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(mission.title)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            Rectangle()
                                .fill(mission.color)
                                .frame(width: geometry.size.width * progressPercentage, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("Day \(mission.currentDay) of \(mission.daysTotal)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(PixelColors.textSecondary)
                }

                Spacer()

                // Arrow
                VStack {
                    Image(systemName: "chevron.right")
                        .foregroundColor(mission.color)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(16)
            .background(
                ZStack {
                    // Shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .offset(x: 3, y: 3)

                    // Background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    mission.color.opacity(0.15),
                                    PixelColors.midnightBlue.opacity(0.95)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Border
                    Rectangle()
                        .stroke(mission.color.opacity(0.4), lineWidth: 2)
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MissionsListView()
        .environmentObject(GameState())
}

#Preview("With Missions") {
    let gameState = GameState()
    gameState.missions = Mission.sampleMissions
    return MissionsListView()
        .environmentObject(gameState)
}
