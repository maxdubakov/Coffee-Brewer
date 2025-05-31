import SwiftUI

struct Welcome: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var onboardingState = OnboardingStateManager.shared
    @State private var currentStep = 1
    @State private var roasterName = ""
    @State private var selectedCountry: Country?
    @State private var showSuccess = false
    
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        OnboardingOverlay(onDismiss: onSkip) {
            switch currentStep {
            case 1:
                WelcomeStep(
                    onGetStarted: { currentStep = 2 },
                    onSkip: onSkip
                )
            case 2:
                QuickRoasterStep(
                    roasterName: $roasterName,
                    selectedCountry: $selectedCountry,
                    onContinue: createRoasterAndProceed,
                    onBack: { currentStep = 1 }
                )
            case 3:
                ReadyToBrew(
                    onCreateRecipe: onComplete,
                    onExplore: onComplete
                )
            default:
                EmptyView()
            }
        }
    }
    
    private func createRoasterAndProceed() {
        guard !roasterName.isEmpty && selectedCountry != nil else { return }
        
        let newRoaster = Roaster(context: viewContext)
        newRoaster.id = UUID()
        newRoaster.name = roasterName
        newRoaster.country = selectedCountry
        
        do {
            try viewContext.save()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep = 3
            }
        } catch {
            print("Failed to save roaster: \(error)")
        }
    }
}

struct WelcomeStep: View {
    let onGetStarted: () -> Void
    let onSkip: () -> Void
    
    @State private var iconRotation = 0.0
    
    var body: some View {
        VStack(spacing: 32) {
            // Premium icon with subtle glow
            ZStack {
                // Subtle glow effect
                Circle()
                    .fill(BrewerColors.caramel.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                
                // Main icon
                SVGIcon("coffee.beans", size: 80, color: BrewerColors.caramel)
                    .rotationEffect(.degrees(iconRotation))
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 5.0)
                        .repeatForever(autoreverses: true)
                ) {
                    iconRotation = 8
                }
            }
            
            VStack(spacing: 12) {
                Text("Welcome to Coffee Brewer")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text("Your personal brewing companion")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                StandardButton(
                    title: "Get Started",
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            onGetStarted()
                        }
                    },
                    style: .primary
                )
                
                StandardButton(
                    title: "I'll explore myself",
                    action: onSkip,
                    style: .secondary
                )
            }
        }
    }
}

struct QuickRoasterStep: View {
    @Binding var roasterName: String
    @Binding var selectedCountry: Country?
    @State private var focusedField: FocusedField?
    
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Add Your First Roaster")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(BrewerColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("You can add more details later")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                FormKeyboardInputField(
                    title: "Roaster Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $roasterName,
                    focusedField: $focusedField
                )
                
                SearchCountryPickerField(
                    selectedCountry: $selectedCountry,
                    focusedField: $focusedField
                )
            }
            
            VStack(spacing: 12) {
                StandardButton(
                    title: "Continue",
                    action: onContinue,
                    style: .primary
                )
                .disabled(roasterName.isEmpty || selectedCountry == nil)
                
                StandardButton(
                    title: "Back",
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            onBack()
                        }
                    },
                    style: .secondary
                )
            }
        }
    }
}

struct ReadyToBrew: View {
    let onCreateRecipe: () -> Void
    let onExplore: () -> Void
    
    @State private var checkmarkScale = 0.0
    @State private var checkmarkOpacity = 0.0
    @State private var glowOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(BrewerColors.caramel.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .opacity(glowOpacity)
                    
                    // Checkmark with premium gradient
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
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)
                }
                
                VStack(spacing: 12) {
                    Text("You're All Set!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text("Create your first recipe to start brewing")
                        .font(.system(size: 17))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    checkmarkScale = 1.0
                    checkmarkOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                    glowOpacity = 1.0
                }
            }
            
            VStack(spacing: 12) {
                StandardButton(
                    title: "Create First Recipe",
                    action: onCreateRecipe,
                    style: .primary
                )
                
                StandardButton(
                    title: "Explore App",
                    action: onExplore,
                    style: .secondary
                )
            }
        }
    }
}

#Preview {
    Welcome(
        onComplete: {},
        onSkip: {}
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
