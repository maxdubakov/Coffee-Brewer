import SwiftUI

struct OnboardingOverlay<Content: View>: View {
    let content: Content
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 24) {
                content
            }
            .padding(28)
            .background(
                ZStack {
                    // Base dark background
                    BrewerColors.darkBackground
                    
                    // Premium gradient overlay
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
            .cornerRadius(28)
            .shadow(color: BrewerColors.caramel.opacity(0.15), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.3), radius: 40, x: 0, y: 20)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                BrewerColors.cream.opacity(0.2),
                                BrewerColors.cream.opacity(0.1),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea(.keyboard)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .opacity
        ))
    }
}

#Preview {
    OnboardingOverlay(onDismiss: {}) {
        VStack(spacing: 16) {
            Text("Welcome")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(BrewerColors.textPrimary)
            Text("This is a preview")
                .foregroundStyle(BrewerColors.textPrimary)
        }
    }
}
