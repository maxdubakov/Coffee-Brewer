import SwiftUI

struct SecondaryHeader: View {
    let title: String
    
    var body : some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold))
            .fontWeight(.semibold)
            .foregroundColor(BrewerColors.textPrimary)
    }
}

#Preview {
    GlobalBackground {
        VStack {
            SecondaryHeader(title: "Secondary Title")
            Spacer()
        }
    }
}
