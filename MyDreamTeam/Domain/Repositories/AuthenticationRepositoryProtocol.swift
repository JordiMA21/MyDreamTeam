import Foundation

protocol AuthenticationRepositoryProtocol: AnyObject {
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() async throws
    func getCurrentUser() -> AuthenticatedUser?
    func deleteAccount() async throws
}
