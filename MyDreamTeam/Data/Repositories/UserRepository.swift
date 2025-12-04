import Foundation

// MARK: - User Repository Protocol

protocol UserRepositoryProtocol: AnyObject {
    func createUser(user: UserEntity) async throws
    func getUser(uid: String) async throws -> UserEntity
    func updateUserProfile(uid: String, displayName: String, bio: String) async throws
    func deleteUser(uid: String) async throws
    func observeUser(uid: String) -> AsyncStream<UserEntity>
}

// MARK: - User Repository Implementation

final class UserRepository: UserRepositoryProtocol {
    private let dataSource: UserFirestoreDataSourceProtocol
    private let errorHandler: ErrorHandlerProtocol

    init(
        dataSource: UserFirestoreDataSourceProtocol,
        errorHandler: ErrorHandlerProtocol = ErrorHandlerManager()
    ) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    // MARK: - UserRepositoryProtocol

    func createUser(user: UserEntity) async throws {
        do {
            let dto = user.toFirebaseDTO()
            try await dataSource.createUser(user: dto)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getUser(uid: String) async throws -> UserEntity {
        do {
            let dto = try await dataSource.getUser(uid: uid)
            return dto.toDomain()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func updateUserProfile(uid: String, displayName: String, bio: String) async throws {
        do {
            let data: [String: Any] = [
                "displayName": displayName,
                "bio": bio,
                "updatedAt": Date()
            ]
            try await dataSource.updateUser(uid: uid, data: data)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func deleteUser(uid: String) async throws {
        do {
            try await dataSource.deleteUser(uid: uid)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func observeUser(uid: String) -> AsyncStream<UserEntity> {
        AsyncStream { continuation in
            Task {
                for await dto in dataSource.observeUser(uid: uid) {
                    continuation.yield(dto.toDomain())
                }
            }
        }
    }
}
