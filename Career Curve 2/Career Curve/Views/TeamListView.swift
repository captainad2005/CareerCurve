import SwiftUI

struct TeamListView: View {
    @EnvironmentObject private var viewModel: ProspectViewModel
    @State private var selectedDivision: String?
    @State private var selectedTeam: Team?
    @Namespace private var animation
    
    private let divisionColors: [String: Color] = [
        "AL East": .red.opacity(0.8),
        "AL Central": .blue.opacity(0.8),
        "AL West": .green.opacity(0.8),
        "NL East": .purple.opacity(0.8),
        "NL Central": .orange.opacity(0.8),
        "NL West": .indigo.opacity(0.8)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // League Overview
                VStack(alignment: .leading, spacing: 16) {
                    Text("MLB Teams")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Division Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(Array(MLBTeams.divisions.keys.sorted()), id: \.self) { division in
                            DivisionCard(
                                division: division,
                                color: divisionColors[division] ?? .blue,
                                teamCount: MLBTeams.divisions[division]?.count ?? 0,
                                prospectCount: viewModel.getProspectsByDivision(division).count,
                                isSelected: selectedDivision == division
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4)) {
                                    selectedDivision = selectedDivision == division ? nil : division
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Teams List
                VStack(spacing: 16) {
                    ForEach(Array(MLBTeams.divisions.keys.sorted()), id: \.self) { division in
                        if selectedDivision == nil || selectedDivision == division {
                            VStack(alignment: .leading, spacing: 12) {
                                DivisionHeader(
                                    title: division,
                                    color: divisionColors[division] ?? .blue
                                )
                                
                                let teamsInDivision = MLBTeams.divisions[division] ?? []
                                ForEach(teamsInDivision, id: \.self) { teamName in
                                    TeamCard(
                                        team: getTeam(named: teamName),
                                        prospectCount: viewModel.getProspectsByTeam(teamName).count,
                                        color: divisionColors[division]?.opacity(0.15) ?? .blue.opacity(0.15)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            selectedTeam = getTeam(named: teamName)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Teams")
        .overlay {
            if let team = selectedTeam {
                TeamDetailOverlay(
                    team: team,
                    prospects: viewModel.getProspectsByTeam(team.name),
                    isPresented: $selectedTeam
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private func getTeam(named teamName: String) -> Team {
        viewModel.teams.first { $0.teamName == teamName } ?? MLBTeams.allTeams[0]
    }
}

struct DivisionCard: View {
    let division: String
    let color: Color
    let teamCount: Int
    let prospectCount: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(division)
                .font(.headline)
                .foregroundStyle(.white)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(teamCount)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Teams")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(prospectCount)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Prospects")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct DivisionHeader: View {
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct TeamCard: View {
    let team: Team
    let prospectCount: Int
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(team.abbreviation)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                
                Text(team.division.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(prospectCount)")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.accent)
                
                Text(prospectCount == 1 ? "prospect" : "prospects")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

struct TeamDetailOverlay: View {
    let team: Team
    let prospects: [Player]
    @Binding var isPresented: Team?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPresented = nil
                    }
                }
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(team.name)
                            .font(.title2.weight(.bold))
                        
                        Text(team.division.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isPresented = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if prospects.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No prospects found")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(prospects) { prospect in
                                ProspectCard(prospect: prospect)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        TeamListView()
            .environmentObject(PreviewData.createMockTeamViewModel())
    }
}

extension PreviewData {
    @MainActor
    static func createMockTeamViewModel() -> ProspectViewModel {
        let prospects = [
            mockProspect(name: "Jackson Holliday", team: "Orioles", position: "SS", probability: 0.95),
            mockProspect(name: "Colson Montgomery", team: "White Sox", position: "SS", probability: 0.88),
            mockProspect(name: "Paul Skenes", team: "Pirates", position: "RHP", probability: 0.93),
            mockProspect(name: "Dylan Crews", team: "Nationals", position: "OF", probability: 0.91),
            mockProspect(name: "Evan Carter", team: "Rangers", position: "OF", probability: 0.89),
            mockProspect(name: "Kyle Harrison", team: "Giants", position: "LHP", probability: 0.87),
            mockProspect(name: "Jordan Walker", team: "Cardinals", position: "OF", probability: 0.92),
            mockProspect(name: "Masyn Winn", team: "Cardinals", position: "SS", probability: 0.86),
            mockProspect(name: "Pete Crow-Armstrong", team: "Cubs", position: "OF", probability: 0.88),
            mockProspect(name: "Jasson Dominguez", team: "Yankees", position: "OF", probability: 0.85)
        ]
        return ProspectViewModel(prospects: prospects)
    }
} 