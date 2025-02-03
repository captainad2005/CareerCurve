import SwiftUI

struct ProspectListRowView: View {
    let prospect: Player
    
    var body: some View {
        HStack(spacing: 16) {
            TeamLogoView(teamId: prospect.currentTeam.id)
                .frame(width: 50, height: 50)
                .background(Circle().fill(.ultraThinMaterial))
                .overlay(Circle().stroke(Theme.colorForProbability(prospect.projectedStats.careerProbability), lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prospect.fullName)
                    .font(.headline)
                    .foregroundStyle(Theme.primary)
                
                HStack {
                    Text(prospect.position.name)
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondary)
                    
                    Text("•")
                        .foregroundStyle(Theme.secondary)
                    
                    Text(prospect.currentTeam.name)
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                ProspectStatBadge(
                    value: String(format: "%.1f", prospect.projectedStats.peakWAR),
                    label: "WAR",
                    color: Theme.colorForWAR(prospect.projectedStats.peakWAR)
                )
                
                ProspectStatBadge(
                    value: String(format: "%.0f%%", prospect.projectedStats.careerProbability * 100),
                    label: "MLB",
                    color: Theme.colorForProbability(prospect.projectedStats.careerProbability)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ProspectStatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .bold))
            Text(label)
                .font(.system(.caption2, design: .rounded))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .foregroundStyle(color)
    }
}

// Preview helper
extension ProspectListRowView {
    static let previewProspect = Player(
        id: 808963,
        fullName: "Preview Player",
        currentTeam: Team(
            id: 119,
            name: "Los Angeles Dodgers",
            abbreviation: "LAD",
            teamName: "Dodgers",
            locationName: "Los Angeles",
            division: .init(id: 203, name: "NL West")
        ),
        position: .init(code: "RHP", name: "Right-Handed Pitcher", type: "Pitcher"),
        stats: PlayerStats(
            batting: nil,
            pitching: PitchingStats(
                era: 1.78,
                wins: 12,
                losses: 3,
                saves: 0,
                strikeouts: 149,
                innings: 102.1,
                whip: 0.89,
                games: 18,
                gamesStarted: 18
            )
        ),
        projectedStats: ProjectedStats(
            careerProbability: 0.95,
            peakWAR: 6.8,
            similarPlayers: ["Yu Darvish", "Shohei Ohtani"],
            projectedDebut: "2025"
        )
    )
}

#Preview {
    ProspectListRowView(prospect: ProspectListRowView.previewProspect)
} 