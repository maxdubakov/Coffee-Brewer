import SwiftUI

struct FormField<Content: View> : View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}
