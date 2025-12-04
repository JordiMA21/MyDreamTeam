import SwiftUI

struct PlayerCardView: View {
    let player: PlayerEntity
    let isSelected: Bool
    let onTap: () -> Void
    let onCompare: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Player Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.displayName)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text(player.currentTeamName ?? "N/A")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(player.number)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 28, height: 28)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(4)
                    }

                    // Stats Row
                    HStack(spacing: 12) {
                        statBadge(icon: "target", value: "\(player.stats?.goals ?? 0)", color: .cyan)
                        statBadge(icon: "hand.raised", value: "\(player.stats?.assists ?? 0)", color: .green)
                        statBadge(icon: "star", value: String(format: "%.1f", player.stats?.averageRating ?? 0), color: .yellow)

                        Spacer()
                    }
                }

                // Market Value and Action
                VStack(alignment: .trailing, spacing: 8) {
                    Text("€\(String(format: "%.1f", player.marketValue))")
                        .font(.headline)
                        .foregroundStyle(.blue)

                    Button(action: onTap) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(isSelected ? .green : .blue)
                    }
                }
            }
            .padding(12)

            // Comparison button
            if let onCompare = onCompare {
                Button(action: onCompare) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                        Text("Comparar")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(6)
                    .background(Color.white.opacity(0.05))
                    .foregroundStyle(.blue)
                    .cornerRadius(6)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Helper View

    private func statBadge(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption)
        }
        .foregroundStyle(color)
    }
}

#Preview {
    PlayerCardView(
        player: PlayerEntity(
            id: "1",
            firstName: "Lionel",
            lastName: "Messi",
            nationality: "Argentina",
            dateOfBirth: Date(),
            position: "FWD",
            number: 7,
            height: 1.70,
            weight: 72,
            foot: "left",
            currentTeamId: "team1",
            currentTeamName: "Inter Miami",
            status: "active",
            season: 2024,
            stats: PlayerStatsEntity(
                played: 34,
                goals: 15,
                assists: 8,
                yellowCards: 2,
                redCards: 0,
                cleanSheets: 0,
                minutes: 2856,
                averageRating: 8.5
            ),
            photo: nil,
            marketValue: 35.0
        ),
        isSelected: false,
        onTap: {},
        onCompare: {}
    )
}
