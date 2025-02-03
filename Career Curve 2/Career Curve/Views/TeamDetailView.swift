import SwiftUI
import Charts

struct TeamDetailView: View {
    let team: Team
    @EnvironmentObject private var viewModel: ProspectViewModel
    
    var body: some View {
        List {
            Section("Team Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(team.name)
                        .font(.headline)
                    Text("Division: \(team.division.name)")
                        .foregroundColor(.secondary)
                    Text("Location: \(team.locationName)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Top Prospects") {
                let teamProspects = viewModel.getProspectsByTeam(team.name)
                if teamProspects.isEmpty {
                    Text("No prospects found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(teamProspects) { prospect in
                        NavigationLink(destination: ProspectDetailView(prospect: prospect)) {
                            ProspectListRowView(prospect: prospect)
                        }
                    }
                }
            }
            
            Section("Prospect Analytics") {
                Chart {
                    ForEach(viewModel.getProspectsByTeam(team.name)) { prospect in
                        BarMark(
                            x: .value("Name", prospect.fullName),
                            y: .value("WAR", prospect.projectedStats.peakWAR)
                        )
                    }
                }
                .frame(height: 200)
            }
        }
        .navigationTitle(team.teamName)
    }
} 