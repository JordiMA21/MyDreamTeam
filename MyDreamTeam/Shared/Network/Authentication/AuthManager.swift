//
//  AuthManager.swift
//  iOSTemplate
//
//  Created by AUTHOR_NAME on DATE
//  Copyright © YEAR AUTHOR_NAME. All rights reserved.
//

import Foundation

/// Gestor de autenticación - Maneja tokens y renovación automática
/// Inspirado en TripleA - Patrón de autenticación OAuth2
@available(iOS 13.0, *)
class AuthManager: ObservableObject {
    // MARK: - Properties

    @Published var isAuthenticated = false
    @Published var currentToken: String? {
        didSet {
            if let token = currentToken {
                tokenStore.saveToken(token)
            } else {
                tokenStore.clearToken()
            }
        }
    }

    private let tokenStore: TokenStore
    private let network: Network
    private let config: AuthConfig

    // MARK: - Init

    init(
        tokenStore: TokenStore = UserDefaultsTokenStore(),
        network: Network,
        config: AuthConfig
    ) {
        self.tokenStore = tokenStore
        self.network = network
        self.config = config
        self.currentToken = tokenStore.retrieveToken()
        self.isAuthenticated = currentToken != nil
    }

    // MARK: - Authentication Methods

    /// Realiza login con credenciales
    /// - Parameters:
    ///   - username: Nombre de usuario
    ///   - password: Contraseña
    /// - Throws: AuthError en caso de fallo
    func login(username: String, password: String) async throws {
        let credentials = LoginCredentials(username: username, password: password)
        let endpoint = AuthEndpoint.login(credentials: credentials)

        let response: AuthResponse = try await network.request(
            endpoint: endpoint,
            responseType: AuthResponse.self
        )

        await MainActor.run {
            self.currentToken = response.accessToken
            self.isAuthenticated = true
        }
    }

    /// Realiza logout
    func logout() {
        currentToken = nil
        isAuthenticated = false
    }

    /// Refresca el token si está disponible
    /// - Throws: AuthError en caso de fallo
    func refreshToken() async throws {
        guard let refreshToken = tokenStore.retrieveRefreshToken() else {
            throw AuthError.noRefreshToken
        }

        let endpoint = AuthEndpoint.refresh(refreshToken: refreshToken)

        let response: AuthResponse = try await network.request(
            endpoint: endpoint,
            responseType: AuthResponse.self
        )

        await MainActor.run {
            self.currentToken = response.accessToken
        }
    }

    /// Valida si el token es aún válido
    func isTokenValid() -> Bool {
        guard let token = currentToken else {
            return false
        }

        // Aquí podrías decodificar el JWT y validar la expiración
        // Por ahora, simplemente verificamos que no esté vacío
        return !token.isEmpty
    }
}

/// Estructura de credenciales de login
struct LoginCredentials: Encodable {
    let username: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}

/// Respuesta de autenticación
struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

/// Configuración de autenticación
struct AuthConfig {
    let clientId: String
    let clientSecret: String?
    let grantType: GrantType

    enum GrantType {
        case password
        case clientCredentials
        case implicit
    }

    init(
        clientId: String,
        clientSecret: String? = nil,
        grantType: GrantType = .password
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.grantType = grantType
    }
}

/// Errores de autenticación
enum AuthError: LocalizedError {
    case invalidCredentials
    case noRefreshToken
    case tokenExpired
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Credenciales inválidas"
        case .noRefreshToken:
            return "No hay token de refresco disponible"
        case .tokenExpired:
            return "Token expirado"
        case .unauthorized:
            return "No autorizado"
        case let .unknown(error):
            return error.localizedDescription
        }
    }
}

/// Almacenamiento de tokens
protocol TokenStore {
    func saveToken(_ token: String)
    func retrieveToken() -> String?
    func saveRefreshToken(_ token: String)
    func retrieveRefreshToken() -> String?
    func clearToken()
    func clearRefreshToken()
}

/// Implementación de almacenamiento con UserDefaults
class UserDefaultsTokenStore: TokenStore {
    private let accessTokenKey = "com.mydreamteam.accessToken"
    private let refreshTokenKey = "com.mydreamteam.refreshToken"

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
    }

    func retrieveToken() -> String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }

    func saveRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: refreshTokenKey)
    }

    func retrieveRefreshToken() -> String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
    }

    func clearRefreshToken() {
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}

/// Endpoints de autenticación
enum AuthEndpoint: Endpoint {
    case login(credentials: LoginCredentials)
    case refresh(refreshToken: String)

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .refresh:
            return "/auth/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .refresh:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case let .login(credentials):
            return [
                "username": credentials.username,
                "password": credentials.password,
                "grant_type": "password"
            ]
        case let .refresh(refreshToken):
            return [
                "refresh_token": refreshToken,
                "grant_type": "refresh_token"
            ]
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
