import SwiftUI

struct PageTitleH2: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SecondaryHeader(title: title)
            
            Text(subtitle ?? "")
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
        .padding(.top, 8)
    }
}
