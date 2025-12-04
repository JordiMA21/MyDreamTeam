import SwiftUI

class TeamDetailRouter: Router {
    func navigateToPlayerDetail(playerId: Int) {
        let view = PlayerDetailBuilder().build(playerId: playerId)
        navigator.push(to: view)
    }

    func navigateToTeamComparison() {
        // Future: Implement team comparison
        showAlert(title: "Comparación", message: "Característica próxima")
    }
}
