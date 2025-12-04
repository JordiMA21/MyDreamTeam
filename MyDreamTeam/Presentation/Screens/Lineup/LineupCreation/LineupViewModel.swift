import Foundation

class LineupViewModel: ObservableObject {
    // MARK: - Properties
    @Published var lineup: Lineup
    @Published var availablePlayers: [Player] = []
    @Published var isLoading = false
    @Published var selectedSlotIndex: Int?
    @Published var showPlayerSelection = false

    private let router: LineupRouter
    private let lineupUseCase: LineupUseCaseProtocol
    private let teamUseCase: TeamUseCaseProtocol
    private let teamId: Int

    // MARK: - Init
    init(
        router: LineupRouter,
        lineupUseCase: LineupUseCaseProtocol,
        teamUseCase: TeamUseCaseProtocol,
        teamId: Int
    ) {
        self.router = router
        self.lineupUseCase = lineupUseCase
        self.teamUseCase = teamUseCase
        self.teamId = teamId
        self.lineup = Lineup(id: 0, teamId: teamId)
    }

    // MARK: - Functions
    @MainActor
    func loadLineupData() {
        Task {
            do {
                isLoading = true
                // Simulate network delay
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                // Load or create lineup
                do {
                    lineup = try await lineupUseCase.getLineup(teamId: teamId)
                } catch {
                    // Si no existe, crear una nueva
                    lineup = Lineup(id: 0, teamId: teamId)
                }

                // Load team players
                availablePlayers = try await teamUseCase.getTeamPlayers(teamId: teamId)
                isLoading = false
            } catch {
                isLoading = false
                router.showAlert(with: error)
            }
        }
    }

    @MainActor
    func assignPlayerToSlot(_ player: Player, slotIndex: Int) {
        lineup.assignPlayerToSlot(player, slotIndex: slotIndex)
        selectedSlotIndex = nil
        showPlayerSelection = false
    }

    @MainActor
    func removePlayerFromSlot(_ slotIndex: Int) {
        lineup.removePlayerFromSlot(slotIndex)
    }

    func getPlayersForSlot(_ slotIndex: Int) -> [Player] {
        guard slotIndex < lineup.slots.count else { return [] }
        let position = lineup.slots[slotIndex].position
        return lineupUseCase.filterPlayersByPosition(availablePlayers, position: position)
    }

    func getFilteredPlayers() -> [Player] {
        guard let slotIndex = selectedSlotIndex else { return [] }
        return getPlayersForSlot(slotIndex)
    }

    @MainActor
    func changeFormation(_ newFormation: FormationType) {
        lineup.updateFormation(newFormation)
    }

    @MainActor
    func saveLineup() {
        Task {
            do {
                try await lineupUseCase.saveLineup(lineup)
                router.showAlert(title: "Éxito", message: "Alineación guardada correctamente")
            } catch {
                router.showAlert(with: error)
            }
        }
    }
}

// MARK: - Navigation Methods
extension LineupViewModel {
    func dismiss() {
        router.dismiss()
    }

    func selectSlot(_ index: Int) {
        selectedSlotIndex = index
        showPlayerSelection = true
    }

    func openSlotForSelection(_ slotIndex: Int) {
        selectedSlotIndex = slotIndex
        showPlayerSelection = true
    }
}
