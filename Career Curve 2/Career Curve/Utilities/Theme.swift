import SwiftUI

struct Theme {
    @Environment(\.colorScheme) static var colorScheme
    
    // MARK: - Base Colors
    static var primary: Color {
        colorScheme == .dark ? .white : .black
    }
    
    static var secondary: Color {
        colorScheme == .dark ? .gray : .gray
    }
    
    static var accent: Color {
        colorScheme == .dark ? Color(red: 0.4, green: 0.6, blue: 1.0) : .blue
    }
    
    static var background: Color {
        colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : .white
    }
    
    static var secondaryBackground: Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.16) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    // MARK: - Chart Colors
    static let chartColors: [Color] = [
        .blue, .green, .orange, .purple, .pink, .red, .yellow, .cyan, .indigo, .mint
    ]
    
    // MARK: - Dynamic Colors for Stats
    static func colorForProbability(_ value: Double) -> Color {
        let baseColors: (light: Color, dark: Color) = {
            switch value {
            case 0.8...1.0:
                return (.green, Color(red: 0.2, green: 0.8, blue: 0.3))
            case 0.6..<0.8:
                return (.blue, Color(red: 0.3, green: 0.6, blue: 1.0))
            case 0.4..<0.6:
                return (.orange, Color(red: 1.0, green: 0.6, blue: 0.2))
            default:
                return (.red, Color(red: 1.0, green: 0.3, blue: 0.3))
            }
        }()
        
        return colorScheme == .dark ? baseColors.dark : baseColors.light
    }
    
    static func colorForWAR(_ value: Double) -> Color {
        let baseColors: (light: Color, dark: Color) = {
            switch value {
            case 5...:
                return (.purple, Color(red: 0.8, green: 0.3, blue: 0.8))
            case 3..<5:
                return (.blue, Color(red: 0.3, green: 0.6, blue: 1.0))
            case 1..<3:
                return (.green, Color(red: 0.2, green: 0.8, blue: 0.3))
            default:
                return (.orange, Color(red: 1.0, green: 0.6, blue: 0.2))
            }
        }()
        
        return colorScheme == .dark ? baseColors.dark : baseColors.light
    }
    
    // MARK: - UI Element Colors
    static var cardBackground: Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.16) : .white
    }
    
    static var cardBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
    
    static var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1)
    }
    
    // MARK: - Text Colors
    static var titleText: Color {
        colorScheme == .dark ? .white : .black
    }
    
    static var bodyText: Color {
        colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.9)
    }
    
    static var captionText: Color {
        colorScheme == .dark ? .gray : .gray
    }
} 