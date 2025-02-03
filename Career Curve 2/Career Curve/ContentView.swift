//  Created by Aradhya Dubey and Ritesh Yadav on 02/01/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject private var viewModel: ProspectViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                ProspectListView()
            }
            .tabItem {
                Label("Prospects", systemImage: "person.3")
            }
            
            NavigationStack {
                TeamListView()
            }
            .tabItem {
                Label("Teams", systemImage: "baseball.diamond.bases")
            }
            
            NavigationStack {
                AnalyticsView()
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .task {
            await viewModel.loadProspects()
        }
    }
}

struct ProspectRowView: View {
    let prospect: Player
    
    var body: some View {
        HStack {
            TeamLogoView(teamId: prospect.currentTeam.id)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(prospect.fullName)
                    .font(.headline)
                Text(prospect.position.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CareerProbabilityGraph(probability: prospect.projectedStats.careerProbability)
        }
    }
}

#Preview {
    ContentView()
}
