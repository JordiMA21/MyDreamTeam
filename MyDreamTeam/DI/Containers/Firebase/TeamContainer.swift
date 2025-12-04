import Foundation

// MARK: - Team Container

class TeamContainer {
    static let shared = TeamContainer()

    private init() {}

    // MARK: - DataSource

    func makeDataSource() -> TeamRemoteDataSourceProtocol {
        TeamRemoteDataSource(network: Config.shared.network)
    }

    // MARK: - Repository

    func makeRepository() -> TeamRepositoryProtocol {
        TeamRepository(dataSource: makeDataSource(), errorHandler: ErrorHandlerManager())
    }

    // MARK: - UseCase

    func makeUseCase() -> TeamUseCaseProtocol {
        TeamUseCase(repository: makeRepository())
    }
}
