import SwiftUI

struct SmallHeader: View {
    let title: String
    
    var body : some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .fontWeight(.semibold)
            .foregroundColor(BrewerColors.textPrimary)
    }
}

#Preview {
    GlobalBackground {
        VStack {
            SmallHeader(title: "SmallHeader Title")
            Spacer()
        }
    }
}
