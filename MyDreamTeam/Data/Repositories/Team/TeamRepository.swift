import Foundation

class TeamRepository: TeamRepositoryProtocol {
    // MARK: - Properties
    private let dataSource: TeamRemoteDataSourceProtocol
    private let errorHandler: ErrorHandlerProtocol

    // MARK: - Init
    init(dataSource: TeamRemoteDataSourceProtocol, errorHandler: ErrorHandlerProtocol) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    // MARK: - Functions
    func getTeam(id: Int) async throws -> Team {
        do {
            let responseDTO = try await dataSource.getTeam(id: id)
            return responseDTO.toDomain()
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getTeamPlayers(teamId: Int) async throws -> [Player] {
        do {
            let responseDTO = try await dataSource.getTeamPlayers(teamId: teamId)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getPlayersByPosition(teamId: Int, position: String) async throws -> [Player] {
        do {
            let responseDTO = try await dataSource.getPlayersByPosition(teamId: teamId, position: position)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func searchTeams(by name: String) async throws -> [Team] {
        do {
            let responseDTO = try await dataSource.searchTeams(by: name)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }
}
