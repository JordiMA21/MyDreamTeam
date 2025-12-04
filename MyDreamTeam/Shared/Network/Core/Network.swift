//
//  Network.swift
//  iOSTemplate
//
//  Created by AUTHOR_NAME on DATE
//  Copyright © YEAR AUTHOR_NAME. All rights reserved.
//

import Foundation

/// Network es el gestor principal de todas las llamadas HTTP
/// Implementa async/await para operaciones asincrónicas modernas
/// Inspirado en TripleA - Patrón de red centralizado
@available(iOS 13.0, *)
class Network {
    // MARK: - Properties

    static let shared = Network()

    private let session: URLSession
    private let baseURL: URL
    private var authManager: AuthManager?
    private let logger: NetworkLogger

    // MARK: - Init

    init(
        baseURL: URL = URL(string: "https://api.example.com")!,
        session: URLSession = .shared,
        authManager: AuthManager? = nil,
        logger: NetworkLogger = NetworkLogger()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.authManager = authManager
        self.logger = logger
    }

    // MARK: - Generic Request Method

    /// Realiza una petición HTTP genérica
    /// - Parameters:
    ///   - endpoint: El endpoint a usar
    ///   - responseType: El tipo de respuesta esperada (Decodable)
    /// - Returns: La respuesta decodificada
    /// - Throws: NetworkError en caso de fallo
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        // Construir la petición
        let request = try buildRequest(for: endpoint)

        logger.log(request: request)

        // Realizar la petición
        let (data, response) = try await session.data(for: request)

        // Validar la respuesta
        try validateResponse(response)

        logger.log(data: data, response: response)

        // Decodificar la respuesta
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    /// Realiza una petición HTTP sin esperar respuesta (void)
    /// - Parameters:
    ///   - endpoint: El endpoint a usar
    /// - Throws: NetworkError en caso de fallo
    func requestVoid(endpoint: Endpoint) async throws {
        let request = try buildRequest(for: endpoint)

        logger.log(request: request)

        let (_, response) = try await session.data(for: request)

        try validateResponse(response)

        logger.log(data: nil, response: response)
    }

    /// Realiza una descarga de archivo
    /// - Parameters:
    ///   - endpoint: El endpoint a usar
    ///   - destination: URL de destino del archivo
    /// - Throws: NetworkError en caso de fallo
    func downloadFile(
        endpoint: Endpoint,
        to destination: URL
    ) async throws {
        let request = try buildRequest(for: endpoint)

        logger.log(request: request)

        let (tempURL, response) = try await session.download(for: request)

        try validateResponse(response)

        try FileManager.default.moveItem(at: tempURL, to: destination)

        logger.log(message: "File downloaded to \(destination)")
    }

    // MARK: - Private Methods

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        // Construir la URL
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path = endpoint.path

        // Agregar query parameters
        if let queryParameters = endpoint.queryParameters {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30

        // Agregar headers globales
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Agregar headers específicos del endpoint
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Agregar token de autenticación si está disponible
        if let token = authManager?.currentToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Agregar body si es necesario
        if let parameters = endpoint.parameters, endpoint.method != .get {
            request.setValue(
                endpoint.contentType.rawValue,
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }

        return request
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            // Success
            break
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - Configuration

    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }

    func setBaseURL(_ url: URL) {
        // Nota: En una implementación real, podrías hacer esto mutable
        // Por ahora, recrea la instancia si necesitas cambiar la URL base
    }
}

/// Errores de red posibles
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case httpError(Int)
    case noInternet
    case timeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case let .decodingError(error):
            return "Error al decodificar: \(error.localizedDescription)"
        case .unauthorized:
            return "No autorizado (401)"
        case .forbidden:
            return "Acceso prohibido (403)"
        case .notFound:
            return "Recurso no encontrado (404)"
        case let .serverError(code):
            return "Error del servidor (\(code))"
        case let .httpError(code):
            return "Error HTTP (\(code))"
        case .noInternet:
            return "Sin conexión a internet"
        case .timeout:
            return "Tiempo de espera agotado"
        case let .unknown(error):
            return "Error desconocido: \(error.localizedDescription)"
        }
    }
}
