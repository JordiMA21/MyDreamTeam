import Foundation

class TeamUseCase: TeamUseCaseProtocol {
    private let repository: TeamRepositoryProtocol

    init(repository: TeamRepositoryProtocol) {
        self.repository = repository
    }

    func getTeam(id: Int) async throws -> Team {
        try await repository.getTeam(id: id)
    }

    func getTeamPlayers(teamId: Int) async throws -> [Player] {
        try await repository.getTeamPlayers(teamId: teamId)
    }

    func getPlayersByPosition(teamId: Int, position: String) async throws -> [Player] {
        try await repository.getPlayersByPosition(teamId: teamId, position: position)
    }

    func searchTeams(by name: String) async throws -> [Team] {
        try await repository.searchTeams(by: name)
    }
}
