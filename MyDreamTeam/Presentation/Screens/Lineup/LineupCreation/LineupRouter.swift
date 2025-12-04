import SwiftUI

class LineupRouter: Router {
    func goToPlayerDetail(playerId: Int) {
        navigator.push(to: PlayerDetailBuilder.build(playerId: playerId))
    }

    func goToTeamDetail(teamId: Int) {
        navigator.push(to: TeamDetailBuilder.build(teamId: teamId))
    }
}
