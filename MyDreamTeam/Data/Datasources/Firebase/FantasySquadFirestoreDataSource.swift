import Foundation
import FirebaseFirestore

// MARK: - Fantasy Squad Firestore DataSource Protocol

protocol FantasySquadFirestoreDataSourceProtocol: AnyObject {
    func createSquad(squad: FirebaseFantasySquadDTO) async throws -> String
    func getSquad(squadId: String) async throws -> FirebaseFantasySquadDTO
    func getUserSquads(userId: String, leagueId: String) async throws -> FirebaseFantasySquadDTO?
    func updateSquad(squadId: String, data: [String: Any]) async throws
    func updatePlayers(squadId: String, players: [FantasyPlayerDTO], bench: [FantasyPlayerDTO]) async throws
    func addTransfer(squadId: String, transfer: FirebaseTransferDTO) async throws -> String
    func getTransferHistory(squadId: String) async throws -> [FirebaseTransferDTO]
    func getLatestTransfers(squadId: String, limit: Int) async throws -> [FirebaseTransferDTO]
    func observeSquad(squadId: String) -> AsyncStream<FirebaseFantasySquadDTO>
}

// MARK: - Fantasy Squad Firestore DataSource Implementation

final class FantasySquadFirestoreDataSource: FantasySquadFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let collectionPath = "fantasySquads"
    private let transfersPath = "transfers"

    // MARK: - FantasySquadFirestoreDataSourceProtocol

    func createSquad(squad: FirebaseFantasySquadDTO) async throws -> String {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(squad)
            let docRef = try await db.collection(collectionPath).addDocument(data: data)
            return docRef.documentID
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getSquad(squadId: String) async throws -> FirebaseFantasySquadDTO {
        do {
            let snapshot = try await db.collection(collectionPath).document(squadId).getDocument()
            return try snapshot.data(as: FirebaseFantasySquadDTO.self)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getUserSquads(userId: String, leagueId: String) async throws -> FirebaseFantasySquadDTO? {
        do {
            let snapshot = try await db.collection(collectionPath)
                .whereField("userId", isEqualTo: userId)
                .whereField("leagueId", isEqualTo: leagueId)
                .limit(to: 1)
                .getDocuments()

            return try snapshot.documents.first.flatMap { doc in
                try doc.data(as: FirebaseFantasySquadDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func updateSquad(squadId: String, data: [String: Any]) async throws {
        do {
            var mutableData = data
            mutableData["updatedAt"] = Date()
            try await db.collection(collectionPath).document(squadId).updateData(mutableData)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func updatePlayers(squadId: String, players: [FantasyPlayerDTO], bench: [FantasyPlayerDTO]) async throws {
        do {
            let encoder = Firestore.Encoder()
            let playersData = try encoder.encode(players)
            let benchData = try encoder.encode(bench)

            let totalValue = players.reduce(0) { $0 + $1.marketValue } +
                            bench.reduce(0) { $0 + $1.marketValue }
            let spent = totalValue
            let budget = 100.0 // Budget inicial (a configurar)
            let remaining = budget - spent

            let updateData: [String: Any] = [
                "players": playersData,
                "bench": benchData,
                "totalValue": totalValue,
                "budget.spent": spent,
                "budget.remaining": max(0, remaining),
                "updatedAt": Date()
            ]

            try await db.collection(collectionPath).document(squadId).updateData(updateData)
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func addTransfer(squadId: String, transfer: FirebaseTransferDTO) async throws -> String {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(transfer)
            let docRef = try await db.collection(collectionPath)
                .document(squadId)
                .collection(transfersPath)
                .addDocument(data: data)
            return docRef.documentID
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getTransferHistory(squadId: String) async throws -> [FirebaseTransferDTO] {
        do {
            let snapshot = try await db.collection(collectionPath)
                .document(squadId)
                .collection(transfersPath)
                .order(by: "date", descending: true)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseTransferDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func getLatestTransfers(squadId: String, limit: Int) async throws -> [FirebaseTransferDTO] {
        do {
            let snapshot = try await db.collection(collectionPath)
                .document(squadId)
                .collection(transfersPath)
                .order(by: "date", descending: true)
                .limit(to: limit)
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try doc.data(as: FirebaseTransferDTO.self)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }

    func observeSquad(squadId: String) -> AsyncStream<FirebaseFantasySquadDTO> {
        AsyncStream { continuation in
            let listener = db.collection(collectionPath).document(squadId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error observing squad: \(error)")
                        continuation.finish()
                        return
                    }

                    guard let snapshot = snapshot else { return }

                    do {
                        let squad = try snapshot.data(as: FirebaseFantasySquadDTO.self)
                        continuation.yield(squad)
                    } catch {
                        print("Error decoding squad: \(error)")
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
                return AppError.customError("No tienes permisos", 7)
            case 5: // Not found
                return AppError.customError("Equipo no encontrado", 5)
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
