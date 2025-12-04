import Foundation

class PlayerTeamViewModel: ObservableObject {
    // MARK: - Properties
    @Published var lineup: Lineup
    @Published var isLoading = false
    @Published var selectedTab: TeamTab = .field

    private let router: PlayerTeamRouter
    private let lineupUseCase: LineupUseCaseProtocol
    let teamId: Int

    enum TeamTab {
        case field
        case roster
    }

    // MARK: - Init
    init(
        router: PlayerTeamRouter,
        lineupUseCase: LineupUseCaseProtocol,
        teamId: Int
    ) {
        self.router = router
        self.lineupUseCase = lineupUseCase
        self.teamId = teamId
        self.lineup = Lineup(id: 0, teamId: teamId)
    }

    // MARK: - Functions
    @MainActor
    func loadLineupData() {
        Task {
            do {
                isLoading = true
                // Load or create lineup
                do {
                    lineup = try await lineupUseCase.getLineup(teamId: teamId)
                } catch {
                    // Si no existe, crear una nueva
                    lineup = Lineup(id: 0, teamId: teamId)
                }
                isLoading = false
            } catch {
                isLoading = false
                router.showAlert(with: error)
            }
        }
    }

    // MARK: - Navigation Methods
    func dismiss() {
        router.dismiss()
    }

    func didSelectPlayer(_ player: Player) {
        router.navigateToPlayerDetail(playerId: player.id)
    }

    // MARK: - Data Helpers
    func getPlayersByPosition(_ position: FormationPosition) -> [Player] {
        return lineup.slots
            .filter { $0.position == position && $0.player != nil }
            .compactMap { $0.player }
    }

    func countPlayersByPosition(_ position: FormationPosition) -> Int {
        return getPlayersByPosition(position).count
    }
}
