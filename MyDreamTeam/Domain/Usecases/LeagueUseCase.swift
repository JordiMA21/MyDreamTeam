import Foundation
import FirebaseAuth

// MARK: - League UseCase Protocol

protocol LeagueUseCaseProtocol: AnyObject {
    func createLeague(name: String, description: String, season: Int, scoringRules: ScoringRulesEntity) async throws -> String
    func getLeague(leagueId: String) async throws -> LeagueEntity
    func deleteLeague(leagueId: String) async throws
    func getUserCreatedLeagues() async throws -> [LeagueEntity]
    func getUserJoinedLeagues() async throws -> [LeagueEntity]
    func getPublicLeagues(season: Int) async throws -> [LeagueEntity]
    func searchLeagues(query: String) async throws -> [LeagueEntity]
    func joinLeague(leagueId: String, teamName: String) async throws
    func leaveLeague(leagueId: String) async throws
    func getLeagueRanking(leagueId: String) async throws -> [LeagueMemberEntity]
    func updateTeamName(leagueId: String, newName: String) async throws
    func isUserMemberOfLeague(leagueId: String) async throws -> Bool
}

// MARK: - League UseCase Implementation

final class LeagueUseCase: LeagueUseCaseProtocol {
    private let repository: LeagueRepositoryProtocol

    init(repository: LeagueRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - LeagueUseCaseProtocol

    func createLeague(name: String, description: String, season: Int, scoringRules: ScoringRulesEntity) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        guard !name.isEmpty else {
            throw AppError.inputError("name", "El nombre de la liga es obligatorio")
        }

        guard name.count <= 50 else {
            throw AppError.inputError("name", "El nombre no puede exceder 50 caracteres")
        }

        let now = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 9, to: now) ?? now

        let league = LeagueEntity(
            id: UUID().uuidString,
            name: name,
            description: description,
            createdBy: userId,
            createdAt: now,
            season: season,
            status: "active",
            maxPlayers: 20,
            scoringFormat: "standard",
            scoringRules: scoringRules,
            settings: LeagueSettingsEntity(
                startDate: now,
                endDate: endDate,
                isPublic: true,
                allowTransfers: true,
                transferDeadline: nil
            ),
            totalPlayers: 0,
            image: nil,
            rules: nil
        )

        let leagueId = try await repository.createLeague(league: league)

        // El creador se une automáticamente a la liga
        let creatorMember = LeagueMemberEntity(
            id: "\(leagueId)_\(userId)",
            leagueId: leagueId,
            userId: userId,
            joinedAt: now,
            teamName: "Mi Equipo",
            totalPoints: 0,
            rank: 1,
            wins: 0,
            draws: 0,
            losses: 0,
            matchesPlayed: 0,
            transfersRemaining: 2,
            status: "active",
            squad: []
        )

        try await repository.addMemberToLeague(leagueId: leagueId, member: creatorMember)

        return leagueId
    }

    func getLeague(leagueId: String) async throws -> LeagueEntity {
        return try await repository.getLeague(leagueId: leagueId)
    }

    func deleteLeague(leagueId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        // Verificar que el usuario es el creador
        let league = try await repository.getLeague(leagueId: leagueId)
        guard league.createdBy == userId else {
            throw AppError.customError("Solo el creador puede eliminar la liga", nil)
        }

        try await repository.deleteLeague(leagueId: leagueId)
    }

    func getUserCreatedLeagues() async throws -> [LeagueEntity] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        return try await repository.getUserCreatedLeagues(userId: userId)
    }

    func getUserJoinedLeagues() async throws -> [LeagueEntity] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        return try await repository.getUserLeagues(userId: userId)
    }

    func getPublicLeagues(season: Int) async throws -> [LeagueEntity] {
        return try await repository.getPublicLeagues(season: season)
    }

    func searchLeagues(query: String) async throws -> [LeagueEntity] {
        guard !query.isEmpty else {
            return []
        }

        return try await repository.searchLeagues(query: query)
    }

    func joinLeague(leagueId: String, teamName: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        guard !teamName.isEmpty else {
            throw AppError.inputError("teamName", "El nombre del equipo es obligatorio")
        }

        guard teamName.count <= 30 else {
            throw AppError.inputError("teamName", "El nombre del equipo no puede exceder 30 caracteres")
        }

        // Verificar que el usuario no es ya miembro
        let isMember = try await repository.isMemberOfLeague(leagueId: leagueId, userId: userId)
        if isMember {
            throw AppError.customError("Ya eres miembro de esta liga", nil)
        }

        // Verificar que la liga existe y está activa
        let league = try await repository.getLeague(leagueId: leagueId)
        guard league.status == "active" else {
            throw AppError.customError("La liga no está activa", nil)
        }

        guard league.totalPlayers < league.maxPlayers else {
            throw AppError.customError("La liga está llena", nil)
        }

        let member = LeagueMemberEntity(
            id: "\(leagueId)_\(userId)",
            leagueId: leagueId,
            userId: userId,
            joinedAt: Date(),
            teamName: teamName,
            totalPoints: 0,
            rank: league.totalPlayers + 1,
            wins: 0,
            draws: 0,
            losses: 0,
            matchesPlayed: 0,
            transfersRemaining: 2,
            status: "active",
            squad: []
        )

        try await repository.addMemberToLeague(leagueId: leagueId, member: member)
    }

    func leaveLeague(leagueId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        // Verificar que el usuario es miembro
        let isMember = try await repository.isMemberOfLeague(leagueId: leagueId, userId: userId)
        guard isMember else {
            throw AppError.customError("No eres miembro de esta liga", nil)
        }

        // No permitir que el creador abandone la liga
        let league = try await repository.getLeague(leagueId: leagueId)
        guard league.createdBy != userId else {
            throw AppError.customError("El creador no puede abandonar la liga. Elimina la liga en su lugar.", nil)
        }

        try await repository.removeMemberFromLeague(leagueId: leagueId, userId: userId)
    }

    func getLeagueRanking(leagueId: String) async throws -> [LeagueMemberEntity] {
        return try await repository.getLeagueRanking(leagueId: leagueId)
    }

    func updateTeamName(leagueId: String, newName: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        guard !newName.isEmpty else {
            throw AppError.inputError("teamName", "El nombre del equipo no puede estar vacío")
        }

        guard newName.count <= 30 else {
            throw AppError.inputError("teamName", "El nombre no puede exceder 30 caracteres")
        }

        try await repository.updateMemberStats(leagueId: leagueId, userId: userId, stats: [
            "teamName": newName,
            "updatedAt": Date()
        ])
    }

    func isUserMemberOfLeague(leagueId: String) async throws -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials("Usuario no autenticado")
        }

        return try await repository.isMemberOfLeague(leagueId: leagueId, userId: userId)
    }
}
