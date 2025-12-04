import Foundation
import FirebaseAuth

// MARK: - Fantasy Squad UseCase Protocol

protocol FantasySquadUseCaseProtocol: AnyObject {
    func createSquad(leagueId: String, leagueName: String, teamName: String) async throws -> String
    func getSquad(squadId: String) async throws -> FantasySquadEntity
    func getUserSquad(leagueId: String) async throws -> FantasySquadEntity?
    func updateTeamName(squadId: String, newName: String) async throws
    func addPlayer(squadId: String, player: FantasyPlayerEntity) async throws
    func removePlayer(squadId: String, playerId: String) async throws
    func transferPlayer(squadId: String, playerOut: FantasyPlayerEntity, playerIn: FantasyPlayerEntity) async throws
    func setCaptain(squadId: String, playerId: String) async throws
    func setViceCaptain(squadId: String, playerId: String) async throws
    func getSquadStats(squadId: String) async throws -> SquadStatsEntity
    func getTransferHistory(squadId: String) async throws -> [TransferEntity]
    func validateFormation(players: [FantasyPlayerEntity]) async throws -> Bool
    func observeSquad(squadId: String) -> AsyncStream<FantasySquadEntity>
}

// MARK: - Fantasy Squad UseCase Implementation

final class FantasySquadUseCase: FantasySquadUseCaseProtocol {
    private let repository: FantasySquadRepositoryProtocol

    init(repository: FantasySquadRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - FantasySquadUseCaseProtocol

    func createSquad(leagueId: String, leagueName: String, teamName: String) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        guard !teamName.isEmpty else {
            throw AppError.inputError("teamName", "El nombre del equipo es obligatorio")
        }

        guard teamName.count <= 30 else {
            throw AppError.inputError("teamName", "El nombre no puede exceder 30 caracteres")
        }

        let budget = BudgetEntity(
            total: 100.0,
            spent: 0,
            remaining: 100.0,
            currency: "EUR"
        )

        let squad = FantasySquadEntity(
            id: UUID().uuidString,
            leagueId: leagueId,
            userId: userId,
            leagueName: leagueName,
            teamName: teamName,
            createdAt: Date(),
            updatedAt: Date(),
            formation: "4-3-3",
            players: [],
            bench: [],
            budget: budget,
            totalValue: 0
        )

        return try await repository.createSquad(squad: squad)
    }

    func getSquad(squadId: String) async throws -> FantasySquadEntity {
        return try await repository.getSquad(squadId: squadId)
    }

    func getUserSquad(leagueId: String) async throws -> FantasySquadEntity? {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        return try await repository.getUserSquad(userId: userId, leagueId: leagueId)
    }

    func updateTeamName(squadId: String, newName: String) async throws {
        guard !newName.isEmpty else {
            throw AppError.inputError("teamName", "El nombre no puede estar vacío")
        }

        guard newName.count <= 30 else {
            throw AppError.inputError("teamName", "El nombre no puede exceder 30 caracteres")
        }

        try await repository.updateSquad(squadId: squadId, data: [
            "teamName": newName,
            "updatedAt": Date()
        ])
    }

    func addPlayer(squadId: String, player: FantasyPlayerEntity) async throws {
        let squad = try await repository.getSquad(squadId: squadId)

        // Validar que no hay duplicado
        if squad.players.contains(where: { $0.id == player.id }) ||
           squad.bench.contains(where: { $0.id == player.id }) {
            throw AppError.customError("Este jugador ya está en tu equipo", nil)
        }

        // Validar presupuesto
        let newSpent = squad.budget.spent + player.marketValue
        guard newSpent <= squad.budget.total else {
            throw AppError.customError("Presupuesto insuficiente", nil)
        }

        // Validar límite de posición (simplificado: máximo 3 de la misma posición)
        let playersInPosition = squad.players.filter { $0.position == player.position }.count
        guard playersInPosition < 3 else {
            throw AppError.customError("Ya tienes el máximo de \(player.position)", nil)
        }

        // Agregar a principales si es posible, si no al banquillo
        var updatedPlayers = squad.players
        var updatedBench = squad.bench

        if updatedPlayers.count < 11 {
            updatedPlayers.append(player)
        } else if updatedBench.count < 4 {
            updatedBench.append(player)
        } else {
            throw AppError.customError("Equipo completo (11 principales + 4 banquillo)", nil)
        }

        try await repository.updateSquadPlayers(squadId: squadId, players: updatedPlayers, bench: updatedBench)
    }

    func removePlayer(squadId: String, playerId: String) async throws {
        let squad = try await repository.getSquad(squadId: squadId)

        var updatedPlayers = squad.players.filter { $0.id != playerId }
        var updatedBench = squad.bench.filter { $0.id != playerId }

        guard updatedPlayers.count + updatedBench.count < squad.players.count + squad.bench.count else {
            throw AppError.customError("Jugador no encontrado", nil)
        }

        try await repository.updateSquadPlayers(squadId: squadId, players: updatedPlayers, bench: updatedBench)
    }

    func transferPlayer(squadId: String, playerOut: FantasyPlayerEntity, playerIn: FantasyPlayerEntity) async throws {
        let squad = try await repository.getSquad(squadId: squadId)

        // Validar que playerOut está en el equipo
        guard squad.players.contains(where: { $0.id == playerOut.id }) ||
              squad.bench.contains(where: { $0.id == playerOut.id }) else {
            throw AppError.customError("El jugador a cambiar no está en tu equipo", nil)
        }

        // Validar que playerIn no está en el equipo
        if squad.players.contains(where: { $0.id == playerIn.id }) ||
           squad.bench.contains(where: { $0.id == playerIn.id }) {
            throw AppError.customError("Este jugador ya está en tu equipo", nil)
        }

        // Calcular si hay presupuesto disponible
        let transferFee = playerIn.marketValue - playerOut.marketValue
        let newSpent = squad.budget.spent + transferFee
        guard newSpent <= squad.budget.total else {
            throw AppError.customError("Presupuesto insuficiente para esta transferencia", nil)
        }

        // Realizar la transferencia
        var updatedPlayers = squad.players
        var updatedBench = squad.bench

        // Reemplazar en jugadores principales
        if let index = updatedPlayers.firstIndex(where: { $0.id == playerOut.id }) {
            updatedPlayers[index] = playerIn
        } else if let index = updatedBench.firstIndex(where: { $0.id == playerOut.id }) {
            updatedBench[index] = playerIn
        }

        // Registrar transferencia
        let transfer = TransferEntity(
            id: UUID().uuidString,
            squadId: squadId,
            playerOutId: playerOut.id,
            playerOutName: "\(playerOut.firstName) \(playerOut.lastName)",
            playerInId: playerIn.id,
            playerInName: "\(playerIn.firstName) \(playerIn.lastName)",
            transferFee: transferFee,
            date: Date(),
            gameweek: 1, // Por implementar
            pointsChange: 0
        )

        try await repository.addTransfer(squadId: squadId, transfer: transfer)
        try await repository.updateSquadPlayers(squadId: squadId, players: updatedPlayers, bench: updatedBench)
    }

    func setCaptain(squadId: String, playerId: String) async throws {
        guard !playerId.isEmpty else {
            throw AppError.inputError("playerId", "Jugador inválido")
        }

        try await repository.setCaptain(squadId: squadId, playerId: playerId, isViceCaptain: false)
    }

    func setViceCaptain(squadId: String, playerId: String) async throws {
        guard !playerId.isEmpty else {
            throw AppError.inputError("playerId", "Jugador inválido")
        }

        try await repository.setCaptain(squadId: squadId, playerId: playerId, isViceCaptain: true)
    }

    func getSquadStats(squadId: String) async throws -> SquadStatsEntity {
        return try await repository.getSquadStats(squadId: squadId)
    }

    func getTransferHistory(squadId: String) async throws -> [TransferEntity] {
        return try await repository.getTransferHistory(squadId: squadId)
    }

    func validateFormation(players: [FantasyPlayerEntity]) async throws -> Bool {
        let goalkeepers = players.filter { $0.position == "GK" }.count
        let defenders = players.filter { $0.position == "DEF" }.count
        let midfielders = players.filter { $0.position == "MID" }.count
        let forwards = players.filter { $0.position == "FWD" }.count

        // Validar que hay 11 jugadores
        guard players.count == 11 else {
            throw AppError.customError("Necesitas exactamente 11 jugadores en campo", nil)
        }

        // Validar formación: 1 GK, 3-5 DEF, 2-5 MID, 1-3 FWD
        guard goalkeepers == 1 else {
            throw AppError.customError("Necesitas exactamente 1 portero", nil)
        }

        guard (3...5).contains(defenders) else {
            throw AppError.customError("Necesitas entre 3 y 5 defensores", nil)
        }

        guard (2...5).contains(midfielders) else {
            throw AppError.customError("Necesitas entre 2 y 5 centrocampistas", nil)
        }

        guard (1...3).contains(forwards) else {
            throw AppError.customError("Necesitas entre 1 y 3 delanteros", nil)
        }

        return true
    }

    func observeSquad(squadId: String) -> AsyncStream<FantasySquadEntity> {
        return repository.observeSquad(squadId: squadId)
    }
}
