import SwiftUI

class RecordingDemoOverlay: ObservableObject {
    @Published var demoStep = 0
    @Published var demoRecordedStages: [(time: Double, id: UUID, type: StageType)] = []
    
    var onDismiss: (() -> Void)?
    
    var currentDemoStep: Int {
        demoStep
    }
    
    var hasSeenRecordingDemo: Bool {
        OnboardingStateManager.shared.hasSeenRecordingDemo
    }
    
    var demoStages: [(time: Double, id: UUID, type: StageType)] {
        demoRecordedStages
    }
    
    func advanceDemo() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if demoStep < 4 {
                demoStep += 1
                
                // Set up demo stages when reaching step 2
                if demoStep == 2 {
                    demoRecordedStages = [
                        (time: 8.0, id: UUID(), type: .fast),
                        (time: 15.0, id: UUID(), type: .wait),
                    ]
                }
            } else {
                OnboardingStateManager.shared.hasSeenRecordingDemo = true
                onDismiss?()
            }
        }
    }
}

struct RecordingDemoOverlayView: View {
    @StateObject private var onboardingState = OnboardingStateManager.shared
    @ObservedObject var demo: RecordingDemoOverlay
    
    var body: some View {
        if !onboardingState.hasSeenRecordingDemo {
            demoOverlay
                .transition(.opacity)
        }
    }
    
    private var demoOverlay: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        onboardingState.hasSeenRecordingDemo = true
                        withAnimation(.easeOut(duration: 0.3)) {
                            demo.onDismiss?()
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BrewerColors.cream)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(BrewerColors.surface.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .strokeBorder(BrewerColors.cream.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Group {
                    switch demo.demoStep {
                    case 0:
                        demoStep1
                    case 1:
                        demoStep2
                    case 2:
                        demoStep3
                    case 3:
                        demoStep4
                    case 4:
                        demoStep5
                    default:
                        EmptyView()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    demo.advanceDemo()
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 50 && demo.demoStep > 0 {
                                // Swipe right - go to previous step
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    demo.demoStep -= 1
                                }
                            } else if value.translation.width < -50 && demo.demoStep < 4 {
                                // Swipe left - go to next step
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    demo.demoStep += 1
                                    
                                    // Set up demo stages when reaching step 2
                                    if demo.demoStep == 2 && demo.demoRecordedStages.isEmpty {
                                        demo.demoRecordedStages = [
                                            (time: 8.0, id: UUID(), type: .fast),
                                            (time: 15.0, id: UUID(), type: .wait),
                                        ]
                                    }
                                }
                            }
                        }
                )
                
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index == demo.demoStep ? BrewerColors.amber : BrewerColors.cream.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == demo.demoStep ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: demo.demoStep)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    demo.demoStep = index
                                    
                                    // Set up demo stages when jumping to step 2
                                    if index == 2 && demo.demoRecordedStages.isEmpty {
                                        demo.demoRecordedStages = [
                                            (time: 8.0, id: UUID(), type: .fast),
                                            (time: 15.0, id: UUID(), type: .wait),
                                        ]
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 70)
            }
        }
    }
    
    private var demoStep1: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Start recording")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Tap to start the timer and begin recording your pour")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.39)
                
                Spacer()
            }
        }
    }
    
    private var demoStep2: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Save the pour")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)

                    Text("This will add an 8-second Fast pour to Recorded Stages")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.39)
                
                Spacer()
            }
        }
    }
    
    private var demoStep3: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Recorded Stages")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Time between your pours is tracked automatically and added as a Wait stage")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var demoStep4: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Text("Control your brew")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Use pause/play to control timing, or restart to begin fresh")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var demoStep5: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(BrewerColors.amber)
                        .scaleAnimation()
                    
                    Text("Complete your recipe")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("You can then adjust water amounts and timing for each stage")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.35)
                
                Spacer()
            }
        }
    }
}
