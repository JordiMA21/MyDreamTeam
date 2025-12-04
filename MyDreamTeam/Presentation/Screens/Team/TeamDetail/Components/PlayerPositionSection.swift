import SwiftUI

struct PlayerPositionSection: View {
    let position: String
    let players: [Player]
    let onPlayerTap: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Header with position
            HStack(spacing: 8) {
                Image(systemName: getPositionIcon(position))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)

                Text(position)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("(\(players.count))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Players list
            VStack(spacing: 10) {
                ForEach(players) { player in
                    TeamPlayerRow(player: player) {
                        onPlayerTap(player.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }

    private func getPositionIcon(_ position: String) -> String {
        switch position.lowercased() {
        case "portero":
            return "hand.raised.fill"
        case "defensa":
            return "shield.fill"
        case "centrocampista":
            return "circle.fill"
        case "delantero":
            return "target"
        default:
            return "person.fill"
        }
    }
}

#Preview {
    PlayerPositionSection(
        position: "Delantero",
        players: [
            Player(id: 1, name: "Lionel Messi", position: "Delantero", team: "Inter Miami", number: 10, image: "", nationality: "Argentina", age: 36, goals: 45, assists: 15, marketValue: 50000000, yellowCards: 2, redCards: 0, minutesPlayed: 2400, matchesPlayed: 32, height: "1.70 m", weight: "72 kg", foot: "Zurdo", fantasyPoints: 285.5, averageRating: 8.2),
            Player(id: 2, name: "Luis Suárez", position: "Delantero", team: "Inter Miami", number: 9, image: "", nationality: "Uruguay", age: 35, goals: 40, assists: 12, marketValue: 45000000, yellowCards: 3, redCards: 0, minutesPlayed: 2100, matchesPlayed: 28, height: "1.82 m", weight: "86 kg", foot: "Derecho", fantasyPoints: 265.0, averageRating: 7.8)
        ],
        onPlayerTap: { _ in }
    )
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.15))
}
