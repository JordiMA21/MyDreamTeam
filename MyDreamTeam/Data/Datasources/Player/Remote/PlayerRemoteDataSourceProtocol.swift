import Foundation

protocol PlayerRemoteDataSourceProtocol {
    func getPlayer(id: Int) async throws -> PlayerDTO
    func searchPlayers(by name: String) async throws -> [PlayerDTO]
    func getPlayersByTeam(teamId: Int) async throws -> [PlayerDTO]
    func getPlayersByPosition(position: String) async throws -> [PlayerDTO]
}
