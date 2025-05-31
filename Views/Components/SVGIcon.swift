import SwiftUI

struct SVGIcon: View {
    let name: String
    let size: CGFloat
    
    init(_ name: String, size: CGFloat = 24) {
        self.name = name
        self.size = size
    }
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        SVGIcon("coffee-beans", size: 32)
        SVGIcon("history", size: 48)
        SVGIcon("more", size: 24)
    }
}