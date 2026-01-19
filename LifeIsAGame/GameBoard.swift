import SwiftUI

// MARK: - Game Tile Model
struct GameTile: Identifiable {
    let id: Int
    let type: TileType
    let color: Color
    let icon: String
    let label: String

    enum TileType {
        case start
        case reward
        case challenge
        case bonus
        case rest
        case milestone
        case finish
        case normal
    }
}

// MARK: - Sample Tiles for 30-day journey
extension GameTile {
    static func createBoard() -> [GameTile] {
        var tiles: [GameTile] = []

        // Create 30 tiles for a 30-day journey in Z-shape
        let tileConfigs: [(TileType, Color, String, String)] = [
            (.start, PixelColors.neonGreen, "🚀", "START"),
            (.normal, PixelColors.tileBlue, "1", "Day 1"),
            (.normal, PixelColors.tilePurple, "2", "Day 2"),
            (.normal, PixelColors.tileGreen, "3", "Day 3"),
            (.normal, PixelColors.tileOrange, "4", "Day 4"),
            (.reward, PixelColors.neonYellow, "⭐", "REWARD"),
            (.normal, PixelColors.tileCyan, "6", "Day 6"),
            // Row 2 (right to left)
            (.normal, PixelColors.tilePink, "7", "Day 7"),
            (.challenge, PixelColors.neonOrange, "⚡", "CHALLENGE"),
            (.normal, PixelColors.tileBlue, "9", "Day 9"),
            (.milestone, PixelColors.neonPink, "🎯", "WEEK 1"),
            (.normal, PixelColors.tileGreen, "11", "Day 11"),
            (.normal, PixelColors.tilePurple, "12", "Day 12"),
            (.bonus, PixelColors.neonCyan, "🎁", "BONUS"),
            // Row 3 (left to right)
            (.normal, PixelColors.tileOrange, "14", "Day 14"),
            (.rest, PixelColors.tileCyan, "💤", "REST"),
            (.normal, PixelColors.tilePink, "16", "Day 16"),
            (.normal, PixelColors.tileBlue, "17", "Day 17"),
            (.normal, PixelColors.tileGreen, "18", "Day 18"),
            (.reward, PixelColors.neonYellow, "⭐", "REWARD"),
            (.milestone, PixelColors.neonPink, "🎯", "WEEK 2"),
            // Row 4 (right to left)
            (.normal, PixelColors.tilePurple, "21", "Day 21"),
            (.challenge, PixelColors.neonOrange, "⚡", "CHALLENGE"),
            (.normal, PixelColors.tileOrange, "23", "Day 23"),
            (.normal, PixelColors.tileCyan, "24", "Day 24"),
            (.bonus, PixelColors.neonCyan, "🎁", "BONUS"),
            (.normal, PixelColors.tilePink, "26", "Day 26"),
            (.normal, PixelColors.tileBlue, "27", "Day 27"),
            // Row 5 (left to right - final)
            (.milestone, PixelColors.neonPink, "🎯", "WEEK 3"),
            (.normal, PixelColors.tileGreen, "29", "Day 29"),
            (.finish, PixelColors.neonGreen, "🏆", "FINISH!")
        ]

        for (index, config) in tileConfigs.enumerated() {
            tiles.append(GameTile(
                id: index,
                type: config.0,
                color: config.1,
                icon: config.2,
                label: config.3
            ))
        }

        return tiles
    }
}

// MARK: - Single Tile View
struct TileView: View {
    let tile: GameTile
    let isPlayerHere: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            // Shadow
            Rectangle()
                .fill(Color.black.opacity(0.4))
                .offset(x: 2, y: 2)

            // Main tile background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            tile.color.opacity(0.9),
                            tile.color.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Highlight
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

            // Border
            Rectangle()
                .stroke(
                    isPlayerHere ? PixelColors.neonYellow : Color.white.opacity(0.5),
                    lineWidth: isPlayerHere ? 3 : 1
                )

            // Content
            VStack(spacing: 2) {
                Text(tile.icon)
                    .font(.system(size: size * 0.35))

                if tile.type != .start && tile.type != .finish {
                    Text(tile.label)
                        .font(.system(size: size * 0.12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .frame(width: size, height: size)
        .glow(color: isPlayerHere ? PixelColors.neonYellow : .clear, radius: isPlayerHere ? 8 : 0)
    }
}

// MARK: - Player Token View
struct PlayerToken: View {
    let color: Color

    var body: some View {
        ZStack {
            // Shadow
            Circle()
                .fill(Color.black.opacity(0.5))
                .offset(x: 2, y: 2)

            // Main body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.7)],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 20
                    )
                )

            // Highlight
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .scaleEffect(0.8)
                .offset(x: -3, y: -3)

            // Border
            Circle()
                .stroke(Color.white, lineWidth: 2)

            // Face
            VStack(spacing: 1) {
                HStack(spacing: 4) {
                    Circle().fill(Color.black).frame(width: 4, height: 4)
                    Circle().fill(Color.black).frame(width: 4, height: 4)
                }
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 8, height: 2)
                    .offset(y: 2)
            }
        }
        .frame(width: 30, height: 30)
    }
}

// MARK: - Z-Shaped Game Board View
struct GameBoardView: View {
    let tiles: [GameTile]
    let playerPosition: Int
    @Binding var playerMoving: Bool

    // Define how many tiles per row for Z-shape
    private let tilesPerRow = 7
    private let tileSize: CGFloat = 48

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 32
            let calculatedTileSize = min(tileSize, (availableWidth - CGFloat(tilesPerRow - 1) * 4) / CGFloat(tilesPerRow))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Build the Z-shaped board
                    ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                        buildRow(
                            rowIndex: rowIndex,
                            tileSize: calculatedTileSize,
                            availableWidth: availableWidth
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
    }

    private var numberOfRows: Int {
        (tiles.count + tilesPerRow - 1) / tilesPerRow
    }

    @ViewBuilder
    private func buildRow(rowIndex: Int, tileSize: CGFloat, availableWidth: CGFloat) -> some View {
        let startIndex = rowIndex * tilesPerRow
        let endIndex = min(startIndex + tilesPerRow, tiles.count)
        let rowTiles = Array(tiles[startIndex..<endIndex])
        let isReversed = rowIndex % 2 == 1 // Alternate direction for Z-shape

        VStack(spacing: 0) {
            // Tiles row
            HStack(spacing: 4) {
                if isReversed {
                    Spacer()
                }

                ForEach(isReversed ? rowTiles.reversed() : rowTiles) { tile in
                    TileView(
                        tile: tile,
                        isPlayerHere: playerPosition == tile.id,
                        size: tileSize
                    )
                }

                if !isReversed {
                    Spacer()
                }
            }

            // Connector to next row (if not last row)
            if rowIndex < numberOfRows - 1 {
                buildConnector(rowIndex: rowIndex, tileSize: tileSize, availableWidth: availableWidth)
            }
        }
    }

    @ViewBuilder
    private func buildConnector(rowIndex: Int, tileSize: CGFloat, availableWidth: CGFloat) -> some View {
        let isGoingRight = rowIndex % 2 == 1

        HStack {
            if isGoingRight {
                Spacer()
                // Connector on the left side
                ZStack {
                    // Vertical line
                    Rectangle()
                        .fill(PixelColors.neonCyan.opacity(0.5))
                        .frame(width: 4, height: 30)

                    // Dots
                    VStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(PixelColors.neonCyan)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(width: tileSize)
                .padding(.trailing, availableWidth - tileSize - 8)
            } else {
                // Connector on the right side
                ZStack {
                    // Vertical line
                    Rectangle()
                        .fill(PixelColors.neonCyan.opacity(0.5))
                        .frame(width: 4, height: 30)

                    // Dots
                    VStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(PixelColors.neonCyan)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(width: tileSize)
                .padding(.leading, availableWidth - tileSize - 8)
                Spacer()
            }
        }
        .frame(height: 30)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        PixelBackground()

        GameBoardView(
            tiles: GameTile.createBoard(),
            playerPosition: 7,
            playerMoving: .constant(false)
        )
    }
}
