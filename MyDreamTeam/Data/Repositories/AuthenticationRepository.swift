import Foundation

final class AuthenticationRepository: AuthenticationRepositoryProtocol {
    private let dataSource: FirebaseAuthDataSourceProtocol

    init(dataSource: FirebaseAuthDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        let dto = try await dataSource.signUp(email: email, password: password)
        return dto.toDomain()
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        let dto = try await dataSource.signIn(email: email, password: password)
        return dto.toDomain()
    }

    func signOut() async throws {
        try await dataSource.signOut()
    }

    func getCurrentUser() -> AuthenticatedUser? {
        dataSource.getCurrentUser()?.toDomain()
    }

    func deleteAccount() async throws {
        try await dataSource.deleteAccount()
    }
}
