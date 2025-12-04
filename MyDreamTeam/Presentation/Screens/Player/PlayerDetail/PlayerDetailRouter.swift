import SwiftUI

class PlayerDetailRouter: Router {
    func navigateToTeamPlayers(teamName: String) {
        // This would navigate to a team roster screen
        // For now, we'll just show an alert
        showAlert(title: "Equipo", message: "Jugadores de \(teamName)")
    }

    func comparePlayers() {
        // Navigate to player comparison screen
        let view = EmptyView()
        navigator.push(to: view)
    }
}
