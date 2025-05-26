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
    
    private var stageTypeText: String {
        switch stageType {
        case .fast:
            return "Fast Pour"
        case .slow:
            return "Slow Pour"
        case .wait:
            return "Wait"
        default:
            return stageType.name
        }
    }
    
    private var stageIcon: String {
        switch stageType {
        case .fast:
            return "drop.fill"
        case .slow:
            return "drop.fill"
        case .wait:
            return "hourglass"
        default:
            return "drop.fill"
        }
    }
    
    private var stageColor: Color {
        switch stageType {
        case .fast:
            return BrewerColors.caramel
        case .slow:
            return BrewerColors.caramel
        case .wait:
            return BrewerColors.amber
        default:
            return BrewerColors.caramel
        }
    }
    
    private var formattedTime: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Stage number circle
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [BrewerColors.espresso, stageColor.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Circle()
                            .strokeBorder(stageColor, lineWidth: 1.5)
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
                
                Text("\(stageNumber)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
            }
            
            // Stage details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: stageIcon)
                        .foregroundColor(stageColor)
                        .font(.system(size: 14, weight: .medium))
                    Text(stageTypeText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                
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
            
            Spacer()
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(BrewerColors.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(stageColor.opacity(0.2), lineWidth: 1)
                )
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
