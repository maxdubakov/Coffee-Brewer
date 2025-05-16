import SwiftUI

struct PlaceholderText: View {
    var value: String
    var body: some View {
        Text(value)
            .font(.system(size: 17, weight: .light))
            .foregroundColor(BrewerColors.placeholder)
    }
}
