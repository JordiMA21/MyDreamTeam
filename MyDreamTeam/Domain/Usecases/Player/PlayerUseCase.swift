import Foundation

class PlayerUseCase: PlayerUseCaseProtocol {
    private let repository: PlayerRepositoryProtocol

    init(repository: PlayerRepositoryProtocol) {
        self.repository = repository
    }

    func getPlayer(id: Int) async throws -> Player {
        try await repository.getPlayer(id: id)
    }

    func searchPlayers(by name: String) async throws -> [Player] {
        try await repository.searchPlayers(by: name)
    }

    func getPlayersByTeam(teamId: Int) async throws -> [Player] {
        try await repository.getPlayersByTeam(teamId: teamId)
    }

    func getPlayersByPosition(position: String) async throws -> [Player] {
        try await repository.getPlayersByPosition(position: position)
    }
}
