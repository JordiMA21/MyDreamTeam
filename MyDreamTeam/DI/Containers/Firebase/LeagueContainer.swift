import Foundation

// MARK: - League Container

class LeagueContainer {
    static let shared = LeagueContainer()

    private init() {}

    // MARK: - DataSources

    func makeLeagueDataSource() -> LeagueFirestoreDataSourceProtocol {
        LeagueFirestoreDataSource()
    }

    func makeMemberDataSource() -> LeagueMemberFirestoreDataSourceProtocol {
        LeagueMemberFirestoreDataSource()
    }

    // MARK: - Repository

    func makeRepository() -> LeagueRepositoryProtocol {
        LeagueRepository(
            leagueDataSource: makeLeagueDataSource(),
            memberDataSource: makeMemberDataSource()
        )
    }

    // MARK: - UseCase

    func makeUseCase() -> LeagueUseCaseProtocol {
        LeagueUseCase(repository: makeRepository())
    }
}
