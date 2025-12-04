import Foundation

protocol LineupRepositoryProtocol {
    func getLineup(teamId: Int) async throws -> Lineup
    func saveLineup(_ lineup: Lineup) async throws
    func updateLineup(_ lineup: Lineup) async throws
    func deleteLineup(teamId: Int) async throws
}
