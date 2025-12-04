import SwiftUI

struct TeamPlayerRow: View {
    let player: Player
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Player number
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Text("#\(player.number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.blue)
                }

                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        Label(player.position, systemImage: "target")
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

                // Fantasy points
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", player.fantasyPoints))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.blue)

                    Text("pts")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}

#Preview {
    TeamPlayerRow(player: Player(
        id: 1,
        name: "Lionel Messi",
        position: "Delantero",
        team: "Inter Miami",
        number: 10,
        image: "",
        nationality: "Argentina",
        age: 36,
        goals: 45,
        assists: 15,
        marketValue: 50000000,
        yellowCards: 2,
        redCards: 0,
        minutesPlayed: 2400,
        matchesPlayed: 32,
        height: "1.70 m",
        weight: "72 kg",
        foot: "Zurdo",
        fantasyPoints: 285.5,
        averageRating: 8.2
    ), onTap: {})
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.15))
}
