import Foundation

// MARK: - Fantasy Squad Container

class FantasySquadContainer {
    static let shared = FantasySquadContainer()

    private init() {}

    // MARK: - DataSource

    func makeDataSource() -> FantasySquadFirestoreDataSourceProtocol {
        FantasySquadFirestoreDataSource()
    }

    // MARK: - Repository

    func makeRepository() -> FantasySquadRepositoryProtocol {
        FantasySquadRepository(dataSource: makeDataSource())
    }

    // MARK: - UseCase

    func makeUseCase() -> FantasySquadUseCaseProtocol {
        FantasySquadUseCase(repository: makeRepository())
    }
}
