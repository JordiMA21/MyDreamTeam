import Foundation

class PlayerTeamRouter: Router {
    // MARK: - Navigation Methods
    func navigateToPlayerDetail(playerId: Int) {
        let builder = PlayerDetailBuilder()
        let detailView = builder.build(playerId: playerId)
        navigator.push(to: detailView)
    }
}
