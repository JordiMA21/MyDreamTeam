import SwiftUI

class LineupRouter: Router {
    func goToPlayerDetail(playerId: Int) {
        let view = PlayerDetailBuilder().build(playerId: playerId)
        navigator.push(to: view)
    }

    func goToTeamDetail(teamId: Int) {
        let view = TeamDetailBuilder().build(teamId: teamId)
        navigator.push(to: view)
    }
}
