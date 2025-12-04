import Foundation
import FirebaseAuth

protocol FirebaseAuthDataSourceProtocol: AnyObject {
    func signUp(email: String, password: String) async throws -> AuthUserDTO
    func signIn(email: String, password: String) async throws -> AuthUserDTO
    func signOut() async throws
    func getCurrentUser() -> AuthUserDTO?
    func deleteAccount() async throws
}

final class FirebaseAuthDataSource: FirebaseAuthDataSourceProtocol {
    private let auth = Auth.auth()

    func signUp(email: String, password: String) async throws -> AuthUserDTO {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return AuthUserDTO(from: result.user)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthUserDTO {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return AuthUserDTO(from: result.user)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func signOut() async throws {
        do {
            try auth.signOut()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func getCurrentUser() -> AuthUserDTO? {
        guard let user = auth.currentUser else { return nil }
        return AuthUserDTO(from: user)
    }

    func deleteAccount() async throws {
        do {
            try await auth.currentUser?.delete()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    private func mapFirebaseError(_ error: NSError) -> AppError {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .generalError
        }

        switch code {
        case .invalidEmail:
            return .inputError("email", "Email inválido")
        case .weakPassword:
            return .inputError("password", "La contraseña es demasiado débil (mínimo 6 caracteres)")
        case .emailAlreadyInUse:
            return .customError("El email ya está registrado", nil)
        case .userNotFound:
            return .badCredentials("Usuario no encontrado")
        case .wrongPassword:
            return .badCredentials("Contraseña incorrecta")
        case .networkError:
            return .noInternet
        default:
            return .generalError
        }
    }
}
