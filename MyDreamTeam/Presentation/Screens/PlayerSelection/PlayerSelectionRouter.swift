import SwiftUI

class PlayerSelectionRouter: Router {
    func navigateToPlayerDetail(playerId: Int) {
        navigator.push(to: PlayerDetailBuilder.build(playerId: playerId))
    }

    func navigateToComparison(comparison: PlayerComparisonResult) {
        // Future: Implement player comparison view
        showAlert(title: "Comparación", message: "\(comparison.summary)")
    }

    func navigateToTeamDetail(teamId: Int) {
        navigator.push(to: TeamDetailBuilder.build(teamId: teamId))
    }
}
