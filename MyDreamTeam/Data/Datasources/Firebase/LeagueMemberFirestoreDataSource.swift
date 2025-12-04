import Foundation
import FirebaseFirestore

// MARK: - League Member Firestore DataSource Protocol

protocol LeagueMemberFirestoreDataSourceProtocol: AnyObject {
    func addMemberToLeague(leagueId: String, member: FirebaseLeagueMemberDTO) async throws
    func getMember(leagueId: String, userId: String) async throws -> FirebaseLeagueMemberDTO
    func updateMember(leagueId: String, userId: String, data: [String: Any]) async throws
    func removeMember(leagueId: String, userId: String) async throws
    func getLeagueMembers(leagueId: String) async throws -> [FirebaseLeagueMemberDTO]
    func getUserLeagues(userId: String) async throws -> [String] // Retorna leagueIds
    func getLeagueRanking(leagueId: String) async throws -> [FirebaseLeagueMemberDTO]
    func isMemberOfLeague(leagueId: String, userId: String) async throws -> Bool
}

// MARK: - League Member Firestore DataSource Implementation

final class LeagueMemberFirestoreDataSource: LeagueMemberFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let leaguesPath = "leagues"
    private let membersPath = "members"

    // MARK: - LeagueMemberFirestoreDataSourceProtocol

    func addMemberToLeague(leagueId: String, member: FirebaseLeagueMemberDTO) async throws {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(member)
            try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .document(member.userId)
                .setData(data)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getMember(leagueId: String, userId: String) async throws -> FirebaseLeagueMemberDTO {
        do {
            let snapshot = try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .document(userId)
                .getDocument()

            return try snapshot.data(as: FirebaseLeagueMemberDTO.self)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func updateMember(leagueId: String, userId: String, data: [String: Any]) async throws {
        do {
            try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .document(userId)
                .updateData(data)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func removeMember(leagueId: String, userId: String) async throws {
        do {
            try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .document(userId)
                .delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getLeagueMembers(leagueId: String) async throws -> [FirebaseLeagueMemberDTO] {
        do {
            let snapshot = try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .order(by: "rank", descending: false)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseLeagueMemberDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getUserLeagues(userId: String) async throws -> [String] {
        do {
            // Esta es una query más compleja que requiere un índice compuesto
            // Por ahora, obtenemos todas las ligas y filtramos en la app
            let allLeaguesSnapshot = try await db.collection(leaguesPath).getDocuments()

            var userLeagueIds: [String] = []

            for leagueDoc in allLeaguesSnapshot.documents {
                let leagueId = leagueDoc.documentID
                let membersSnapshot = try await db.collection(leaguesPath)
                    .document(leagueId)
                    .collection(membersPath)
                    .document(userId)
                    .getDocument()

                if membersSnapshot.exists {
                    userLeagueIds.append(leagueId)
                }
            }

            return userLeagueIds
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getLeagueRanking(leagueId: String) async throws -> [FirebaseLeagueMemberDTO] {
        do {
            let snapshot = try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .whereField("status", isEqualTo: "active")
                .order(by: "totalPoints", descending: true)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseLeagueMemberDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func isMemberOfLeague(leagueId: String, userId: String) async throws -> Bool {
        do {
            let snapshot = try await db.collection(leaguesPath)
                .document(leagueId)
                .collection(membersPath)
                .document(userId)
                .getDocument()

            return snapshot.exists
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
                return AppError.customError("Miembro no encontrado", 5)
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
