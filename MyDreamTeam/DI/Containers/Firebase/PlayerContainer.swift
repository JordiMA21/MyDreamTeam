import Foundation

// MARK: - Player Container

class PlayerContainer {
    static let shared = PlayerContainer()

    private init() {}

    // MARK: - DataSource

    func makeDataSource() -> PlayerRemoteDataSourceProtocol {
        PlayerRemoteDataSource(network: Config.shared.network)
    }

    // MARK: - Repository

    func makeRepository() -> PlayerRepositoryProtocol {
        PlayerRepository(dataSource: makeDataSource(), errorHandler: ErrorHandlerManager())
    }

    // MARK: - UseCase

    func makeUseCase() -> PlayerUseCaseProtocol {
        PlayerUseCase(repository: makeRepository())
    }
}
