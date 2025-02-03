import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject private var viewModel: ProspectViewModel
    @State private var selectedTimeframe = TimeFrame.oneYear
    @State private var selectedChart = ChartType.probability
    
    enum TimeFrame: String, CaseIterable {
        case sixMonths = "6 Months"
        case oneYear = "1 Year"
        case twoYears = "2 Years"
        
        var monthCount: Int {
            switch self {
            case .sixMonths: return 6
            case .oneYear: return 12
            case .twoYears: return 24
            }
        }
        
        var dateRange: Range<Date> {
            let end = Date()
            let start = Calendar.current.date(byAdding: .month, value: -monthCount, to: end)!
            return start..<end
        }
    }
    
    enum ChartType: String, CaseIterable {
        case probability = "Success Probability"
        case war = "Projected WAR"
        case position = "Position Distribution"
        case timeline = "MLB Timeline"
    }
    
    var filteredProspects: [Player] {
        let dateRange = selectedTimeframe.dateRange
        return viewModel.prospects.filter { prospect in
            if let debutYear = Int(prospect.projectedStats.projectedDebut),
               let debutDate = Calendar.current.date(from: DateComponents(year: debutYear)) {
                return dateRange.contains(debutDate)
            }
            return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Chart Type Selector
                Picker("Chart Type", selection: $selectedChart) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Timeframe Selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Selected Chart View with filtered data
                switch selectedChart {
                case .probability:
                    ProbabilityDistributionChart(prospects: filteredProspects)
                        .transition(.scale)
                case .war:
                    TopProspectsWARChart(prospects: filteredProspects)
                        .transition(.scale)
                case .position:
                    PositionDistributionChart(prospects: filteredProspects)
                        .transition(.scale)
                case .timeline:
                    ProspectTimelineChart(prospects: filteredProspects)
                        .transition(.scale)
                }
                
                // Key Stats Section with filtered data
                KeyStatsView(prospects: filteredProspects)
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .animation(.easeInOut, value: selectedChart)
        .animation(.easeInOut, value: selectedTimeframe)
    }
}

struct ProbabilityDistributionChart: View {
    let prospects: [Player]
    @State private var selectedProbability: Double?
    
    private let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Success Probability Distribution")
                .font(.headline)
            
            probabilityChart
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var probabilityChart: some View {
        Chart {
            ForEach(prospects) { prospect in
                probabilityBar(for: prospect)
            }
        }
        .frame(height: 200)
        .chartXScale(domain: 0...1)
        .chartYScale(domain: 0...10)
        .chartXAxis {
            AxisMarks(values: [0, 0.25, 0.5, 0.75, 1]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(percentFormatter.string(from: NSNumber(value: doubleValue)) ?? "")
                    }
                }
            }
        }
        .chartOverlay { proxy in
            probabilityOverlay(proxy: proxy)
        }
    }
    
    private func probabilityBar(for prospect: Player) -> some ChartContent {
        BarMark(
            x: .value("Probability", prospect.projectedStats.careerProbability),
            y: .value("Count", 1)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Theme.colorForProbability(prospect.projectedStats.careerProbability),
                    Theme.colorForProbability(prospect.projectedStats.careerProbability).opacity(0.7)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .cornerRadius(8)
        .annotation(position: .top) {
            if selectedProbability == prospect.projectedStats.careerProbability {
                Text(prospect.fullName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func probabilityOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if let plotFrame = proxy.plotFrame {
                                let x = value.location.x - geometry[plotFrame].origin.x
                                guard let probability = proxy.value(atX: x) as Double? else { return }
                                selectedProbability = probability
                            }
                        }
                        .onEnded { _ in
                            selectedProbability = nil
                        }
                )
        }
    }
}

struct TopProspectsWARChart: View {
    let prospects: [Player]
    @State private var selectedProspect: Player?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projected Peak WAR")
                .font(.headline)
            
            warChart
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var warChart: some View {
        Chart {
            ForEach(topProspects) { prospect in
                warBar(for: prospect)
            }
        }
        .frame(height: 250)
        .chartXAxis(.visible)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartOverlay { proxy in
            warOverlay(proxy: proxy)
        }
    }
    
    private var topProspects: [Player] {
        Array(prospects.sorted { $0.projectedStats.peakWAR > $1.projectedStats.peakWAR }.prefix(10))
    }
    
    private func warBar(for prospect: Player) -> some ChartContent {
        BarMark(
            x: .value("Name", prospect.fullName),
            y: .value("WAR", prospect.projectedStats.peakWAR)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Theme.colorForWAR(prospect.projectedStats.peakWAR),
                    Theme.colorForWAR(prospect.projectedStats.peakWAR).opacity(0.7)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .cornerRadius(8)
        .annotation(position: .top) {
            if selectedProspect?.id == prospect.id {
                Text(String(format: "%.1f WAR", prospect.projectedStats.peakWAR))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func warOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if let plotFrame = proxy.plotFrame {
                                let x = value.location.x - geometry[plotFrame].origin.x
                                guard let index = proxy.value(atX: x) as Int? else { return }
                                if index < topProspects.count {
                                    selectedProspect = topProspects[index]
                                }
                            }
                        }
                        .onEnded { _ in
                            selectedProspect = nil
                        }
                )
        }
    }
}

struct PositionDistributionChart: View {
    let prospects: [Player]
    
    var positionCounts: [String: Int] {
        Dictionary(grouping: prospects) { $0.position.name }
            .mapValues { $0.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position Distribution")
                .font(.headline)
            
            Chart(positionCounts.sorted(by: { $0.value > $1.value }), id: \.key) { position in
                SectorMark(
                    angle: .value("Count", position.value),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Position", position.key))
                .cornerRadius(8)
            }
            .frame(height: 300)
            .chartLegend(position: .bottom, spacing: 20)
            .chartForegroundStyleScale(range: Theme.chartColors)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProspectTimelineChart: View {
    let prospects: [Player]
    
    var sortedProspects: [Player] {
        prospects.sorted { $0.projectedStats.projectedDebut < $1.projectedStats.projectedDebut }
    }
    
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let earliestYear = Int(sortedProspects.first?.projectedStats.projectedDebut ?? "2024") ?? 2024
        let latestYear = Int(sortedProspects.last?.projectedStats.projectedDebut ?? "2024") ?? 2024
        
        let start = calendar.date(from: DateComponents(year: earliestYear))!
        let end = calendar.date(from: DateComponents(year: latestYear + 1))!
        
        return start...end
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MLB Debut Timeline")
                .font(.headline)
            
            Chart {
                ForEach(sortedProspects) { prospect in
                    if let debutYear = Int(prospect.projectedStats.projectedDebut),
                       let debutDate = Calendar.current.date(from: DateComponents(year: debutYear)) {
                        PointMark(
                            x: .value("Year", debutDate),
                            y: .value("WAR", prospect.projectedStats.peakWAR)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .annotation(position: .top) {
                            Text(prospect.fullName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 300)
            .chartXScale(domain: dateRange)
            .chartXAxis {
                AxisMarks(values: .stride(by: .year)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.year())
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct KeyStatsView: View {
    let prospects: [Player]
    
    private var averageMLBReadiness: Double {
        guard !prospects.isEmpty else { return 0 }
        return prospects.reduce(0.0) { $0 + $1.projectedStats.careerProbability } / Double(prospects.count)
    }
    
    private var nextYearDebutCount: Int {
        let nextYear = Calendar.current.component(.year, from: Date()) + 1
        return prospects.filter { $0.projectedStats.projectedDebut == String(nextYear) }.count
    }
    
    private var topPositionProspect: (name: String, war: Double)? {
        prospects
            .max(by: { $0.projectedStats.peakWAR < $1.projectedStats.peakWAR })
            .map { ($0.fullName, $0.projectedStats.peakWAR) }
    }
    
    private var immediateImpactCount: Int {
        prospects.filter { 
            $0.projectedStats.careerProbability >= 0.8 && 
            $0.projectedStats.peakWAR >= 3.0 
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("MLB Predictions")
                    .font(.title3.bold())
                
                Spacer()
                
                Text("2024 Season")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                StatCard(
                    title: "MLB Ready Next Year",
                    value: "\(nextYearDebutCount)",
                    color: Theme.primary
                )
                
                StatCard(
                    title: "Impact Players",
                    value: "\(immediateImpactCount)",
                    color: Theme.accent
                )
                
                StatCard(
                    title: "Top Prospect",
                    value: topPositionProspect.map { String(format: "%.1f WAR", $0.war) } ?? "N/A",
                    color: Theme.colorForWAR(topPositionProspect?.war ?? 0)
                )
                
                StatCard(
                    title: "MLB Readiness",
                    value: String(format: "%.0f%%", averageMLBReadiness * 100),
                    color: Theme.colorForProbability(averageMLBReadiness)
                )
            }
            
            if let topProspect = topPositionProspect {
                Text("Top Prospect: \(topProspect.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
} 