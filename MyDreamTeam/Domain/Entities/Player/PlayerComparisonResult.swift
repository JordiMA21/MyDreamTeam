import Foundation

// MARK: - Player Comparison Result

struct PlayerComparisonResult {
    let player1: Player
    let player2: Player

    let goalsComparison: ComparisonDetail
    let assistsComparison: ComparisonDetail
    let ratingComparison: ComparisonDetail
    let priceComparison: ComparisonDetail
    let fantasyPointsComparison: ComparisonDetail

    var winner: Player? {
        // Calculate overall winner based on fantasy points
        if fantasyPointsComparison.player1Value > fantasyPointsComparison.player2Value {
            return player1
        } else if fantasyPointsComparison.player2Value > fantasyPointsComparison.player1Value {
            return player2
        }
        return nil // Draw
    }

    var summary: String {
        if let winner = winner {
            return "\(winner.name) es mejor en general"
        }
        return "\(player1.name) vs \(player2.name) - Empate"
    }
}

// MARK: - Comparison Detail

struct ComparisonDetail {
    let player1Value: Double
    let player2Value: Double

    var difference: Double {
        return abs(player1Value - player2Value)
    }

    var winner: Int? {
        // Returns 1 if player1 wins, 2 if player2 wins, nil if equal
        if player1Value > player2Value {
            return 1
        } else if player2Value > player1Value {
            return 2
        }
        return nil
    }

    var differencePercentage: Double {
        let maxValue = max(player1Value, player2Value)
        guard maxValue > 0 else { return 0 }
        return (difference / maxValue) * 100
    }
}
