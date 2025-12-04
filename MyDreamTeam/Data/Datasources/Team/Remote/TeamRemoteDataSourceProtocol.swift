import Foundation

protocol TeamRemoteDataSourceProtocol {
    func getTeam(id: Int) async throws -> TeamDTO
    func getTeamPlayers(teamId: Int) async throws -> [PlayerDTO]
    func getPlayersByPosition(teamId: Int, position: String) async throws -> [PlayerDTO]
    func searchTeams(by name: String) async throws -> [TeamDTO]
}
