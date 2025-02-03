import SwiftUI

struct TeamCompactRowView: View {
    let teamName: String
    let prospectCount: Int
    let division: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(teamName)
                    .font(.headline)
                    .foregroundStyle(Theme.primary)
                
                HStack {
                    Image(systemName: "baseball.diamond.bases")
                        .foregroundStyle(Theme.secondary)
                    Text(division)
                        .font(.caption)
                        .foregroundStyle(Theme.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(prospectCount)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.accent)
                
                Text(prospectCount == 1 ? "prospect" : "prospects")
                    .font(.caption)
                    .foregroundStyle(Theme.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        TeamCompactRowView(
            teamName: "Baltimore Orioles",
            prospectCount: 5,
            division: "AL East"
        )
        TeamCompactRowView(
            teamName: "New York Yankees",
            prospectCount: 3,
            division: "AL East"
        )
        TeamCompactRowView(
            teamName: "Los Angeles Dodgers",
            prospectCount: 4,
            division: "NL West"
        )
    }
    .listStyle(.insetGrouped)
} 