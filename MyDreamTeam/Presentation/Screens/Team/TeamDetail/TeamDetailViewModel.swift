import Foundation

class TeamDetailViewModel: ObservableObject {
    // MARK: - Properties
    @Published var team: Team?
    @Published var players: [Player] = []
    @Published var playersByPosition: [String: [Player]] = [:]
    @Published var isLoading = false
    @Published var selectedTab = 0 // 0 = Info, 1 = Plantilla

    private let router: TeamDetailRouter
    private let teamUseCase: TeamUseCaseProtocol
    private let teamId: Int

    // MARK: - Init
    init(router: TeamDetailRouter, teamUseCase: TeamUseCaseProtocol, teamId: Int) {
        self.router = router
        self.teamUseCase = teamUseCase
        self.teamId = teamId
    }

    // MARK: - Functions
    @MainActor
    func loadTeamData() {
        Task {
            do {
                isLoading = true
                // Simulate network delay
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                team = try await teamUseCase.getTeam(id: teamId)
                players = try await teamUseCase.getTeamPlayers(teamId: teamId)

                // Group players by position
                playersByPosition = Dictionary(grouping: players, by: { $0.position })
                    .sorted { $0.key < $1.key }
                    .reduce(into: [:]) { dict, item in
                        dict[item.key] = item.value.sorted { $0.number < $1.number }
                    }

                isLoading = false
            } catch {
                isLoading = false
                router.showAlert(with: error)
            }
        }
    }
}

// MARK: - Navigation Methods
extension TeamDetailViewModel {
    func dismiss() {
        router.dismiss()
    }

    func navigateToPlayerDetail(playerId: Int) {
        router.navigateToPlayerDetail(playerId: playerId)
    }

    func getPositionIcon(_ position: String) -> String {
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
