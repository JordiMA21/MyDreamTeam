import Foundation

protocol PlayerUseCaseProtocol {
    func getPlayer(id: Int) async throws -> Player
    func searchPlayers(by name: String) async throws -> [Player]
    func getPlayersByTeam(teamId: Int) async throws -> [Player]
    func getPlayersByPosition(position: String) async throws -> [Player]
}
