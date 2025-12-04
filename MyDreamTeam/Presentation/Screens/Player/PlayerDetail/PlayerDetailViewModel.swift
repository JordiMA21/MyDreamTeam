import Foundation

class PlayerDetailViewModel: ObservableObject {
    // MARK: - Properties
    @Published var player: Player?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let router: PlayerDetailRouter
    private let playerUseCase: PlayerUseCaseProtocol
    private let playerId: Int

    // MARK: - Init
    init(router: PlayerDetailRouter, playerUseCase: PlayerUseCaseProtocol, playerId: Int) {
        self.router = router
        self.playerUseCase = playerUseCase
        self.playerId = playerId
    }

    // MARK: - Functions
    @MainActor
    func loadPlayer() {
        Task {
            do {
                isLoading = true
                player = try await playerUseCase.getPlayer(id: playerId)
                isLoading = false
            } catch {
                isLoading = false
                router.showAlert(with: error)
            }
        }
    }
}

// MARK: - Navigation Methods
extension PlayerDetailViewModel {
    func dismiss() {
        router.dismiss()
    }

    func navigateToTeamPlayers() {
        if let team = player?.team {
            router.navigateToTeamPlayers(teamName: team)
        }
    }

    func addPlayerToFantasyTeam() {
        if let player = player {
            router.showAlert(title: "Jugador agregado",
                           message: "\(player.name) se agregó a tu equipo",
                           action: { })
        }
    }
}
