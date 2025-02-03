import SwiftUI

struct CareerProbabilityGraph: View {
    let probability: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: probability)
            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .foregroundColor(probabilityColor)
            .rotationEffect(.degrees(-90))
            .frame(width: 30, height: 30)
            .overlay(
                Text("\(Int(probability * 100))")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
            )
    }
    
    private var probabilityColor: Color {
        switch probability {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        default: return .red
        }
    }
} 