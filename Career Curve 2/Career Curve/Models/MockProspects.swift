import Foundation

struct MockProspects {
    static let topProspects: [Player] = [
        // AL East
        createProspect("Jackson Holliday", "Orioles", "SS", 0.95, 6.5, "2024"),
        createProspect("Junior Caminero", "Rays", "3B", 0.92, 5.8, "2024"),
        createProspect("Marcelo Mayer", "Red Sox", "SS", 0.88, 5.2, "2024"),
        createProspect("Spencer Jones", "Yankees", "OF", 0.85, 4.8, "2025"),
        createProspect("Ricky Tiedemann", "Blue Jays", "LHP", 0.87, 4.9, "2024"),
        
        // AL Central
        createProspect("Jackson Merrill", "White Sox", "SS", 0.89, 5.1, "2024"),
        createProspect("Chase DeLauter", "Guardians", "OF", 0.86, 4.7, "2025"),
        createProspect("Max Clark", "Tigers", "OF", 0.88, 5.0, "2026"),
        createProspect("Brooks Lee", "Twins", "SS", 0.87, 4.8, "2024"),
        createProspect("Nick Loftin", "Royals", "UTL", 0.83, 4.2, "2024"),
        
        // AL West
        createProspect("Wyatt Langford", "Rangers", "OF", 0.93, 6.0, "2024"),
        createProspect("Jacob Wilson", "Athletics", "SS", 0.85, 4.6, "2024"),
        createProspect("Drew Gilbert", "Astros", "OF", 0.84, 4.5, "2024"),
        createProspect("Harry Ford", "Mariners", "C", 0.86, 4.8, "2025"),
        createProspect("Zach Neto", "Angels", "SS", 0.88, 4.9, "2024"),
        
        // NL East
        createProspect("Dylan Crews", "Nationals", "OF", 0.94, 6.2, "2024"),
        createProspect("Jett Williams", "Mets", "SS", 0.87, 4.8, "2025"),
        createProspect("Thomas Saggese", "Braves", "INF", 0.82, 4.1, "2024"),
        createProspect("Ethan Salas", "Marlins", "C", 0.89, 5.2, "2026"),
        createProspect("Andrew Painter", "Phillies", "RHP", 0.90, 5.5, "2024"),
        
        // NL Central
        createProspect("Paul Skenes", "Pirates", "RHP", 0.94, 6.1, "2024"),
        createProspect("Pete Crow-Armstrong", "Cubs", "OF", 0.91, 5.4, "2024"),
        createProspect("Jordan Walker", "Cardinals", "OF", 0.92, 5.7, "2024"),
        createProspect("Jacob Misiorowski", "Brewers", "RHP", 0.85, 4.7, "2025"),
        createProspect("Rhett Lowder", "Reds", "RHP", 0.86, 4.8, "2025"),
        
        // NL West
        createProspect("Jordan Lawlar", "Diamondbacks", "SS", 0.91, 5.6, "2024"),
        createProspect("Kyle Harrison", "Giants", "LHP", 0.88, 5.0, "2024"),
        createProspect("Jackson Merrill", "Padres", "SS", 0.89, 5.2, "2024"),
        createProspect("Gavin Williams", "Dodgers", "RHP", 0.87, 4.9, "2024"),
        createProspect("Adael Amador", "Rockies", "SS", 0.85, 4.6, "2024")
    ]
    
    private static func createProspect(_ name: String, _ team: String, _ position: String, _ probability: Double, _ war: Double, _ debut: String) -> Player {
        let positionType = position.contains("P") ? "Pitcher" : "Position Player"
        return Player(
            id: Int.random(in: 100000...999999),
            fullName: name,
            currentTeam: Team(
                id: Int.random(in: 100...200),
                name: team,
                abbreviation: String(team.prefix(3).uppercased()),
                teamName: team,
                locationName: team,
                division: getDivisionForTeam(team)
            ),
            position: Position(code: position, name: getPositionName(position), type: positionType),
            stats: generateStats(position),
            projectedStats: ProjectedStats(
                careerProbability: probability,
                peakWAR: war,
                similarPlayers: generateSimilarPlayers(position),
                projectedDebut: debut
            )
        )
    }
    
    private static func getDivisionForTeam(_ team: String) -> Division {
        let divisions: [String: Division] = [
            "Orioles": Division(id: 201, name: "AL East"),
            "Red Sox": Division(id: 201, name: "AL East"),
            "Yankees": Division(id: 201, name: "AL East"),
            "Rays": Division(id: 201, name: "AL East"),
            "Blue Jays": Division(id: 201, name: "AL East"),
            
            "White Sox": Division(id: 202, name: "AL Central"),
            "Guardians": Division(id: 202, name: "AL Central"),
            "Tigers": Division(id: 202, name: "AL Central"),
            "Royals": Division(id: 202, name: "AL Central"),
            "Twins": Division(id: 202, name: "AL Central"),
            
            "Astros": Division(id: 203, name: "AL West"),
            "Angels": Division(id: 203, name: "AL West"),
            "Athletics": Division(id: 203, name: "AL West"),
            "Mariners": Division(id: 203, name: "AL West"),
            "Rangers": Division(id: 203, name: "AL West"),
            
            "Braves": Division(id: 204, name: "NL East"),
            "Marlins": Division(id: 204, name: "NL East"),
            "Mets": Division(id: 204, name: "NL East"),
            "Phillies": Division(id: 204, name: "NL East"),
            "Nationals": Division(id: 204, name: "NL East"),
            
            "Cubs": Division(id: 205, name: "NL Central"),
            "Reds": Division(id: 205, name: "NL Central"),
            "Brewers": Division(id: 205, name: "NL Central"),
            "Pirates": Division(id: 205, name: "NL Central"),
            "Cardinals": Division(id: 205, name: "NL Central"),
            
            "Diamondbacks": Division(id: 206, name: "NL West"),
            "Rockies": Division(id: 206, name: "NL West"),
            "Dodgers": Division(id: 206, name: "NL West"),
            "Padres": Division(id: 206, name: "NL West"),
            "Giants": Division(id: 206, name: "NL West")
        ]
        
        return divisions[team] ?? Division(id: 200, name: "Unknown")
    }
    
    private static func getPositionName(_ code: String) -> String {
        let positions: [String: String] = [
            "C": "Catcher",
            "1B": "First Baseman",
            "2B": "Second Baseman",
            "3B": "Third Baseman",
            "SS": "Shortstop",
            "OF": "Outfielder",
            "LHP": "Left-Handed Pitcher",
            "RHP": "Right-Handed Pitcher",
            "UTL": "Utility Player"
        ]
        return positions[code] ?? code
    }
    
    private static func generateStats(_ position: String) -> PlayerStats {
        if position.contains("P") {
            return PlayerStats(
                batting: nil,
                pitching: PitchingStats(
                    era: Double.random(in: 2.0...4.0),
                    wins: Int.random(in: 5...15),
                    losses: Int.random(in: 2...10),
                    saves: 0,
                    strikeouts: Int.random(in: 80...200),
                    innings: Double.random(in: 80...180),
                    whip: Double.random(in: 0.9...1.3),
                    games: Int.random(in: 20...30),
                    gamesStarted: Int.random(in: 15...25)
                )
            )
        } else {
            return PlayerStats(
                batting: BattingStats(
                    avg: Double.random(in: 0.250...0.320),
                    hr: Int.random(in: 10...30),
                    rbi: Int.random(in: 40...100),
                    obp: Double.random(in: 0.320...0.400),
                    slg: Double.random(in: 0.400...0.550),
                    ops: Double.random(in: 0.720...0.950),
                    games: Int.random(in: 100...140),
                    atBats: Int.random(in: 300...500),
                    hits: Int.random(in: 80...160)
                ),
                pitching: nil
            )
        }
    }
    
    private static func generateSimilarPlayers(_ position: String) -> [String] {
        let pitchers = ["Max Scherzer", "Justin Verlander", "Clayton Kershaw", "Gerrit Cole", "Jacob deGrom"]
        let hitters = ["Mike Trout", "Ronald Acuña Jr.", "Juan Soto", "Fernando Tatis Jr.", "Mookie Betts"]
        
        let pool = position.contains("P") ? pitchers : hitters
        return Array(pool.shuffled().prefix(2))
    }
} 