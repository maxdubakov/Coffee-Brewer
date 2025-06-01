import SwiftUI

struct CenteredContent<Content: View>: View {
    let content: Content
    let verticalOffset: CGFloat
    
    init(verticalOffset: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.verticalOffset = verticalOffset
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width)
                .frame(height: geometry.size.height)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2 + verticalOffset
                )
        }
    }
}

// MARK: - Preview
#Preview {
    CenteredContent {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Centered Content")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This content is centered on the screen")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}