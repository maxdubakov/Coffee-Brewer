import SwiftUI

struct RecordedStageScroll: View {
    let displayTimestamps: [(time: Double, id: UUID, type: StageType, isActive: Bool)]
    let currentElapsedTime: Double
    let onRemove: (Int) -> Void
    
    @State private var scrollPosition: UUID?
    
    var body: some View {
        if displayTimestamps.isEmpty {
            // Empty state
            VStack(spacing: 16) {
                Text("No stages recorded yet")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                
                Text("Start the timer and tap to record stages")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.horizontal, 18)
        } else {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(Array(displayTimestamps.enumerated()), id: \.1.id) { index, timestamp in
                            RecordedStageCard(
                                stageNumber: index + 1,
                                timestamp: timestamp.time,
                                stageType: timestamp.type,
                                previousTimestamp: index > 0 ? displayTimestamps[index - 1].time : 0,
                                isActive: timestamp.isActive,
                                currentElapsedTime: currentElapsedTime,
                                onRemove: timestamp.isActive ? nil : {
                                    onRemove(index)
                                }
                            )
                            .id(timestamp.id)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: timestamp.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .scrollClipDisabled()
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.05),
                            .init(color: .black, location: 0.95),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .onChange(of: displayTimestamps.count) { oldCount, newCount in
                    if newCount > oldCount, let lastTimestamp = displayTimestamps.last {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            proxy.scrollTo(lastTimestamp.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastTimestamp = displayTimestamps.last {
                        proxy.scrollTo(lastTimestamp.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct RecordedStageCard: View {
    let stageNumber: Int
    let timestamp: Double
    let stageType: StageType
    let previousTimestamp: Double
    let isActive: Bool
    let currentElapsedTime: Double
    let onRemove: (() -> Void)?
    
    private var stageDuration: Int16 {
        if isActive {
            return Int16(currentElapsedTime - previousTimestamp)
        } else {
            return Int16(timestamp - previousTimestamp)
        }
    }
    
    
    private var formattedTime: String {
        timestamp.formattedTime
    }
    
    var body: some View {
        StageCard(
            stageNumber: stageNumber,
            stageType: stageType,
            content: {
                // Stage details
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        StageInfo(
                            icon: stageType.icon,
                            title: stageType.displayName,
                            color: stageType.color
                        )
                        
                        if isActive {
                            // Active indicator
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(stageType.color)
                                    .frame(width: 6, height: 6)
                                    .scaleAnimation()
                                
                                Text("Recording...")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(stageType.color)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(stageType.color.opacity(0.1))
                            )
                        }
                    }
                    
                    HStack(spacing: 6) {
                        // Recording time or duration
                        if isActive {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(stageType.color)
                                
                                Text("\(stageDuration)s")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(stageType.color)
                                    .monospacedDigit()
                            }
                        } else {
                            Text("Recorded at \(formattedTime)")
                                .font(.system(size: 14))
                                .foregroundColor(BrewerColors.textSecondary)
                            
                            // Duration for completed stages
                            if stageNumber > 1 {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 10))
                                        .foregroundColor(BrewerColors.textSecondary)
                                    
                                    Text("\(stageDuration)s")
                                        .font(.system(size: 14))
                                        .foregroundColor(BrewerColors.textSecondary)
                                }
                            }
                        }
                    }
                }
            },
            trailing: {
                // Remove button (only for completed stages)
                if let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                    }
                }
            }
        )
        .opacity(isActive ? 0.9 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    GlobalBackground {
        RecordedStageScroll(
            displayTimestamps: [
                (time: 0, id: UUID(), type: .fast, isActive: false),
                (time: 15, id: UUID(), type: .slow, isActive: false),
                (time: 45, id: UUID(), type: .wait, isActive: false),
                (time: 75, id: UUID(), type: .slow, isActive: true)
            ],
            currentElapsedTime: 82,
            onRemove: { _ in }
        )
        .padding()
    }
}
