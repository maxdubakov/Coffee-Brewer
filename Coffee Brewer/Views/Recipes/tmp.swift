import SwiftUI

struct ModernScrollView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(MockData.items) { item in
                    Circle()
                        .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                        .foregroundStyle(item.color.gradient)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: 400)
        .contentMargins(40, for: .scrollContent)
        .scrollTargetBehavior(.paging)
    }
}

struct Item: Identifiable {
    let id = UUID()
    let color: Color
}

struct MockData {
    static var items = [
        Item(color: .teal),
        Item(color: .red),
        Item(color: .pink),
        Item(color: .green),
    ]
}

#Preview {
    ModernScrollView()
}
