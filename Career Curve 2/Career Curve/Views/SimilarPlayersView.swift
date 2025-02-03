import SwiftUI

struct SimilarPlayersView: View {
    let players: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Similar Players")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(players, id: \.self) { player in
                        VStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(player.prefix(2))
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                )
                            
                            Text(player)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 