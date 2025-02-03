import SwiftUI

struct ProspectHeaderView: View {
    let prospect: Player
    
    var body: some View {
        VStack(spacing: 12) {
            TeamLogoView(teamId: prospect.currentTeam.id)
                .frame(width: 80, height: 80)
            
            Text(prospect.fullName)
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(prospect.position.name) | \(prospect.currentTeam.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProbabilityIndicator(probability: prospect.projectedStats.careerProbability)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProbabilityIndicator: View {
    let probability: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text("MLB Career Probability")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(probability * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(probabilityColor)
        }
    }
    
    private var probabilityColor: Color {
        switch probability {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        default: return .red
        }
    }
} 