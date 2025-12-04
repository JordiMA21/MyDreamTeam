import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - User Firestore DataSource Protocol

protocol UserFirestoreDataSourceProtocol: AnyObject {
    func createUser(user: FirebaseUserDTO) async throws
    func getUser(uid: String) async throws -> FirebaseUserDTO
    func updateUser(uid: String, data: [String: Any]) async throws
    func deleteUser(uid: String) async throws
    func observeUser(uid: String) -> AsyncStream<FirebaseUserDTO>
}

// MARK: - User Firestore DataSource Implementation

final class UserFirestoreDataSource: UserFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let collectionPath = "users"

    // MARK: - UserFirestoreDataSourceProtocol

    func createUser(user: FirebaseUserDTO) async throws {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(user)
            try await db.collection(collectionPath).document(user.uid).setData(data)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getUser(uid: String) async throws -> FirebaseUserDTO {
        do {
            let snapshot = try await db.collection(collectionPath).document(uid).getDocument()
            return try snapshot.data(as: FirebaseUserDTO.self)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        do {
            try await db.collection(collectionPath).document(uid).updateData(data)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func deleteUser(uid: String) async throws {
        do {
            try await db.collection(collectionPath).document(uid).delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func observeUser(uid: String) -> AsyncStream<FirebaseUserDTO> {
        AsyncStream { continuation in
            let listener = db.collection(collectionPath).document(uid)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error observing user: \(error)")
                        continuation.finish()
                        return
                    }

                    guard let snapshot = snapshot else { return }

                    do {
                        let user = try snapshot.data(as: FirebaseUserDTO.self)
                        continuation.yield(user)
                    } catch {
                        print("Error decoding user: \(error)")
                        continuation.finish()
                    }
                }

            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    // MARK: - Private Methods

    private func mapFirestoreError(_ error: Error) -> Error {
        let nsError = error as NSError

        if nsError.domain == "FIRFirestoreErrorDomain" {
            switch nsError.code {
            case 7: // Permission denied
                return AppError.customError("No tienes permisos para acceder", nsError.code)
            case 5: // Not found
                return AppError.customError("Usuario no encontrado", nsError.code)
            case 14: // Unavailable
                return AppError.noInternet
            case 16: // Unauthenticated
                return AppError.badCredentials("No autenticado")
            default:
                return AppError.generalError
            }
        }

        return error
    }
}
