import Foundation

final class AuthenticationContainer {
    static let shared = AuthenticationContainer()
    private init() {}

    func makeUseCase() -> AuthenticationUseCaseProtocol {
        let dataSource = FirebaseAuthDataSource()
        let repository = AuthenticationRepository(dataSource: dataSource)
        return AuthenticationUseCase(repository: repository)
    }
}
