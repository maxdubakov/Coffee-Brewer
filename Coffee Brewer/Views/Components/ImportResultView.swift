import SwiftUI

struct ImportResultView: View {
    let result: ImportResult
    @Binding var isPresented: Bool
    
    @State private var iconScale = 0.0
    @State private var iconOpacity = 0.0
    @State private var glowOpacity = 0.0
    @State private var contentOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
                // Top section with icon and title
                VStack(spacing: 24) {
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(result.isSuccess ? BrewerColors.caramel.opacity(0.2) : Color.orange.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                            .opacity(glowOpacity)
                        
                        // Main icon with premium gradient
                        if result.isSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            BrewerColors.caramel,
                                            BrewerColors.caramel.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(iconScale)
                                .opacity(iconOpacity)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.orange,
                                            Color.orange.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(iconScale)
                                .opacity(iconOpacity)
                        }
                    }
                    .frame(height: 120)
                    
                    VStack(spacing: 12) {
                        Text(result.isSuccess ? "Import Complete" : "Import Failed")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                        
                        if result.isSuccess && result.hasData {
                            Text("Successfully imported \(result.totalImported) items")
                                .font(.system(size: 16))
                                .foregroundColor(BrewerColors.textSecondary)
                                .multilineTextAlignment(.center)
                        } else if result.isSuccess && !result.hasData {
                            Text("No new data found to import")
                                .font(.system(size: 16))
                                .foregroundColor(BrewerColors.textSecondary)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Something went wrong during import")
                                .font(.system(size: 16))
                                .foregroundColor(BrewerColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .frame(height: 220)
                .opacity(contentOpacity)
                
                // Content section
                if result.isSuccess && result.hasData {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Imported Items
                            if result.totalImported > 0 {
                                ImportSectionView(
                                    title: "Successfully Imported",
                                    items: result.imported,
                                    iconName: "plus.circle.fill",
                                    iconColor: BrewerColors.caramel,
                                    total: result.totalImported
                                )
                            }
                            
                            // Ignored Items
                            if result.totalIgnored > 0 {
                                ImportSectionView(
                                    title: "Already Existed (Skipped)",
                                    items: result.ignored,
                                    iconName: "minus.circle.fill",
                                    iconColor: Color.orange,
                                    total: result.totalIgnored
                                )
                            }
                        }
                    }
                    .opacity(contentOpacity)
                } else if !result.isSuccess {
                    // Error details
                    VStack(spacing: 16) {
                        Text(result.error?.localizedDescription ?? "Unknown error occurred")
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .opacity(contentOpacity)
                }
                
                Spacer()
                
                // Close button
                StandardButton(
                    title: "Done",
                    action: { isPresented = false },
                    style: .primary
                )
                .opacity(contentOpacity)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(
            ZStack {
                // Base dark background
                BrewerColors.darkBackground
                
                // Premium gradient overlay (like onboarding)
                LinearGradient(
                    gradient: Gradient(colors: [
                        BrewerColors.caramel.opacity(0.15),
                        BrewerColors.caramel.opacity(0.05),
                        Color.clear,
                        BrewerColors.cream.opacity(0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle radial gradient for depth
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.08),
                        Color.clear
                    ]),
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 200
                )
            }
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                glowOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).delay(0.5)) {
                contentOpacity = 1.0
            }
        }
    }
}

struct ImportSectionView: View {
    let title: String
    let items: [String: Int]
    let iconName: String
    let iconColor: Color
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("\(total) item\(total == 1 ? "" : "s")")
                        .font(.system(size: 13))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                
                Spacer()
            }
            
            // Items List
            VStack(spacing: 6) {
                ForEach(items.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    HStack {
                        Text(key)
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        Spacer()
                        
                        Text("\(value)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(BrewerColors.cardBackground.opacity(0.6))
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            BrewerColors.cardBackground.opacity(0.3)
                            
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.03),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(BrewerColors.cardBackground.opacity(0.5))
        .cornerRadius(16)
    }
}

#Preview {
    ImportResultView(
        result: ImportResult.success(
            imported: ["Recipes": 3, "Roasters": 2, "Brews": 5],
            ignored: ["Recipes": 1, "Grinders": 2]
        ),
        isPresented: .constant(true)
    )
    .background(BrewerColors.background)
}
