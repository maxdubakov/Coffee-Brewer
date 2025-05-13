import SwiftUI

struct BrewerColors {
    // Main app colors
    static let background = Color(red: 0.05, green: 0.03, blue: 0.01)
    static let surface = Color(red: 0.12, green: 0.10, blue: 0.08)
    
    // Text colors
    static let textPrimary = Color(red: 0.93, green: 0.91, blue: 0.90)
    static let textSecondary = Color(red: 0.93, green: 0.91, blue: 0.90).opacity(0.7)
    static let placeholder = Color(red: 0.93, green: 0.91, blue: 0.90).opacity(0.4)
    
    // Accent colors
    static let coffee = Color(red: 0.55, green: 0.27, blue: 0.07)
    static let cream = Color(red: 0.93, green: 0.87, blue: 0.80)
    
    // UI elements
    static let divider = Color(red: 0.71, green: 0.63, blue: 0.57).opacity(0.2)
    static let inputBackground = Color(red: 0.88, green: 0.79, blue: 0.72).opacity(0.12)
}
