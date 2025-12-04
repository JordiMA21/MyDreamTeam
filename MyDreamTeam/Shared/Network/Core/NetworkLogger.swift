//
//  NetworkLogger.swift
//  iOSTemplate
//
//  Created by AUTHOR_NAME on DATE
//  Copyright © YEAR AUTHOR_NAME. All rights reserved.
//

import Foundation

/// Logger para debugging de peticiones y respuestas de red
/// Inspirado en TripleA - Patrón de logging configurado
class NetworkLogger {
    // MARK: - Properties

    var isEnabled: Bool = true
    var logLevel: LogLevel = .info

    enum LogLevel {
        case verbose // Todo
        case debug   // Peticiones y respuestas completas
        case info    // Solo información importante
        case warning // Solo warnings y errores
        case error   // Solo errores
        case none    // Desactivado
    }

    // MARK: - Public Methods

    func log(request: URLRequest) {
        guard isEnabled, logLevel != .none else { return }

        let emoji = "📤"
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "UNKNOWN"

        switch logLevel {
        case .verbose, .debug:
            var log = "\n\(emoji) ─────────────────────────────────────────\n"
            log += "REQUEST: \(method) \(url)\n"

            if let headers = request.allHTTPHeaderFields {
                log += "HEADERS:\n"
                for (key, value) in headers {
                    // No loguear tokens completos por seguridad
                    let sanitizedValue = sanitize(value, for: key)
                    log += "  \(key): \(sanitizedValue)\n"
                }
            }

            if let body = request.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                log += "BODY:\n  \(bodyString)\n"
            }

            log += "─────────────────────────────────────────\n"
            print(log)

        case .info:
            print("\(emoji) \(method) \(url)")

        case .warning, .error, .none:
            break
        }
    }

    func log(data: Data?, response: URLResponse) {
        guard isEnabled, logLevel != .none else { return }

        let emoji = "📥"
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let statusEmoji = statusCode >= 200 && statusCode < 300 ? "✅" : "❌"

        switch logLevel {
        case .verbose, .debug:
            var log = "\n\(emoji) ─────────────────────────────────────────\n"
            log += "RESPONSE: \(statusEmoji) \(statusCode)\n"

            if let data = data,
               let jsonString = try? JSONSerialization.jsonObject(
                   with: data,
                   options: [.fragmentsAllowed]
               ),
               let prettyData = try? JSONSerialization.data(
                   withJSONObject: jsonString,
                   options: [.prettyPrinted]
               ),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                log += "DATA:\n\(prettyString)\n"
            } else if let data = data {
                log += "DATA:\n\(String(data: data, encoding: .utf8) ?? "UNREADABLE")\n"
            }

            log += "─────────────────────────────────────────\n"
            print(log)

        case .info:
            print("\(emoji) \(statusEmoji) \(statusCode)")

        case .warning, .error, .none:
            break
        }
    }

    func log(message: String) {
        guard isEnabled else { return }

        switch logLevel {
        case .verbose, .debug, .info:
            print("ℹ️ \(message)")
        case .warning, .error, .none:
            break
        }
    }

    func log(error: Error) {
        guard isEnabled else { return }

        switch logLevel {
        case .verbose, .debug, .info, .warning, .error:
            print("❌ Error: \(error.localizedDescription)")
        case .none:
            break
        }
    }

    // MARK: - Private Methods

    private func sanitize(_ value: String, for key: String) -> String {
        // Ocultar tokens y credenciales
        let sensitiveKeys = ["authorization", "x-api-key", "token", "password"]
        let lowerKey = key.lowercased()

        if sensitiveKeys.contains(where: { lowerKey.contains($0) }) {
            return "[HIDDEN]"
        }

        // Limitar longitud de valores largos
        return value.count > 100 ? String(value.prefix(100)) + "..." : value
    }
}
