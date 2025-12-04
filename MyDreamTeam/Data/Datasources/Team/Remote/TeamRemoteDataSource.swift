import Foundation
import TripleA

class TeamRemoteDataSource: TeamRemoteDataSourceProtocol {
    let network: Network

    init(network: Network) {
        self.network = network
    }

    func getTeam(id: Int) async throws -> TeamDTO {
        let endpoint = Endpoint(path: "api/teams/\(id)",
                                httpMethod: .get)
        return try await network.load(endpoint: endpoint, of: TeamDTO.self)
    }

    func getTeamPlayers(teamId: Int) async throws -> [PlayerDTO] {
        let query: [String: Any] = ["team_id": teamId]
        let endpoint = Endpoint(path: "api/players",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint, of: [PlayerDTO].self)
    }

    func getPlayersByPosition(teamId: Int, position: String) async throws -> [PlayerDTO] {
        let query: [String: Any] = ["team_id": teamId, "position": position]
        let endpoint = Endpoint(path: "api/players",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint, of: [PlayerDTO].self)
    }

    func searchTeams(by name: String) async throws -> [TeamDTO] {
        let query: [String: Any] = ["name": name]
        let endpoint = Endpoint(path: "api/teams/search",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint, of: [TeamDTO].self)
    }
}
