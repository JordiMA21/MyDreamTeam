import SwiftUI

struct PlayerSelectionModal: View {
    @Environment(\.dismiss) var dismiss

    let position: FormationPosition
    let players: [Player]
    let onPlayerSelected: (Player) -> Void
    let onRemovePlayer: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Seleccionar \(position.rawValue)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.gray)
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.05))

                // Players list
                if players.isEmpty {
                    VStack {
                        Image(systemName: "person.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)

                        Text("No hay jugadores disponibles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.gray)
                            .padding(.top, 12)
                    }
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(players) { player in
                                PlayerSelectionRow(player: player) {
                                    onPlayerSelected(player)
                                    dismiss()
                                }
                            }
                        }
                        .padding(16)
                    }
                }

                // Remove button
                Button(action: {
                    onRemovePlayer()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Desasignar")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.red.opacity(0.2))
                    .foregroundStyle(.red)
                    .cornerRadius(10)
                }
                .padding(16)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct PlayerSelectionRow: View {
    let player: Player
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Number circle
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))

                    Text("#\(player.number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 44, height: 44)

                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        Text(player.position)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)

                        Text("•")
                            .foregroundStyle(.gray)

                        Text(player.nationality)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", player.fantasyPoints))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.blue)

                    Text("pts")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Image(systemName: "checkmark.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}

#Preview {
    PlayerSelectionModal(
        position: .forward,
        players: [
            Player(id: 1, name: "Lionel Messi", position: "Delantero", team: "Inter Miami", number: 10, image: "", nationality: "Argentina", age: 36, goals: 45, assists: 15, marketValue: 50000000, yellowCards: 2, redCards: 0, minutesPlayed: 2400, matchesPlayed: 32, height: "1.70 m", weight: "72 kg", foot: "Zurdo", fantasyPoints: 285.5, averageRating: 8.2),
            Player(id: 2, name: "Luis Suárez", position: "Delantero", team: "Inter Miami", number: 9, image: "", nationality: "Uruguay", age: 35, goals: 40, assists: 12, marketValue: 45000000, yellowCards: 3, redCards: 0, minutesPlayed: 2100, matchesPlayed: 28, height: "1.82 m", weight: "86 kg", foot: "Derecho", fantasyPoints: 265.0, averageRating: 7.8)
        ],
        onPlayerSelected: { _ in },
        onRemovePlayer: {}
    )
}
