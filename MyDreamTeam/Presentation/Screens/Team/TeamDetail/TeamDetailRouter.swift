import SwiftUI

class TeamDetailRouter: Router {
    func navigateToPlayerDetail(playerId: Int) {
        navigator.push(to: PlayerDetailBuilder.build(playerId: playerId))
    }

    func navigateToTeamComparison() {
        // Future: Implement team comparison
        showAlert(title: "Comparación", message: "Característica próxima")
    }
}
