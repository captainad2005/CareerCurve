import SwiftUI

struct CareerTimelineView: View {
    let prospect: Player
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Career Timeline")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 20) {
                TimelineItem(
                    title: "Present",
                    description: "Current Level",
                    date: "2024"
                )
                
                TimelineItem(
                    title: "Projected MLB Debut",
                    description: "Expected Call-up",
                    date: prospect.projectedStats.projectedDebut
                )
                
                TimelineItem(
                    title: "Peak Performance",
                    description: "Projected WAR: \(String(format: "%.1f", prospect.projectedStats.peakWAR))",
                    date: String(Int(prospect.projectedStats.projectedDebut)! + 3)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TimelineItem: View {
    let title: String
    let description: String
    let date: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
} 