import SwiftUI

struct Settings: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GlobalBackground {
            VStack(spacing: 0) {
                // Fixed header
                VStack(spacing: 0) {
                    PageTitleH1("Settings", subtitle: "Manage your coffee data")
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 32) {
                        DataManagement()
                        Preferences()
                        Tutorial()
                        
                        // About Section with premium touch
                        VStack(alignment: .leading, spacing: 20) {
                            Text("About")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(BrewerColors.textPrimary)
                            
                            VStack(spacing: 0) {
                                // Version with subtle badge
                                HStack {
                                    Text("Version")
                                        .font(.system(size: 15))
                                        .foregroundColor(BrewerColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        Text("1.0.0")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(BrewerColors.textSecondary)
                                        
                                        // Premium version badge
                                        Text("PRO")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(BrewerColors.caramel)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                Capsule()
                                                    .fill(BrewerColors.caramel.opacity(0.15))
                                            )
                                    }
                                }
                                .padding(.vertical, 16)
                                
                                CustomDivider()
                                    .opacity(0.5)
                                
                                // Developer with subtle branding
                                HStack {
                                    Text("Developer")
                                        .font(.system(size: 15))
                                        .foregroundColor(BrewerColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("Coffee Brewer Team")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [BrewerColors.caramel, BrewerColors.caramel.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .padding(.vertical, 16)
                            }
                            .padding(.horizontal, 20)
                            .background(BrewerColors.cardBackground.opacity(0.5))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                BrewerColors.divider.opacity(0.3),
                                                BrewerColors.divider.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                        }
                        
                        // Premium footer
                        VStack(spacing: 12) {
                            SVGIcon("coffee.beans", size: 30, color: BrewerColors.textSecondary.opacity(0.3))
                            
                            Text("Brew better coffee, every time")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.3))
                                .italic()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        Color.clear.frame(height: 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
    GlobalBackground {
        Settings()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
