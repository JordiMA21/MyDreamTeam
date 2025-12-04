import Foundation

// MARK: - User Container

class UserContainer {
    static let shared = UserContainer()

    private init() {}

    // MARK: - DataSource

    func makeDataSource() -> UserFirestoreDataSourceProtocol {
        UserFirestoreDataSource()
    }

    // MARK: - Repository

    func makeRepository() -> UserRepositoryProtocol {
        UserRepository(dataSource: makeDataSource())
    }

    // MARK: - UseCase

    func makeUseCase() -> UserUseCaseProtocol {
        UserUseCase(repository: makeRepository())
    }
}
