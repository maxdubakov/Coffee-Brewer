import SwiftUI

struct BackButton: View {
    let action: () -> Void
    var body: some View {
        HStack {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                }
                .foregroundColor(BrewerColors.textPrimary)
            }
            .padding(.leading, 18)
            
            Spacer()
        }
    }
}
