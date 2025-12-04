import SwiftUI

struct PlayerPositionListSection: View {
    let position: FormationPosition
    let players: [Player]
    let onPlayerTap: (Player) -> Void

    var positionColor: Color {
        FormationManager.getPositionColor(for: position)
    }

    var positionLabel: String {
        switch position {
        case .goalkeeper:
            return "Porteros"
        case .defender:
            return "Defensas"
        case .midfielder:
            return "Mediocampistas"
        case .forward:
            return "Delanteros"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con etiqueta de posición
            HStack(spacing: 12) {
                Circle()
                    .fill(positionColor)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(positionLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("\(players.count) jugador\(players.count == 1 ? "" : "es")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Spacer()

                Text(String(players.count))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(positionColor)
                    .frame(width: 32, height: 32)
                    .background(positionColor.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)

            // Lista de jugadores
            VStack(spacing: 8) {
                ForEach(players) { player in
                    PlayerPositionListRow(player: player, position: position) {
                        onPlayerTap(player)
                    }
                }
            }
        }
    }
}

// MARK: - Player Row Component
struct PlayerPositionListRow: View {
    let player: Player
    let position: FormationPosition
    let onTap: () -> Void

    var positionColor: Color {
        FormationManager.getPositionColor(for: position)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Player number with color background
                VStack {
                    Text(String(player.number))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    positionColor.opacity(0.8),
                                    positionColor.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                )

                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(player.team)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)

                        Text("•")
                            .foregroundStyle(.gray)

                        Text("\(player.age) años")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                }

                Spacer()

                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.green)

                        Text(String(player.goals))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.yellow)

                        Text(String(format: "%.1f", player.averageRating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(positionColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    let mockPlayers = [
        Player(
            id: 1, name: "Andrés Palop", position: "Portero", team: "Sevilla",
            number: 1, image: "", nationality: "Española", age: 35, goals: 0, assists: 0,
            marketValue: 5000000, yellowCards: 2, redCards: 0, minutesPlayed: 2700,
            matchesPlayed: 30, height: "188 cm", weight: "85 kg", foot: "Derecha",
            fantasyPoints: 450, averageRating: 7.2
        ),
        Player(
            id: 2, name: "Nacho Fernández", position: "Defensa", team: "Real Madrid",
            number: 18, image: "", nationality: "Española", age: 24, goals: 1, assists: 2,
            marketValue: 18000000, yellowCards: 3, redCards: 0, minutesPlayed: 1800,
            matchesPlayed: 22, height: "180 cm", weight: "78 kg", foot: "Derecha",
            fantasyPoints: 380, averageRating: 6.9
        )
    ]

    VStack {
        PlayerPositionListSection(
            position: .goalkeeper,
            players: [mockPlayers[0]],
            onPlayerTap: { _ in }
        )

        PlayerPositionListSection(
            position: .defender,
            players: [mockPlayers[1]],
            onPlayerTap: { _ in }
        )
    }
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.15))
}
