import Foundation

class PlayerUseCase: PlayerUseCaseProtocol {
    private let repository: PlayerRepositoryProtocol

    init(repository: PlayerRepositoryProtocol) {
        self.repository = repository
    }

    func getPlayer(id: Int) async throws -> Player {
        try await repository.getPlayer(id: id)
    }

    func searchPlayers(by name: String) async throws -> [Player] {
        try await repository.searchPlayers(by: name)
    }

    func getPlayersByTeam(teamId: Int) async throws -> [Player] {
        try await repository.getPlayersByTeam(teamId: teamId)
    }

    func getPlayersByPosition(position: String) async throws -> [Player] {
        try await repository.getPlayersByPosition(position: position)
    }

    // MARK: - New Methods for PlayerSelection

    func getAvailablePlayers(for position: String, season: Int) async throws -> [Player] {
        // Get players by position
        let players = try await repository.getPlayersByPosition(position: position)

        // Filter available players (for now, return all)
        // In the future, you can filter by season, availability, etc.
        return players
    }

    func comparePlayerStats(_ player1: Player, _ player2: Player) -> PlayerComparisonResult {
        let goalsComparison = ComparisonDetail(
            player1Value: Double(player1.goals),
            player2Value: Double(player2.goals)
        )

        let assistsComparison = ComparisonDetail(
            player1Value: Double(player1.assists),
            player2Value: Double(player2.assists)
        )

        let ratingComparison = ComparisonDetail(
            player1Value: player1.averageRating,
            player2Value: player2.averageRating
        )

        let priceComparison = ComparisonDetail(
            player1Value: player1.marketValue,
            player2Value: player2.marketValue
        )

        let fantasyPointsComparison = ComparisonDetail(
            player1Value: player1.fantasyPoints,
            player2Value: player2.fantasyPoints
        )

        return PlayerComparisonResult(
            player1: player1,
            player2: player2,
            goalsComparison: goalsComparison,
            assistsComparison: assistsComparison,
            ratingComparison: ratingComparison,
            priceComparison: priceComparison,
            fantasyPointsComparison: fantasyPointsComparison
        )
    }
}
