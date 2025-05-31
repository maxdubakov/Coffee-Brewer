import SwiftUI

struct Welcome: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var onboardingState = OnboardingStateManager.shared
    @State private var currentStep = 1
    @State private var roasterName = ""
    @State private var selectedCountry: Country?
    @State private var grinderName = ""
    @State private var grinderType = "Manual"
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
                QuickGrinderStep(
                    grinderName: $grinderName,
                    grinderType: $grinderType,
                    onContinue: createGrinderAndProceed,
                    onBack: { currentStep = 2 }
                )
            case 4:
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
    
    private func createGrinderAndProceed() {
        guard !grinderName.isEmpty else { return }
        
        let newGrinder = Grinder(context: viewContext)
        newGrinder.id = UUID()
        newGrinder.name = grinderName
        newGrinder.type = grinderType
        
        do {
            try viewContext.save()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep = 4
            }
        } catch {
            print("Failed to save grinder: \(error)")
        }
    }
}

struct WelcomeStep: View {
    let onGetStarted: () -> Void
    let onSkip: () -> Void
    
    @State private var iconRotation = 0.0
    
    var body: some View {
        VStack {
            // Top section with icon
            VStack(spacing: 24) {
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
                .frame(height: 120)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 5.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        iconRotation = 8
                    }
                }
                
                VStack(spacing: 12) {
                    Text("Welcome to\nCoffee Brewer")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text("Your personal brewing companion")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: 240) // Fixed height for top section
            
            Spacer(minLength: 20)
            
            // Bottom section with buttons
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
        .frame(height: 400) // Fixed total height
    }
}

struct QuickRoasterStep: View {
    @Binding var roasterName: String
    @Binding var selectedCountry: Country?
    @State private var focusedField: FocusedField?
    
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            // Top section with title
            VStack(spacing: 12) {
                Text("Add Your First Roaster")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text("You can add more details later")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100) // Fixed height for title section
            
            // Middle section with form fields
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
            .frame(height: 140) // Fixed height for form section
            
            Spacer(minLength: 20)
            
            // Bottom section with buttons
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
        .frame(height: 400) // Fixed total height
    }
}

struct QuickGrinderStep: View {
    @Binding var grinderName: String
    @Binding var grinderType: String
    @State private var focusedField: FocusedField?
    
    let onContinue: () -> Void
    let onBack: () -> Void
    
    let grinderTypes = ["Manual", "Electric"]
    
    var body: some View {
        VStack {
            // Top section with title
            VStack(spacing: 12) {
                Text("Add Your Grinder")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text("Tell us about your coffee grinder")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100) // Fixed height for title section
            
            // Middle section with form fields
            VStack(spacing: 16) {
                FormKeyboardInputField(
                    title: "Grinder Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $grinderName,
                    focusedField: $focusedField
                )
                
                FormToggleField(
                    title: "Type",
                    options: grinderTypes,
                    selectedOption: $grinderType
                )
            }
            .frame(height: 140) // Fixed height for form section
            
            Spacer(minLength: 20)
            
            // Bottom section with buttons
            VStack(spacing: 12) {
                StandardButton(
                    title: "Continue",
                    action: onContinue,
                    style: .primary
                )
                .disabled(grinderName.isEmpty)
                
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
        .frame(height: 400) // Fixed total height
    }
}

struct ReadyToBrew: View {
    let onCreateRecipe: () -> Void
    let onExplore: () -> Void
    
    @State private var checkmarkScale = 0.0
    @State private var checkmarkOpacity = 0.0
    @State private var glowOpacity = 0.0
    
    var body: some View {
        VStack {
            // Top section with icon and title
            VStack(spacing: 24) {
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
                .frame(height: 120)
                
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
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: 220) // Fixed height for top section
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    checkmarkScale = 1.0
                    checkmarkOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                    glowOpacity = 1.0
                }
            }
            
            Spacer(minLength: 20)
            
            // Bottom section with buttons
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
        .frame(height: 400) // Fixed total height
    }
}

#Preview {
    Welcome(
        onComplete: {},
        onSkip: {}
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
