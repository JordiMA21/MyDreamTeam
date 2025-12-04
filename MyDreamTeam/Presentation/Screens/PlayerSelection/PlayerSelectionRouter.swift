import SwiftUI

class PlayerSelectionRouter: Router {
    func navigateToPlayerDetail(playerId: String) {
        navigator.push(to: PlayerDetailBuilder.build(playerId: playerId))
    }

    func navigateToComparison(comparison: PlayerComparisonResult) {
        // Future: Implement player comparison view
        showAlert(title: "Comparación", message: "\(comparison.comparison.summary)")
    }

    func navigateToTeamDetail(teamId: String) {
        navigator.push(to: TeamDetailBuilder.build(teamId: teamId))
    }
}
