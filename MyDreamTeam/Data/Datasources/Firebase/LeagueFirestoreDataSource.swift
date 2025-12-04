import Foundation
import FirebaseFirestore

// MARK: - League Firestore DataSource Protocol

protocol LeagueFirestoreDataSourceProtocol: AnyObject {
    func createLeague(league: FirebaseLeagueDTO) async throws -> String
    func getLeague(leagueId: String) async throws -> FirebaseLeagueDTO
    func updateLeague(leagueId: String, data: [String: Any]) async throws
    func deleteLeague(leagueId: String) async throws
    func getUserCreatedLeagues(userId: String) async throws -> [FirebaseLeagueDTO]
    func getPublicLeagues(season: Int) async throws -> [FirebaseLeagueDTO]
    func searchLeagues(query: String) async throws -> [FirebaseLeagueDTO]
    func getLeaguesByStatus(status: String) async throws -> [FirebaseLeagueDTO]
}

// MARK: - League Firestore DataSource Implementation

final class LeagueFirestoreDataSource: LeagueFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let collectionPath = "leagues"

    // MARK: - LeagueFirestoreDataSourceProtocol

    func createLeague(league: FirebaseLeagueDTO) async throws -> String {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(league)
            let docRef = try await db.collection(collectionPath).addDocument(data: data)
            return docRef.documentID
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getLeague(leagueId: String) async throws -> FirebaseLeagueDTO {
        do {
            let snapshot = try await db.collection(collectionPath).document(leagueId).getDocument()
            return try snapshot.data(as: FirebaseLeagueDTO.self)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func updateLeague(leagueId: String, data: [String: Any]) async throws {
        do {
            try await db.collection(collectionPath).document(leagueId).updateData(data)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func deleteLeague(leagueId: String) async throws {
        do {
            try await db.collection(collectionPath).document(leagueId).delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getUserCreatedLeagues(userId: String) async throws -> [FirebaseLeagueDTO] {
        do {
            let snapshot = try await db.collection(collectionPath)
                .whereField("createdBy", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseLeagueDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getPublicLeagues(season: Int) async throws -> [FirebaseLeagueDTO] {
        do {
            let snapshot = try await db.collection(collectionPath)
                .whereField("settings.isPublic", isEqualTo: true)
                .whereField("season", isEqualTo: season)
                .whereField("status", isEqualTo: "active")
                .order(by: "totalPlayers", descending: true)
                .limit(to: 50)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseLeagueDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func searchLeagues(query: String) async throws -> [FirebaseLeagueDTO] {
        do {
            let snapshot = try await db.collection(collectionPath)
                .whereField("name", isGreaterThanOrEqualTo: query)
                .whereField("name", isLessThan: query + "z")
                .limit(to: 20)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseLeagueDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getLeaguesByStatus(status: String) async throws -> [FirebaseLeagueDTO] {
        do {
            let snapshot = try await db.collection(collectionPath)
                .whereField("status", isEqualTo: status)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseLeagueDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    // MARK: - Private Methods

    private func mapFirestoreError(_ error: Error) -> Error {
        let nsError = error as NSError

        if nsError.domain == "FIRFirestoreErrorDomain" {
            switch nsError.code {
            case 7: // Permission denied
                return AppError.customError("No tienes permisos para acceder", 7)
            case 5: // Not found
                return AppError.customError("Liga no encontrada", 5)
            case 14: // Unavailable
                return AppError.noInternet
            case 16: // Unauthenticated
                return AppError.badCredentials("Unauthenticated")
            default:
                return AppError.customError("Error de Firestore: \(nsError.localizedDescription)", nsError.code)
            }
        }

        return AppError.generalError
    }
}
