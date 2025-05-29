import SwiftUI

struct CustomDivider: View {
    let widthPercentage: CGFloat
    let color: Color
    let height: CGFloat
    let alignment: Alignment
    
    init(widthPercentage: CGFloat = 1.0, color: Color = Color.primary.opacity(0.15), height: CGFloat = 0.5, alignment: Alignment = .leading) {
        self.widthPercentage = widthPercentage
        self.color = color
        self.height = height
        self.alignment = alignment
    }
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(color)
                .frame(width: geometry.size.width * widthPercentage, height: height)
                .frame(maxWidth: .infinity, alignment: alignment)
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Item 1")
        CustomDivider(alignment: .leading)
        Text("Item 2")
        CustomDivider(alignment: .center)
        Text("Item 3")
        CustomDivider(alignment: .trailing)
        Text("Item 4")
    }
    .padding()
}
