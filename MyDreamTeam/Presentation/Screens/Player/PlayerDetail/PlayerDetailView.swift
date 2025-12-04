import SwiftUI

struct PlayerDetailView: View {
    @StateObject var viewModel: PlayerDetailViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
            } else if let player = viewModel.player {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header with player image and basic info
                        playerHeaderView(player)

                        // Player basic info
                        playerBasicInfoView(player)

                        // Statistics section
                        playerStatsSection(player)

                        // Additional info section
                        playerAdditionalInfoSection(player)

                        // Action buttons
                        playerActionButtonsView()

                        Spacer()
                            .frame(height: 20)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                    Text("No se pudieron cargar los datos del jugador")
                        .font(.headline)
                    Button("Reintentar") {
                        viewModel.loadPlayer()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Detalle del Jugador")
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
            viewModel.loadPlayer()
        }
    }

    // MARK: - Header View
    @ViewBuilder
    private func playerHeaderView(_ player: Player) -> some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                // Player image placeholder
                Image(systemName: "person.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .frame(width: 120, height: 120)
                    .background(Circle().fill(Color.white.opacity(0.1)))

                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Text(player.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        Text("#\(player.number)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))

                        Spacer()
                    }

                    HStack(spacing: 12) {
                        Label(player.position, systemImage: "target")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))

                        Divider()
                            .frame(height: 16)

                        Label(player.team, systemImage: "sportscourt.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
        }
        .frame(height: 280)
    }

    // MARK: - Basic Info View
    @ViewBuilder
    private func playerBasicInfoView(_ player: Player) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(String(player.age))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)

                    Text("Edad")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }

                VStack(spacing: 8) {
                    Text(player.nationality)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)
                        .lineLimit(1)

                    Text("Nacionalidad")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }

                VStack(spacing: 8) {
                    Text(player.foot)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)

                    Text("Pie")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Spacer()
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Statistics Section
    @ViewBuilder
    private func playerStatsSection(_ player: Player) -> some View {
        VStack(spacing: 12) {
            Text("Estadísticas")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            // Stats grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatCard(title: "Goles", value: String(player.goals), icon: "figure.soccer")
                    StatCard(title: "Asistencias", value: String(player.assists), icon: "hand.raised.fill")
                    StatCard(title: "Amarillas", value: String(player.yellowCards), icon: "square.fill")
                }

                HStack(spacing: 12) {
                    StatCard(title: "Rojas", value: String(player.redCards), icon: "square.fill")
                    StatCard(title: "Partidos", value: String(player.matchesPlayed), icon: "calendar")
                    StatCard(title: "Minutos", value: String(player.minutesPlayed / 60) + "h", icon: "clock.fill")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Additional Info Section
    @ViewBuilder
    private func playerAdditionalInfoSection(_ player: Player) -> some View {
        VStack(spacing: 16) {
            Text("Información Adicional")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            // Fantasy stats
            VStack(spacing: 12) {
                InfoRow(label: "Puntos Fantasy", value: String(format: "%.1f", player.fantasyPoints))
                InfoRow(label: "Calificación Promedio", value: String(format: "%.1f", player.averageRating))
                InfoRow(label: "Valor de Mercado", value: String(format: "€%.0f", player.marketValue))
                InfoRow(label: "Altura", value: player.height)
                InfoRow(label: "Peso", value: player.weight)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private func playerActionButtonsView() -> some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.addPlayerToFantasyTeam()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Agregar a mi equipo")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }

            Button(action: {
                viewModel.navigateToTeamPlayers()
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("Ver equipo")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.white.opacity(0.1))
                .foregroundStyle(.blue)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.3), lineWidth: 1))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.blue)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        PlayerDetailView(
            viewModel: PlayerDetailViewModel(
                router: PlayerDetailRouter(),
                playerUseCase: PlayerUseCase(repository: MockPlayerRepository()),
                playerId: 1
            )
        )
    }
}

// Mock for preview
class MockPlayerRepository: PlayerRepositoryProtocol {
    func getPlayer(id: Int) async throws -> Player {
        return Player(
            id: 1,
            name: "Lionel Messi",
            position: "Delantero",
            team: "Inter Miami",
            number: 10,
            image: "https://example.com/messi.jpg",
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
        )
    }

    func searchPlayers(by name: String) async throws -> [Player] {
        return []
    }

    func getPlayersByTeam(teamId: Int) async throws -> [Player] {
        return []
    }

    func getPlayersByPosition(position: String) async throws -> [Player] {
        return []
    }
}
