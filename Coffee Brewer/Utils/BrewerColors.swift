import SwiftUI

struct BrewerColors {
    // Main app colors
    static let background = Color(red: 0.05, green: 0.03, blue: 0.01)
    static let cardBackground = Color(red: 0.07, green: 0.06, blue: 0.05)
    static let surface = Color(red: 0.12, green: 0.10, blue: 0.08)
    
    // Text colors
    static let textPrimary = Color(red: 0.93, green: 0.91, blue: 0.90)
    static let textSecondary = Color(red: 0.93, green: 0.91, blue: 0.90).opacity(0.7)
    static let textLight = Color(red: 0.92, green: 0.86, blue: 0.81).opacity(1.0)
    static let placeholder = Color(red: 0.93, green: 0.91, blue: 0.90).opacity(0.4)
    
    // Accent colors
    static let coffee = Color(red: 0.55, green: 0.27, blue: 0.07).opacity(0.50)
    static let cream = Color(red: 0.93, green: 0.87, blue: 0.80)
    
    // UI elements
    static let divider = Color(red: 0.71, green: 0.63, blue: 0.57).opacity(0.2)
    static let inputBackground = Color(red: 0.88, green: 0.79, blue: 0.72).opacity(0.12)
    
    static let espresso = Color(red: 0.28, green: 0.16, blue: 0.08)
    static let caramel = Color(red: 0.76, green: 0.55, blue: 0.32)
    static let mocha = Color(red: 0.45, green: 0.30, blue: 0.20)
    static let amber = Color(red: 0.85, green: 0.65, blue: 0.30)
    
    // Button states
    static let buttonShadow = Color.black.opacity(0.3)
    static let buttonHighlight = Color.white.opacity(0.1)
}
