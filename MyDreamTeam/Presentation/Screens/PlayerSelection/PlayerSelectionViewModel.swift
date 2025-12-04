import Foundation

// MARK: - Player Selection ViewModel

class PlayerSelectionViewModel: ObservableObject {
    // MARK: - Properties
    @Published var players: [Player] = []
    @Published var filteredPlayers: [Player] = []
    @Published var selectedPosition: String = "FWD"
    @Published var searchText: String = ""
    @Published var isLoading = false

    @Published var selectedPlayers: [Player] = []
    @Published var remainingBudget: Double = 100.0
    @Published var playersByPosition: [String: [Player]] = [:]

    private let router: PlayerSelectionRouter
    private let playerUseCase: PlayerUseCaseProtocol
    private let fantasySortedUseCase: FantasySquadUseCaseProtocol
    private let squadId: String
    private let season: Int

    // MARK: - Init

    init(
        router: PlayerSelectionRouter,
        playerUseCase: PlayerUseCaseProtocol,
        fantasySortedUseCase: FantasySquadUseCaseProtocol,
        squadId: String,
        season: Int
    ) {
        self.router = router
        self.playerUseCase = playerUseCase
        self.fantasySortedUseCase = fantasySortedUseCase
        self.squadId = squadId
        self.season = season
    }

    // MARK: - Load Players

    @MainActor
    func loadPlayersByPosition() {
        Task {
            do {
                isLoading = true
                players = try await playerUseCase.getAvailablePlayers(
                    for: selectedPosition,
                    season: season
                )
                applyFilters()
                isLoading = false
            } catch {
                isLoading = false
                router.showAlert(with: error)
            }
        }
    }

    // MARK: - Search and Filter

    func applyFilters() {
        if searchText.isEmpty {
            filteredPlayers = players
        } else {
            Task {
                do {
                    let searchResults = try await playerUseCase.searchPlayers(by: searchText)
                    filteredPlayers = searchResults
                        .filter { $0.position == selectedPosition }
                        .sorted(by: { $0.marketValue > $1.marketValue })
                } catch {
                    router.showAlert(with: error)
                }
            }
        }
    }

    func changePosition(_ newPosition: String) {
        selectedPosition = newPosition
        searchText = ""
        Task {
            await loadPlayersByPosition()
        }
    }

    // MARK: - Player Selection

    func addPlayerToSquad(_ player: Player) {
        guard !isPlayerSelected(player) else {
            router.showToastWithCloseAction(with: "Este jugador ya está en tu equipo")
            return
        }

        guard remainingBudget >= player.marketValue else {
            router.showAlert(
                title: "Presupuesto Insuficiente",
                message: "No tienes presupuesto suficiente para este jugador",
                action: {}
            )
            return
        }

        Task {
            do {
                try await fantasySortedUseCase.addPlayer(squadId: squadId, player: FantasyPlayerEntity(
                    id: String(player.id),
                    firstName: player.name.components(separatedBy: " ").first ?? player.name,
                    lastName: player.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                    position: player.position,
                    currentTeam: player.team,
                    number: player.number,
                    marketValue: player.marketValue,
                    weekPoints: 0,
                    totalPoints: 0,
                    isCaptain: false,
                    isViceCaptain: false,
                    addedAt: Date()
                ))

                selectedPlayers.append(player)
                remainingBudget -= player.marketValue
                router.showToastWithCloseAction(with: "\(player.name) agregado al equipo")
            } catch {
                router.showAlert(with: error)
            }
        }
    }

    func removePlayerFromSquad(_ player: Player) {
        Task {
            do {
                try await fantasySortedUseCase.removePlayer(squadId: squadId, playerId: String(player.id))

                if let index = selectedPlayers.firstIndex(where: { $0.id == player.id }) {
                    selectedPlayers.remove(at: index)
                    remainingBudget += player.marketValue
                    router.showToastWithCloseAction(with: "\(player.name) removido del equipo")
                }
            } catch {
                router.showAlert(with: error)
            }
        }
    }

    func isPlayerSelected(_ player: Player) -> Bool {
        selectedPlayers.contains { $0.id == player.id }
    }

    // MARK: - Player Comparison

    func compareWithPlayer(_ player: Player) {
        guard selectedPlayers.count > 0 else {
            router.showAlert(
                title: "Sin Jugador Seleccionado",
                message: "Selecciona un jugador primero para comparar",
                action: {}
            )
            return
        }

        let comparison = playerUseCase.comparePlayerStats(player, selectedPlayers[0])
        router.navigateToComparison(comparison: comparison)
    }

    // MARK: - Stats

    var totalBudgetSpent: Double {
        100.0 - remainingBudget
    }

    var budgetPercentage: Double {
        guard totalBudgetSpent > 0 else { return 0 }
        return (totalBudgetSpent / 100.0) * 100
    }

    var canAddMorePlayers: Bool {
        remainingBudget > 0 && selectedPlayers.count < 15
    }
}
