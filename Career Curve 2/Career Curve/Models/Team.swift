import Foundation

struct Team: Codable, Hashable {
    let id: Int
    let name: String
    let abbreviation: String
    let teamName: String
    let locationName: String
    let division: Division
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
} 