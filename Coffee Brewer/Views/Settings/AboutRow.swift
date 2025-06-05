import SwiftUI

struct AboutRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(BrewerColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(BrewerColors.textSecondary)
        }
    }
}
