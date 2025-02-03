import SwiftUI

struct TeamLogoView: View {
    let teamId: Int
    
    var body: some View {
        // In a real app, you would load the actual team logo
        // For now, showing a placeholder
        Circle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Text("\(teamId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            )
    }
} 