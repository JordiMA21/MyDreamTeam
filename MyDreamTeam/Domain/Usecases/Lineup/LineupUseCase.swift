import Foundation

class LineupUseCase: LineupUseCaseProtocol {
    private let repository: LineupRepositoryProtocol

    init(repository: LineupRepositoryProtocol) {
        self.repository = repository
    }

    func getLineup(teamId: Int) async throws -> Lineup {
        try await repository.getLineup(teamId: teamId)
    }

    func saveLineup(_ lineup: Lineup) async throws {
        try await repository.saveLineup(lineup)
    }

    func updateLineup(_ lineup: Lineup) async throws {
        try await repository.updateLineup(lineup)
    }

    func deleteLineup(teamId: Int) async throws {
        try await repository.deleteLineup(teamId: teamId)
    }

    func filterPlayersByPosition(_ players: [Player], position: FormationPosition) -> [Player] {
        players.filter { player in
            let playerPosition = player.position.lowercased()
            switch position {
            case .goalkeeper:
                return playerPosition == "portero"
            case .defender:
                return playerPosition == "defensa"
            case .midfielder:
                return playerPosition == "centrocampista"
            case .forward:
                return playerPosition == "delantero"
            }
        }
    }
}
