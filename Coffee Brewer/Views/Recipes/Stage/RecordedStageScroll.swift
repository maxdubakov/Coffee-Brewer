import SwiftUI

struct RecordedStageScroll: View {
    let recordedTimestamps: [(time: Double, id: UUID, type: StageType)]
    let currentIndex: Int
    let onRemove: (Int) -> Void
    
    @State private var scrollPosition: UUID?
    
    var body: some View {
        if recordedTimestamps.isEmpty {
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
                        ForEach(Array(recordedTimestamps.enumerated()), id: \.1.id) { index, timestamp in
                            RecordedStageCard(
                                stageNumber: index + 1,
                                timestamp: timestamp.time,
                                stageType: timestamp.type,
                                previousTimestamp: index > 0 ? recordedTimestamps[index - 1].time : 0,
                                onRemove: {
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
                .onChange(of: recordedTimestamps.count) { oldCount, newCount in
                    if newCount > oldCount, let lastTimestamp = recordedTimestamps.last {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            proxy.scrollTo(lastTimestamp.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastTimestamp = recordedTimestamps.last {
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
    let onRemove: () -> Void
    
    private var stageDuration: Int16 {
        Int16(timestamp - previousTimestamp)
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
                    StageInfo(
                        icon: stageType.icon,
                        title: stageType.displayName,
                        color: stageType.color
                    )
                    
                    HStack(spacing: 6) {
                        // Recording time
                        Text("Recorded at \(formattedTime)")
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        // Duration
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
            },
            trailing: {
                // Remove button
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    GlobalBackground {
        RecordedStageScroll(
            recordedTimestamps: [
                (time: 0, id: UUID(), type: .fast),
                (time: 15, id: UUID(), type: .slow),
                (time: 45, id: UUID(), type: .wait),
                (time: 75, id: UUID(), type: .slow)
            ],
            currentIndex: 2,
            onRemove: { _ in }
        )
        .padding()
    }
}
