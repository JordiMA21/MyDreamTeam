import Foundation

protocol TeamUseCaseProtocol {
    func getTeam(id: Int) async throws -> Team
    func getTeamPlayers(teamId: Int) async throws -> [Player]
    func getPlayersByPosition(teamId: Int, position: String) async throws -> [Player]
    func searchTeams(by name: String) async throws -> [Team]
}
