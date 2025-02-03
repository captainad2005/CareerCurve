import Foundation

struct MLBTeams {
    static let dodgers = Team(id: 119, name: "Los Angeles Dodgers", abbreviation: "LAD", teamName: "Dodgers", locationName: "Los Angeles", division: .init(id: 203, name: "NL West"))
    static let redSox = Team(id: 111, name: "Boston Red Sox", abbreviation: "BOS", teamName: "Red Sox", locationName: "Boston", division: .init(id: 201, name: "AL East"))
    static let twins = Team(id: 142, name: "Minnesota Twins", abbreviation: "MIN", teamName: "Twins", locationName: "Minnesota", division: .init(id: 202, name: "AL Central"))
    static let nationals = Team(id: 120, name: "Washington Nationals", abbreviation: "WSH", teamName: "Nationals", locationName: "Washington", division: .init(id: 204, name: "NL East"))
    static let tigers = Team(id: 116, name: "Detroit Tigers", abbreviation: "DET", teamName: "Tigers", locationName: "Detroit", division: .init(id: 202, name: "AL Central"))
    
    static let allTeams: [Team] = [
        dodgers, redSox, twins, nationals, tigers
    ]
    
    static let divisions = [
        "AL East": ["Yankees", "Red Sox", "Blue Jays", "Rays", "Orioles"],
        "AL Central": ["Twins", "Guardians", "Tigers", "White Sox", "Royals"],
        "AL West": ["Rangers", "Astros", "Mariners", "Angels", "Athletics"],
        "NL East": ["Braves", "Phillies", "Mets", "Marlins", "Nationals"],
        "NL Central": ["Brewers", "Cubs", "Reds", "Pirates", "Cardinals"],
        "NL West": ["Dodgers", "D-backs", "Giants", "Padres", "Rockies"]
    ]
} 