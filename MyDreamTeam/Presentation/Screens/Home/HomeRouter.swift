import Foundation

class HomeRouter: Router {
    func navigateToTeamDetail(teamId: Int = 1) {
        navigator.push(to: TeamDetailBuilder.build(teamId: teamId))
    }

    func navigateToPlayerDetail(playerId: Int = 1) {
        navigator.push(to: PlayerDetailBuilder.build(playerId: playerId))
    }

    func navigateToLineup(teamId: Int = 1) {
        navigator.push(to: LineupBuilder.build(teamId: teamId))
    }

    func navigateToPlayerTeam(teamId: Int = 1) {
        navigator.push(to: PlayerTeamBuilder.build(teamId: teamId))
    }
}
