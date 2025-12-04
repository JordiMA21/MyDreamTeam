import Foundation

class PlayerRepository: PlayerRepositoryProtocol {
    // MARK: - Properties
    private let dataSource: PlayerRemoteDataSourceProtocol
    private let errorHandler: ErrorHandlerProtocol

    // MARK: - Init
    init(dataSource: PlayerRemoteDataSourceProtocol, errorHandler: ErrorHandlerProtocol) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    // MARK: - Functions
    func getPlayer(id: Int) async throws -> Player {
        do {
            let responseDTO = try await dataSource.getPlayer(id: id)
            return responseDTO.toDomain()
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func searchPlayers(by name: String) async throws -> [Player] {
        do {
            let responseDTO = try await dataSource.searchPlayers(by: name)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getPlayersByTeam(teamId: Int) async throws -> [Player] {
        do {
            let responseDTO = try await dataSource.getPlayersByTeam(teamId: teamId)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getPlayersByPosition(position: String) async throws -> [Player] {
        do {
            let responseDTO = try await dataSource.getPlayersByPosition(position: position)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }
}
