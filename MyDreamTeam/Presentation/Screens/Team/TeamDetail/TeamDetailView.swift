import SwiftUI

struct TeamDetailView: View {
    @StateObject var viewModel: TeamDetailViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
            } else if let team = viewModel.team {
                VStack(spacing: 0) {
                    // Tab selector
                    Picker("", selection: $viewModel.selectedTab) {
                        Text("Información").tag(0)
                        Text("Plantilla").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(16)
                    .background(Color.white.opacity(0.05))

                    // Content based on selected tab
                    if viewModel.selectedTab == 0 {
                        teamInfoView(team)
                    } else {
                        teamRosterView()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Detalle del Equipo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    viewModel.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.blue)
                }
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
        .onAppear {
            viewModel.loadTeamData()
        }
    }

    // MARK: - Team Info View
    @ViewBuilder
    private func teamInfoView(_ team: Team) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header with team info
                teamHeaderView(team)

                // Statistics
                teamStatsView(team)

                // Additional info
                teamAdditionalInfoView(team)

                Spacer()
                    .frame(height: 20)
            }
        }
    }

    // MARK: - Team Header View
    @ViewBuilder
    private func teamHeaderView(_ team: Team) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                // Team logo placeholder
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                    .frame(width: 100, height: 100)
                    .background(Circle().fill(Color.white.opacity(0.1)))

                VStack(spacing: 8) {
                    Text(team.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        Label(team.city, systemImage: "location.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))

                        Divider()
                            .frame(height: 16)

                        Text(team.league)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 260)
    }

    // MARK: - Team Stats View
    @ViewBuilder
    private func teamStatsView(_ team: Team) -> some View {
        VStack(spacing: 16) {
            Text("Estadísticas")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            // League position
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text(String(team.position))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.blue)

                        Text("Posición")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 8) {
                        Text(String(team.points))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.blue)

                        Text("Puntos")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 8) {
                        Text("\(team.wins)-\(team.draws)-\(team.losses)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.blue)

                        Text("W-D-L")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)

                HStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text(String(team.goalsFor))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.green)

                        Text("Goles a favor")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 8) {
                        Text(String(team.goalsAgainst))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.red)

                        Text("Goles en contra")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 8) {
                        Text(String(team.goalsFor - team.goalsAgainst))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.blue)

                        Text("Diferencia")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Team Additional Info View
    @ViewBuilder
    private func teamAdditionalInfoView(_ team: Team) -> some View {
        VStack(spacing: 16) {
            Text("Información")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            VStack(spacing: 12) {
                InfoRow(label: "Entrenador", value: team.coach)
                InfoRow(label: "Estadio", value: team.stadium)
                InfoRow(label: "Capacidad", value: "\(team.capacity) espectadores")
                InfoRow(label: "Fundación", value: String(team.foundedYear))
                InfoRow(label: "País", value: team.country)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Team Roster View
    @ViewBuilder
    private func teamRosterView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                if viewModel.playersByPosition.isEmpty {
                    Text("No hay jugadores disponibles")
                        .foregroundStyle(.gray)
                        .padding(40)
                } else {
                    ForEach(Array(viewModel.playersByPosition.sorted { $0.key < $1.key }), id: \.key) { position, players in
                        PlayerPositionSection(
                            position: position,
                            players: players
                        ) { playerId in
                            viewModel.navigateToPlayerDetail(playerId: playerId)
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(
            viewModel: TeamDetailViewModel(
                router: TeamDetailRouter(),
                teamUseCase: TeamUseCase(repository: MockTeamRepository()),
                teamId: 1
            )
        )
    }
}

// Mock for preview
class MockTeamRepository: TeamRepositoryProtocol {
    func getTeam(id: Int) async throws -> Team {
        return Team(
            id: 1,
            name: "Inter Miami",
            logo: "https://example.com/inter-miami.png",
            city: "Miami",
            country: "USA",
            foundedYear: 2018,
            coach: "Gerardo Martino",
            coachImage: "",
            stadium: "Hard Rock Stadium",
            capacity: 65326,
            league: "MLS",
            position: 1,
            points: 72,
            wins: 22,
            draws: 6,
            losses: 6,
            goalsFor: 78,
            goalsAgainst: 42
        )
    }

    func getTeamPlayers(teamId: Int) async throws -> [Player] {
        return [
            Player(id: 1, name: "Lionel Messi", position: "Delantero", team: "Inter Miami", number: 10, image: "", nationality: "Argentina", age: 36, goals: 45, assists: 15, marketValue: 50000000, yellowCards: 2, redCards: 0, minutesPlayed: 2400, matchesPlayed: 32, height: "1.70 m", weight: "72 kg", foot: "Zurdo", fantasyPoints: 285.5, averageRating: 8.2),
            Player(id: 2, name: "Luis Suárez", position: "Delantero", team: "Inter Miami", number: 9, image: "", nationality: "Uruguay", age: 35, goals: 40, assists: 12, marketValue: 45000000, yellowCards: 3, redCards: 0, minutesPlayed: 2100, matchesPlayed: 28, height: "1.82 m", weight: "86 kg", foot: "Derecho", fantasyPoints: 265.0, averageRating: 7.8),
            Player(id: 3, name: "Sergio Busquets", position: "Centrocampista", team: "Inter Miami", number: 5, image: "", nationality: "España", age: 34, goals: 5, assists: 8, marketValue: 8000000, yellowCards: 4, redCards: 0, minutesPlayed: 1800, matchesPlayed: 24, height: "1.83 m", weight: "76 kg", foot: "Derecho", fantasyPoints: 155.0, averageRating: 7.5)
        ]
    }

    func getPlayersByPosition(teamId: Int, position: String) async throws -> [Player] {
        return []
    }

    func searchTeams(by name: String) async throws -> [Team] {
        return []
    }
}
