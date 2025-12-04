import Foundation
import TripleA

class PlayerRemoteDataSource: PlayerRemoteDataSourceProtocol {
    let network: TripleA.Network

    init(network: TripleA.Network) {
        self.network = network
    }

    func getPlayer(id: Int) async throws -> PlayerDTO {
        let endpoint = TripleA.Endpoint(path: "api/players/\(id)",
                                        httpMethod: .get)
        return try await network.load(endpoint: endpoint, of: PlayerDTO.self)
    }

    func searchPlayers(by name: String) async throws -> [PlayerDTO] {
        let query: [String: Any] = ["name": name]
        let endpoint = TripleA.Endpoint(path: "api/players/search",
                                        httpMethod: .get,
                                        query: query)
        return try await network.load(endpoint: endpoint, of: [PlayerDTO].self)
    }

    func getPlayersByTeam(teamId: Int) async throws -> [PlayerDTO] {
        let query: [String: Any] = ["team_id": teamId]
        let endpoint = TripleA.Endpoint(path: "api/players",
                                        httpMethod: .get,
                                        query: query)
        return try await network.load(endpoint: endpoint, of: [PlayerDTO].self)
    }

    func getPlayersByPosition(position: String) async throws -> [PlayerDTO] {
        let query: [String: Any] = ["position": position]
        let endpoint = TripleA.Endpoint(path: "api/players",
                                        httpMethod: .get,
                                        query: query)
        return try await network.load(endpoint: endpoint, of: [PlayerDTO].self)
    }
}
