import SwiftUI

// Move SortOption enum outside
enum SortOption: CaseIterable {
    case probability, name, team
    
    var title: String {
        switch self {
        case .probability: return "MLB Probability"
        case .name: return "Name"
        case .team: return "Team"
        }
    }
}

struct ProspectListView: View {
    @EnvironmentObject private var viewModel: ProspectViewModel
    @State private var searchText = ""
    @State private var sortOption: SortOption = .probability
    @State private var isLoading = true
    @State private var selectedProspect: Player?
    @Namespace private var animation
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Top Prospects Carousel
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top Prospects")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .opacity(0.9)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(Array(sortedProspects.prefix(5))) { prospect in
                                        TopProspectCard(prospect: prospect, namespace: animation)
                                            .matchedGeometryEffect(id: prospect.id, in: animation)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    selectedProspect = prospect
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        
                        // Sort and Filter Section
                        VStack(spacing: 12) {
                            Text("Sort prospects by:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    SortButton(
                                        title: option.title,
                                        isSelected: sortOption == option,
                                        action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                sortOption = option
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Prospects List
                        LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                            let prospectsByPosition = Dictionary(grouping: sortedProspects) { $0.position.type }
                            
                            ForEach(Array(prospectsByPosition.keys.sorted()), id: \.self) { positionType in
                                Section {
                                    VStack(spacing: 12) {
                                        ForEach(prospectsByPosition[positionType] ?? []) { prospect in
                                            ProspectCard(prospect: prospect)
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                    }
                                    .padding(.horizontal)
                                } header: {
                                    PositionHeader(title: positionType, count: prospectsByPosition[positionType]?.count ?? 0)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    await refreshProspects()
                }
                .searchable(text: $searchText, prompt: "Search prospects...")
                .overlay {
                    if selectedProspect != nil {
                        ProspectDetailOverlay(
                            prospect: selectedProspect!,
                            namespace: animation,
                            isPresented: $selectedProspect
                        )
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
        }
        .navigationTitle("Career Curve")
        .task {
            await loadProspects()
        }
    }
    
    private func loadProspects() async {
        withAnimation {
            isLoading = true
        }
        await viewModel.loadProspects()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isLoading = false
        }
    }
    
    private func refreshProspects() async {
        await viewModel.updateProjections()
    }
    
    private var sortedProspects: [Player] {
        let filtered = searchText.isEmpty ? viewModel.prospects :
            viewModel.prospects.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
        
        switch sortOption {
        case .probability:
            return filtered.sorted { $0.projectedStats.careerProbability > $1.projectedStats.careerProbability }
        case .name:
            return filtered.sorted { $0.fullName < $1.fullName }
        case .team:
            return filtered.sorted { $0.currentTeam.name < $1.currentTeam.name }
        }
    }
}

// MARK: - Supporting Views

struct TopProspectCard: View {
    let prospect: Player
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.colorForProbability(prospect.projectedStats.careerProbability),
                            Theme.colorForProbability(prospect.projectedStats.careerProbability).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay {
                    Text(prospect.fullName.prefix(2))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .shadow(color: Theme.colorForProbability(prospect.projectedStats.careerProbability).opacity(0.3),
                       radius: 8, x: 0, y: 4)
            
            VStack(spacing: 4) {
                Text(prospect.fullName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(prospect.position.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(Int(prospect.projectedStats.careerProbability * 100))%")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
        }
        .padding()
        .frame(width: 160)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        }
    }
}

struct ProspectCard: View {
    let prospect: Player
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Player Info
            VStack(alignment: .leading, spacing: 6) {
                Text(prospect.fullName)
                    .font(.headline)
                
                HStack {
                    Text(prospect.position.name)
                    Text("•")
                    Text(prospect.currentTeam.name)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                // Stats
                if let batting = prospect.stats.batting {
                    StatsRow(stats: [
                        ("AVG", String(format: "%.3f", batting.avg)),
                        ("HR", "\(batting.hr)"),
                        ("OPS", String(format: "%.3f", batting.ops))
                    ])
                } else if let pitching = prospect.stats.pitching {
                    StatsRow(stats: [
                        ("ERA", String(format: "%.2f", pitching.era)),
                        ("SO", "\(pitching.strikeouts)"),
                        ("WHIP", String(format: "%.2f", pitching.whip))
                    ])
                }
            }
            
            Spacer()
            
            // Projections
            VStack(alignment: .trailing, spacing: 6) {
                ProbabilityRing(value: prospect.projectedStats.careerProbability)
                    .frame(width: 50, height: 50)
                
                Text("MLB: " + prospect.projectedStats.projectedDebut)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("WAR: " + String(format: "%.1f", prospect.projectedStats.peakWAR))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        }
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

struct StatsRow: View {
    let stats: [(String, String)]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(stats, id: \.0) { stat in
                VStack(spacing: 2) {
                    Text(stat.1)
                        .font(.system(.caption, design: .rounded).weight(.bold))
                    Text(stat.0)
                        .font(.system(.caption2))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ProbabilityRing: View {
    let value: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    Theme.colorForProbability(value),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(value * 100))")
                .font(.system(.caption, design: .rounded).weight(.bold))
        }
    }
}

struct PositionHeader: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title + "s")
                .font(.title3.weight(.bold))
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding()
        .background(.background)
    }
}

struct SortButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentColor.opacity(0.1))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.3)],
                                 startPoint: .top,
                                 endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        isAnimating = true
                    }
                }
            
            Text("Loading prospects...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProspectDetailOverlay: View {
    let prospect: Player
    let namespace: Namespace.ID
    @Binding var isPresented: Player?
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPresented = nil
                    }
                }
            
            // Prospect detail card
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(prospect.fullName)
                            .font(.title2.weight(.bold))
                        
                        HStack {
                            Text(prospect.position.name)
                            Text("•")
                            Text(prospect.currentTeam.name)
                        }
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
                
                // Stats
                VStack(spacing: 16) {
                    // Probability and WAR
                    HStack(spacing: 20) {
                        StatBox(
                            title: "MLB Probability",
                            value: String(format: "%.0f%%", prospect.projectedStats.careerProbability * 100),
                            color: Theme.colorForProbability(prospect.projectedStats.careerProbability)
                        )
                        
                        StatBox(
                            title: "Peak WAR",
                            value: String(format: "%.1f", prospect.projectedStats.peakWAR),
                            color: Theme.colorForWAR(prospect.projectedStats.peakWAR)
                        )
                    }
                    
                    // Performance stats
                    if let batting = prospect.stats.batting {
                        VStack(spacing: 12) {
                            Text("Batting Statistics")
                                .font(.headline)
                            
                            HStack(spacing: 20) {
                                StatBox(title: "AVG", value: String(format: "%.3f", batting.avg))
                                StatBox(title: "HR", value: "\(batting.hr)")
                                StatBox(title: "OPS", value: String(format: "%.3f", batting.ops))
                            }
                        }
                    } else if let pitching = prospect.stats.pitching {
                        VStack(spacing: 12) {
                            Text("Pitching Statistics")
                                .font(.headline)
                            
                            HStack(spacing: 20) {
                                StatBox(title: "ERA", value: String(format: "%.2f", pitching.era))
                                StatBox(title: "SO", value: "\(pitching.strikeouts)")
                                StatBox(title: "WHIP", value: String(format: "%.2f", pitching.whip))
                            }
                        }
                    }
                    
                    // Similar players
                    VStack(spacing: 8) {
                        Text("Similar Players")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(prospect.projectedStats.similarPlayers, id: \.self) { player in
                                Text(player)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.secondary.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding()
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var color: Color = .accentColor
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct PreviewData {
    @MainActor
    static func createMockViewModel() -> ProspectViewModel {
        let prospects = [
            mockProspect(name: "Jackson Holliday", team: "Orioles", position: "SS", probability: 0.95),
            mockProspect(name: "Junior Caminero", team: "Rays", position: "3B", probability: 0.92),
            mockProspect(name: "Jackson Merrill", team: "Padres", position: "SS", probability: 0.88),
            mockProspect(name: "Jordan Lawlar", team: "Diamondbacks", position: "SS", probability: 0.87),
            mockProspect(name: "Wyatt Langford", team: "Rangers", position: "OF", probability: 0.90)
        ]
        return ProspectViewModel(prospects: prospects)
    }
    
    static func mockProspect(name: String, team: String, position: String, probability: Double) -> Player {
        Player(
            id: Int.random(in: 100000...999999),
            fullName: name,
            currentTeam: Team(
                id: Int.random(in: 100...200),
                name: team,
                abbreviation: team.prefix(3).uppercased(),
                teamName: team,
                locationName: team,
                division: .init(id: 1, name: "AL East")
            ),
            position: .init(code: position, name: position, type: "Position Player"),
            stats: PlayerStats(
                batting: BattingStats(
                    avg: 0.320,
                    hr: 20,
                    rbi: 80,
                    obp: 0.400,
                    slg: 0.550,
                    ops: 0.950,
                    games: 100,
                    atBats: 400,
                    hits: 128
                ),
                pitching: nil
            ),
            projectedStats: ProjectedStats(
                careerProbability: probability,
                peakWAR: 5.5,
                similarPlayers: ["Mike Trout", "Ronald Acuña Jr."],
                projectedDebut: "2024"
            )
        )
    }
}

#Preview {
    NavigationStack {
        ProspectListView()
            .environmentObject(PreviewData.createMockViewModel())
    }
} 