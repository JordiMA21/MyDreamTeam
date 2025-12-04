import Foundation

class HomeViewModel: ObservableObject {
    private let router: HomeRouter

    init(router: HomeRouter) {
        self.router = router
    }

    func openTeamDetail() {
        router.navigateToTeamDetail(teamId: 1)
    }

    func openPlayerDetail() {
        router.navigateToPlayerDetail(playerId: 1)
    }

    func openLineup() {
        router.navigateToLineup(teamId: 1)
    }

    func openPlayerTeam() {
        router.navigateToPlayerTeam(teamId: 1)
    }
}
