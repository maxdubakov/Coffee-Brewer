enum CoffeeStrength: String, CaseIterable {
  case light = "Light"
  case medium = "Medium"
  case strong = "Strong"
  
  var ratio: Double {
    switch self {
    case .light: return 17.0
    case .medium: return 15.5
    case .strong: return 14.444444444
    }
  }
  
  var description: String {
    switch self {
    case .light: return "Smooth"
    case .medium: return "Balanced"
    case .strong: return "Full-Bodied"
    }
  }
}
