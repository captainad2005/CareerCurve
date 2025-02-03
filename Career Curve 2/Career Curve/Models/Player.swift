import Foundation

class Player: Identifiable, Codable {
    let id: Int
    let fullName: String
    let currentTeam: Team
    let position: Position
    let stats: PlayerStats
    var projectedStats: ProjectedStats
    
    init(id: Int, fullName: String, currentTeam: Team, position: Position, stats: PlayerStats, projectedStats: ProjectedStats) {
        self.id = id
        self.fullName = fullName
        self.currentTeam = currentTeam
        self.position = position
        self.stats = stats
        self.projectedStats = projectedStats
    }
}

struct Position: Codable, Hashable {
    let code: String
    let name: String
    let type: String
}

struct PlayerStats: Codable {
    let batting: BattingStats?
    let pitching: PitchingStats?
}

struct BattingStats: Codable {
    let avg: Double
    let hr: Int
    let rbi: Int
    let obp: Double
    let slg: Double
    let ops: Double
    let games: Int
    let atBats: Int
    let hits: Int
}

struct PitchingStats: Codable {
    let era: Double
    let wins: Int
    let losses: Int
    let saves: Int
    let strikeouts: Int
    let innings: Double
    let whip: Double
    let games: Int
    let gamesStarted: Int
}

struct ProjectedStats: Codable {
    var careerProbability: Double
    var peakWAR: Double
    var similarPlayers: [String]
    var projectedDebut: String
    
    init(careerProbability: Double, peakWAR: Double, similarPlayers: [String], projectedDebut: String) {
        self.careerProbability = careerProbability
        self.peakWAR = peakWAR
        self.similarPlayers = similarPlayers
        self.projectedDebut = projectedDebut
    }
} 