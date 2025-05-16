import SwiftUI

struct SecondaryHeader: View {
    let title: String
    
    var body : some View {
        Text(title)
            .font(.headline)
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
