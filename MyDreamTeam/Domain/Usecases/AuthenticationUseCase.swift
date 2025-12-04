import Foundation

protocol AuthenticationUseCaseProtocol: AnyObject {
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() async throws
    func getCurrentUser() -> AuthenticatedUser?
    func deleteAccount() async throws
}

final class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let repository: AuthenticationRepositoryProtocol

    init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        try await repository.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        try await repository.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await repository.signOut()
    }

    func getCurrentUser() -> AuthenticatedUser? {
        repository.getCurrentUser()
    }

    func deleteAccount() async throws {
        try await repository.deleteAccount()
    }
}
