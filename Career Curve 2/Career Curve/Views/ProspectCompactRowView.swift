import SwiftUI

struct ProspectCompactRowView: View {
    let prospect: Player
    
    var body: some View {
        HStack(spacing: 12) {
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
                Text(String(format: "%.0f%%", prospect.projectedStats.careerProbability * 100))
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.colorForProbability(prospect.projectedStats.careerProbability))
                
                Text("MLB Ready: " + prospect.projectedStats.projectedDebut)
                    .font(.caption)
                    .foregroundStyle(Theme.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        ProspectCompactRowView(prospect: PreviewData.mockProspect(
            name: "Jackson Holliday",
            team: "Orioles",
            position: "SS",
            probability: 0.95
        ))
        ProspectCompactRowView(prospect: PreviewData.mockProspect(
            name: "Junior Caminero",
            team: "Rays",
            position: "3B",
            probability: 0.92
        ))
        ProspectCompactRowView(prospect: PreviewData.mockProspect(
            name: "Paul Skenes",
            team: "Pirates",
            position: "RHP",
            probability: 0.93
        ))
    }
    .listStyle(.insetGrouped)
} 