import Foundation

class PlayerTeamRouter: Router {
    // MARK: - Navigation Methods
    func navigateToPlayerDetail(playerId: Int) {
        navigator.push(to: PlayerDetailBuilder.build(playerId: playerId))
    }
}
