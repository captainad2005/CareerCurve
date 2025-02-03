import Foundation

class MLBService {
    static let shared = MLBService()
    private let baseURL = "https://statsapi.mlb.com/api/v1"
    
    func fetchPlayer(id: Int) async throws -> Player {
        let url = "\(baseURL)/people/\(id)"
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        return try JSONDecoder().decode(Player.self, from: data)
    }
    
    func fetchTeam(id: Int) async throws -> Team {
        let url = "\(baseURL)/teams/\(id)"
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        return try JSONDecoder().decode(Team.self, from: data)
    }
    
    func fetchProspectPrediction(player: Player) async throws -> ProjectedStats {
        // In a real app, this would call an ML model API
        // For now, returning mock data
        return ProjectedStats(
            careerProbability: 0.85,
            peakWAR: 4.2,
            similarPlayers: ["Mike Trout", "Ronald Acuña Jr."],
            projectedDebut: "2025"
        )
    }
} 