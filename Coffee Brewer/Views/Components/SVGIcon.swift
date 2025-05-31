import SwiftUI

struct SVGIcon: View {
    let name: String
    let size: CGFloat
    let color: Color?
    
    init(_ name: String, size: CGFloat = 24, color: Color? = nil) {
        self.name = name
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}

#Preview {
    VStack(spacing: 20) {
        SVGIcon("grinder", size: 32)
        SVGIcon("grinder", size: 48, color: .blue)
        SVGIcon("grinder", size: 24, color: .red)
    }
}
