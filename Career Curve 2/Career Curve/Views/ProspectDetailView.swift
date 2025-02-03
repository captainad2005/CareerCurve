import SwiftUI
import Charts

struct ProspectDetailView: View {
    let prospect: Player
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProspectHeaderView(prospect: prospect)
                
                ProjectionGraphs(stats: prospect.projectedStats)
                
                SimilarPlayersView(players: prospect.projectedStats.similarPlayers)
                
                CareerTimelineView(prospect: prospect)
            }
            .padding()
        }
        .navigationTitle(prospect.fullName)
    }
}

struct ProjectionGraphs: View {
    let stats: ProjectedStats
    
    var body: some View {
        Chart {
            BarMark(
                x: .value("Year", "2024"),
                y: .value("WAR", stats.peakWAR)
            )
            // Add more chart elements
        }
        .frame(height: 200)
    }
} 