import SwiftUI

struct RecipeForm<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content() 
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            content
        }
        .padding(.bottom, 20)
        .contentShape(Rectangle())
    }
}
