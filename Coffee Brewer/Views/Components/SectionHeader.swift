import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body : some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(BrewerColors.textPrimary)
                .padding(.vertical, 30)
            Spacer()
        }
    }
}

#Preview {
    GlobalBackground {
        VStack {
            SectionHeader(title: "Title")
            Spacer()
        }
    }
}
