struct CoffeePrompts {
  static let messages = [
    "☕️ How much coffee today?",
    "⚖️ Let's measure your coffee!",
    "🫘 Show me your coffee scoop!",
    "📏 Your coffee dose for today?",
    "✨ Time to measure those beans!"
  ]
  
  static let selectedPrompt: String = messages.randomElement() ?? "☕️ How much coffee today?"
  
}
