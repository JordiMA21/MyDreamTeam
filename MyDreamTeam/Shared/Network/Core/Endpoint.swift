//
//  Endpoint.swift
//  iOSTemplate
//
//  Created by AUTHOR_NAME on DATE
//  Copyright © YEAR AUTHOR_NAME. All rights reserved.
//

import Foundation

/// Protocolo que define la estructura de un endpoint de API
/// Inspirado en TripleA - Patrón de definición de endpoints
protocol Endpoint {
    /// El path relativo del endpoint (ej: "/users")
    var path: String { get }

    /// El método HTTP a usar (GET, POST, PUT, DELETE, etc)
    var method: HTTPMethod { get }

    /// Los parámetros a enviar en la URL (para GET) o en el body (para POST)
    var parameters: [String: Any]? { get }

    /// Headers específicos del endpoint (además de los globales)
    var headers: [String: String]? { get }

    /// El tipo de contenido (application/json, multipart/form-data, etc)
    var contentType: ContentType { get }

    /// Parámetros de query string opcionales
    var queryParameters: [String: String]? { get }
}

// Extensión con valores por defecto
extension Endpoint {
    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }
    var contentType: ContentType { .json }
}

/// Enumeración de métodos HTTP soportados
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}

/// Tipos de contenido soportados
enum ContentType: String {
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case plainText = "text/plain"
    case xml = "application/xml"
}

/// Estructura de configuración para un endpoint
struct EndpointConfiguration {
    let baseURL: URL
    let timeout: TimeInterval
    let headers: [String: String]

    init(
        baseURL: URL,
        timeout: TimeInterval = 30,
        headers: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.headers = headers
    }
}
