import Foundation
import FirebaseAuth

// MARK: - User UseCase Protocol

protocol UserUseCaseProtocol: AnyObject {
    func getCurrentUser() async throws -> UserEntity
    func getUser(uid: String) async throws -> UserEntity
    func updateUserProfile(displayName: String, bio: String) async throws
    func setFavoriteTeam(teamId: String) async throws
    func observeCurrentUserProfile() -> AsyncStream<UserEntity>
}

// MARK: - User UseCase Implementation

final class UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - UserUseCaseProtocol

    func getCurrentUser() async throws -> UserEntity {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }
        return try await repository.getUser(uid: uid)
    }

    func getUser(uid: String) async throws -> UserEntity {
        return try await repository.getUser(uid: uid)
    }

    func updateUserProfile(displayName: String, bio: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        try await repository.updateUserProfile(uid: uid, displayName: displayName, bio: bio)
    }

    func setFavoriteTeam(teamId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        _ = [
            "preferences.favoriteTeam": teamId,
            "updatedAt": Date()
        ]

        try await repository.updateUserProfile(uid: uid, displayName: "", bio: "")
    }

    func observeCurrentUserProfile() -> AsyncStream<UserEntity> {
        guard let uid = Auth.auth().currentUser?.uid else {
            return AsyncStream { continuation in
                print("Error: Usuario no autenticado")
                continuation.finish()
            }
        }

        return repository.observeUser(uid: uid)
    }
}
