import Foundation

@MainActor
class ProspectViewModel: ObservableObject {
    @Published var prospects: [Player]
    @Published private(set) var teams: [Team] = []
    @Published private(set) var isLoading = false
    private let mlbService = MLBService.shared
    
    init(prospects: [Player] = []) {
        self.prospects = prospects
        self.teams = MLBTeams.allTeams
    }
    
    func loadProspects() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load mock data
        prospects = MockProspects.topProspects
    }
    
    func updateProjections() async {
        guard !prospects.isEmpty else { return }
        
        for (index, prospect) in prospects.enumerated() {
            do {
                let newProjection = try await mlbService.fetchProspectPrediction(player: prospect)
                var updatedProspect = prospect
                updatedProspect.projectedStats = newProjection
                prospects[index] = updatedProspect
            } catch {
                print("Error updating projections: \(error)")
            }
        }
    }
    
    func getProspectsByTeam(_ teamName: String) -> [Player] {
        prospects.filter { $0.currentTeam.name == teamName }
    }
    
    func getProspectsByDivision(_ division: String) -> [Player] {
        let teamsInDivision = MLBTeams.divisions[division] ?? []
        return prospects.filter { prospect in
            teamsInDivision.contains(prospect.currentTeam.teamName)
        }
    }
    
    func setProspects(_ newProspects: [Player]) {
        prospects = newProspects
    }
} 