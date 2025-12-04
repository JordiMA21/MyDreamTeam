import Foundation

// MARK: - League Repository Protocol

protocol LeagueRepositoryProtocol: AnyObject {
    func createLeague(league: LeagueEntity) async throws -> String
    func getLeague(leagueId: String) async throws -> LeagueEntity
    func updateLeague(leagueId: String, data: [String: Any]) async throws
    func deleteLeague(leagueId: String) async throws
    func getUserCreatedLeagues(userId: String) async throws -> [LeagueEntity]
    func getPublicLeagues(season: Int) async throws -> [LeagueEntity]
    func searchLeagues(query: String) async throws -> [LeagueEntity]
    func getUserLeagues(userId: String) async throws -> [LeagueEntity]
    func getLeagueRanking(leagueId: String) async throws -> [LeagueMemberEntity]
    func addMemberToLeague(leagueId: String, member: LeagueMemberEntity) async throws
    func removeMemberFromLeague(leagueId: String, userId: String) async throws
    func updateMemberStats(leagueId: String, userId: String, stats: [String: Any]) async throws
    func isMemberOfLeague(leagueId: String, userId: String) async throws -> Bool
}

// MARK: - League Repository Implementation

final class LeagueRepository: LeagueRepositoryProtocol {
    private let leagueDataSource: LeagueFirestoreDataSourceProtocol
    private let memberDataSource: LeagueMemberFirestoreDataSourceProtocol
    private let errorHandler: ErrorHandlerProtocol

    init(
        leagueDataSource: LeagueFirestoreDataSourceProtocol,
        memberDataSource: LeagueMemberFirestoreDataSourceProtocol,
        errorHandler: ErrorHandlerProtocol = ErrorHandlerManager()
    ) {
        self.leagueDataSource = leagueDataSource
        self.memberDataSource = memberDataSource
        self.errorHandler = errorHandler
    }

    // MARK: - LeagueRepositoryProtocol

    func createLeague(league: LeagueEntity) async throws -> String {
        do {
            let dto = league.toFirebaseDTO()
            return try await leagueDataSource.createLeague(league: dto)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getLeague(leagueId: String) async throws -> LeagueEntity {
        do {
            let dto = try await leagueDataSource.getLeague(leagueId: leagueId)
            return dto.toDomain()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func updateLeague(leagueId: String, data: [String: Any]) async throws {
        do {
            var mutableData = data
            mutableData["updatedAt"] = Date()
            try await leagueDataSource.updateLeague(leagueId: leagueId, data: mutableData)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func deleteLeague(leagueId: String) async throws {
        do {
            try await leagueDataSource.deleteLeague(leagueId: leagueId)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getUserCreatedLeagues(userId: String) async throws -> [LeagueEntity] {
        do {
            let dtos = try await leagueDataSource.getUserCreatedLeagues(userId: userId)
            return dtos.map { $0.toDomain() }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getPublicLeagues(season: Int) async throws -> [LeagueEntity] {
        do {
            let dtos = try await leagueDataSource.getPublicLeagues(season: season)
            return dtos.map { $0.toDomain() }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func searchLeagues(query: String) async throws -> [LeagueEntity] {
        do {
            let dtos = try await leagueDataSource.searchLeagues(query: query)
            return dtos.map { $0.toDomain() }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getUserLeagues(userId: String) async throws -> [LeagueEntity] {
        do {
            let leagueIds = try await memberDataSource.getUserLeagues(userId: userId)
            var leagues: [LeagueEntity] = []

            for leagueId in leagueIds {
                if let league = try? await getLeague(leagueId: leagueId) {
                    leagues.append(league)
                }
            }

            return leagues.sorted { $0.createdAt > $1.createdAt }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func getLeagueRanking(leagueId: String) async throws -> [LeagueMemberEntity] {
        do {
            let dtos = try await memberDataSource.getLeagueRanking(leagueId: leagueId)
            return dtos.map { $0.toDomain() }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func addMemberToLeague(leagueId: String, member: LeagueMemberEntity) async throws {
        do {
            let dto = member.toFirebaseDTO()
            try await memberDataSource.addMemberToLeague(leagueId: leagueId, member: dto)

            // Incrementar totalPlayers en la liga
            try await leagueDataSource.updateLeague(leagueId: leagueId, data: [
                "totalPlayers": FieldValue.increment(Int64(1))
            ])
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func removeMemberFromLeague(leagueId: String, userId: String) async throws {
        do {
            try await memberDataSource.removeMember(leagueId: leagueId, userId: userId)

            // Decrementar totalPlayers en la liga
            try await leagueDataSource.updateLeague(leagueId: leagueId, data: [
                "totalPlayers": FieldValue.increment(Int64(-1))
            ])
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func updateMemberStats(leagueId: String, userId: String, stats: [String: Any]) async throws {
        do {
            try await memberDataSource.updateMember(leagueId: leagueId, userId: userId, data: stats)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }

    func isMemberOfLeague(leagueId: String, userId: String) async throws -> Bool {
        do {
            return try await memberDataSource.isMemberOfLeague(leagueId: leagueId, userId: userId)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.generalError
        }
    }
}

// MARK: - FieldValue Helper

extension LeagueRepository {
    private enum FieldValue {
        static func increment(_ value: Int64) -> NSNumber {
            NSNumber(value: value)
        }
    }
}
