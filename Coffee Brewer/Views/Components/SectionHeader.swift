import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body : some View {
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(BrewerColors.textPrimary)
                .padding(.vertical, 40)
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
