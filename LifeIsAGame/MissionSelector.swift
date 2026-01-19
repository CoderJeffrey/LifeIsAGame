import SwiftUI

// MARK: - Mission Model
struct Mission: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let emoji: String
    let color: Color
    let description: String
    let daysTotal: Int
    var currentDay: Int
}

// MARK: - Sample Missions
extension Mission {
    static let sampleMissions: [Mission] = [
        Mission(
            title: "30 Days Workout",
            emoji: "💪",
            color: PixelColors.neonPink,
            description: "Exercise every day",
            daysTotal: 30,
            currentDay: 7
        ),
        Mission(
            title: "Read 20 Pages",
            emoji: "📚",
            color: PixelColors.neonCyan,
            description: "Read daily",
            daysTotal: 30,
            currentDay: 12
        ),
        Mission(
            title: "No Sugar Challenge",
            emoji: "🍬",
            color: PixelColors.neonOrange,
            description: "Avoid sugary foods",
            daysTotal: 21,
            currentDay: 5
        ),
        Mission(
            title: "Meditation",
            emoji: "🧘",
            color: PixelColors.neonGreen,
            description: "10 min meditation",
            daysTotal: 30,
            currentDay: 15
        ),
        Mission(
            title: "Learn Coding",
            emoji: "💻",
            color: PixelColors.tilePurple,
            description: "Code 1 hour daily",
            daysTotal: 100,
            currentDay: 23
        )
    ]
}

// MARK: - Mission Card View
struct MissionCard: View {
    let mission: Mission
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Emoji icon
                Text(mission.emoji)
                    .font(.system(size: 32))
                    .shadow(color: mission.color.opacity(0.8), radius: isSelected ? 10 : 0)

                // Title
                Text(mission.title)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Progress
                Text("Day \(mission.currentDay)/\(mission.daysTotal)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(PixelColors.textSecondary)
            }
            .frame(width: 90, height: 100)
            .background(
                ZStack {
                    // Shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .offset(x: 3, y: 3)

                    // Main background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    mission.color.opacity(isSelected ? 0.4 : 0.2),
                                    PixelColors.midnightBlue.opacity(0.9)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Border
                    Rectangle()
                        .stroke(
                            isSelected ? mission.color : Color.white.opacity(0.3),
                            lineWidth: isSelected ? 3 : 2
                        )
                }
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mission Selector View
struct MissionSelector: View {
    @Binding var selectedMission: Mission?
    let missions: [Mission]
    @State private var showMissionPicker = false

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("⚔️ SELECT MISSION")
                    .pixelText(size: 14, color: PixelColors.neonYellow)

                Spacer()

                Button(action: { showMissionPicker.toggle() }) {
                    HStack(spacing: 4) {
                        Text("ALL")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundColor(PixelColors.neonCyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Rectangle()
                            .stroke(PixelColors.neonCyan, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, 16)

            // Horizontal scroll of missions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(missions) { mission in
                        MissionCard(
                            mission: mission,
                            isSelected: selectedMission?.id == mission.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMission = mission
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            // Selected mission info bar
            if let selected = selectedMission {
                SelectedMissionBar(mission: selected)
            }
        }
    }
}

// MARK: - Selected Mission Info Bar
struct SelectedMissionBar: View {
    let mission: Mission

    var progressPercentage: Double {
        Double(mission.currentDay) / Double(mission.daysTotal)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Mission icon
                Text(mission.emoji)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .background(
                        Rectangle()
                            .fill(mission.color.opacity(0.3))
                            .overlay(Rectangle().stroke(mission.color, lineWidth: 2))
                    )

                // Mission details
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text(mission.description)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(PixelColors.textSecondary)
                }

                Spacer()

                // Day counter
                VStack(spacing: 2) {
                    Text("DAY")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(PixelColors.textSecondary)

                    Text("\(mission.currentDay)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(mission.color)
                        .glow(color: mission.color, radius: 3)
                }
            }
            .padding(.horizontal, 16)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [mission.color, mission.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 8)

                    // Border
                    Rectangle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 16)

            // Progress text
            HStack {
                Text("\(Int(progressPercentage * 100))% COMPLETE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(PixelColors.textSecondary)

                Spacer()

                Text("\(mission.daysTotal - mission.currentDay) DAYS LEFT")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(mission.color)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(PixelColors.midnightBlue.opacity(0.8))
                .overlay(
                    Rectangle()
                        .stroke(mission.color.opacity(0.5), lineWidth: 2)
                )
        )
    }
}

#Preview {
    ZStack {
        PixelBackground()
        VStack {
            MissionSelector(
                selectedMission: .constant(Mission.sampleMissions.first),
                missions: Mission.sampleMissions
            )
            Spacer()
        }
    }
}
