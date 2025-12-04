import Foundation

// MARK: - Fantasy Squad Repository Protocol

protocol FantasySquadRepositoryProtocol: AnyObject {
    func createSquad(squad: FantasySquadEntity) async throws -> String
    func getSquad(squadId: String) async throws -> FantasySquadEntity
    func getUserSquad(userId: String, leagueId: String) async throws -> FantasySquadEntity?
    func updateSquad(squadId: String, data: [String: Any]) async throws
    func updateSquadPlayers(squadId: String, players: [FantasyPlayerEntity], bench: [FantasyPlayerEntity]) async throws
    func addTransfer(squadId: String, transfer: TransferEntity) async throws
    func getTransferHistory(squadId: String) async throws -> [TransferEntity]
    func getLatestTransfers(squadId: String, limit: Int) async throws -> [TransferEntity]
    func setCaptain(squadId: String, playerId: String, isViceCaptain: Bool) async throws
    func getSquadStats(squadId: String) async throws -> SquadStatsEntity
    func observeSquad(squadId: String) -> AsyncStream<FantasySquadEntity>
}

// MARK: - Fantasy Squad Repository Implementation

final class FantasySquadRepository: FantasySquadRepositoryProtocol {
    private let dataSource: FantasySquadFirestoreDataSourceProtocol
    private let errorHandler: ErrorHandlerProtocol

    init(
        dataSource: FantasySquadFirestoreDataSourceProtocol,
        errorHandler: ErrorHandlerProtocol = ErrorHandlerManager()
    ) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    // MARK: - FantasySquadRepositoryProtocol

    func createSquad(squad: FantasySquadEntity) async throws -> String {
        do {
            let dto = squad.toFirebaseDTO()
            return try await dataSource.createSquad(squad: dto)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getSquad(squadId: String) async throws -> FantasySquadEntity {
        do {
            let dto = try await dataSource.getSquad(squadId: squadId)
            return dto.toDomain()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getUserSquad(userId: String, leagueId: String) async throws -> FantasySquadEntity? {
        do {
            guard let dto = try await dataSource.getUserSquads(userId: userId, leagueId: leagueId) else {
                return nil
            }
            return dto.toDomain()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func updateSquad(squadId: String, data: [String: Any]) async throws {
        do {
            try await dataSource.updateSquad(squadId: squadId, data: data)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func updateSquadPlayers(squadId: String, players: [FantasyPlayerEntity], bench: [FantasyPlayerEntity]) async throws {
        do {
            let playersDTO = players.map { $0.toDTO() }
            let benchDTO = bench.map { $0.toDTO() }
            try await dataSource.updatePlayers(squadId: squadId, players: playersDTO, bench: benchDTO)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func addTransfer(squadId: String, transfer: TransferEntity) async throws {
        do {
            let dto = transfer.toFirebaseDTO()
            try await dataSource.addTransfer(squadId: squadId, transfer: dto)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getTransferHistory(squadId: String) async throws -> [TransferEntity] {
        do {
            let dtos = try await dataSource.getTransferHistory(squadId: squadId)
            return dtos.map { $0.toDomain() }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getLatestTransfers(squadId: String, limit: Int) async throws -> [TransferEntity] {
        do {
            let dtos = try await dataSource.getLatestTransfers(squadId: squadId, limit: limit)
            return dtos.map { $0.toDomain() }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func setCaptain(squadId: String, playerId: String, isViceCaptain: Bool) async throws {
        do {
            // Primero, obtener el equipo
            let squad = try await getSquad(squadId: squadId)

            // Quitar captain/vicecaptain de otros jugadores
            var updatedPlayers = squad.players.map { player in
                var mutablePlayer = player
                if isViceCaptain {
                    mutablePlayer.isViceCaptain = false
                } else {
                    mutablePlayer.isCaptain = false
                }
                return mutablePlayer
            }

            // Establecer nuevo captain/vicecaptain
            if let index = updatedPlayers.firstIndex(where: { $0.id == playerId }) {
                if isViceCaptain {
                    updatedPlayers[index].isViceCaptain = true
                } else {
                    updatedPlayers[index].isCaptain = true
                }
            }

            // Actualizar en Firestore
            try await updateSquadPlayers(squadId: squadId, players: updatedPlayers, bench: squad.bench)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getSquadStats(squadId: String) async throws -> SquadStatsEntity {
        do {
            let squad = try await getSquad(squadId: squadId)

            let totalSquadValue = squad.players.reduce(0) { $0 + $1.marketValue } +
                                 squad.bench.reduce(0) { $0 + $1.marketValue }
            let averagePlayerValue = totalSquadValue / Double(squad.players.count + squad.bench.count)
            let weekPoints = squad.players.reduce(0) { $0 + $1.weekPoints }
            let totalPoints = squad.players.reduce(0) { $0 + $1.totalPoints }
            let captainName = squad.players.first(where: { $0.isCaptain })?.firstName ?? nil

            // Calcular fuerza del banquillo (0-100)
            let benchStrength: Double
            if squad.bench.isEmpty {
                benchStrength = 0
            } else {
                let benchPoints = squad.bench.reduce(0) { $0 + $1.totalPoints }
                benchStrength = min(100, (Double(benchPoints) / Double(squad.bench.count)) * 10)
            }

            // Verificar cumplimiento de formación (simplificado)
            let defenders = squad.players.filter { $0.position == "DEF" }.count
            let midfielders = squad.players.filter { $0.position == "MID" }.count
            let forwards = squad.players.filter { $0.position == "FWD" }.count
            let goalkeepers = squad.players.filter { $0.position == "GK" }.count

            let formationCompliance = goalkeepers == 1 && defenders >= 3 && midfielders >= 3 && forwards >= 1

            return SquadStatsEntity(
                totalSquadValue: totalSquadValue,
                averagePlayerValue: averagePlayerValue,
                totalTransfers: 0, // Se obtiene del historial
                transfersRemaining: 2, // Por implementar
                weekPoints: weekPoints,
                totalPoints: totalPoints,
                captainChoice: captainName,
                benchStrength: benchStrength,
                formationCompliance: formationCompliance
            )
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func observeSquad(squadId: String) -> AsyncStream<FantasySquadEntity> {
        AsyncStream { continuation in
            Task {
                for await dto in dataSource.observeSquad(squadId: squadId) {
                    continuation.yield(dto.toDomain())
                }
            }
        }
    }
}
