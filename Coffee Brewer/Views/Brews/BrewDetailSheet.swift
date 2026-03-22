import SwiftUI

struct BrewDetailSheet: View {
    @ObservedObject var brew: Brew
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var showRatingSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Main brew card
            VStack(spacing: 0) {
                // Header section with brew info
                VStack(spacing: 20) {
                    // Top: Coffee name and rating
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(brew.coffeeName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BrewerColors.cream)
                                .lineLimit(2)

                            if let roasterName = brew.roasterName {
                                Text(roasterName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary)
                            }
                        }

                        Spacer()

                        if brew.rating > 0 {
                            HalfStarRating(rating: .constant(brew.rating), starSize: 16, spacing: 4)
                                .allowsHitTesting(false)
                        }
                    }

                    // Bottom: key metrics
                    VStack(spacing: 16) {
                        if brew.tds > 0 {
                            HStack(spacing: 24) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TDS")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                    Text(String(format: "%.2f%%", brew.tds))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(BrewerColors.cream)
                                }

                                Spacer()
                            }
                        }

                        // Brew parameters
                        HStack(spacing: 12) {
                            BrewMetric(
                                iconName: "scalemass",
                                value: "\(brew.grams)g",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 80)

                            BrewMetric(
                                iconName: "drop",
                                value: "\(brew.waterAmount)ml",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 80)

                            BrewMetric(
                                iconName: "thermometer",
                                value: "\(Int(brew.temperature))°C",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 80)

                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 20)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    BrewerColors.cardBackground,
                                    BrewerColors.cardBackground.opacity(0.9),
                                    BrewerColors.caramel.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Taste profile section
            if hasTasteProfile {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Taste Profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        TasteProfileRow(label: "Acidity", value: Int(brew.acidity))
                        TasteProfileRow(label: "Sweetness", value: Int(brew.sweetness))
                        TasteProfileRow(label: "Bitterness", value: Int(brew.bitterness))
                        TasteProfileRow(label: "Body", value: Int(brew.body))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24)
            }

            // Notes section
            if let notes = brew.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)

                    Text(notes)
                        .font(.system(size: 15))
                        .foregroundColor(BrewerColors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(BrewerColors.cardBackground.opacity(0.5))
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.top, 24)
            }

            // Brew Again button
            Button {
                navigationCoordinator.pendingCloneBrew = brew
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .medium))
                    Text("Brew Again")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(BrewerColors.caramel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(BrewerColors.caramel.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            // Rate This Brew button
            Button {
                showRatingSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.system(size: 15, weight: .medium))
                    Text(brew.isAssessed ? "Update Rating" : "Rate This Brew")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(BrewerColors.caramel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(BrewerColors.caramel.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()
        }
        .background(BrewerColors.background.ignoresSafeArea())
        .sheet(isPresented: $showRatingSheet) {
            RatingSheet(brew: brew)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var hasTasteProfile: Bool {
        brew.acidity > 0 || brew.sweetness > 0 || brew.bitterness > 0 || brew.body > 0
    }
}

// MARK: - Brew Metric
private struct BrewMetric: View {
    let iconName: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(BrewerColors.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Taste Profile Row
private struct TasteProfileRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
                .frame(width: 80, alignment: .leading)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BrewerColors.divider)
                        .frame(height: 8)

                    if value > 0 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(BrewerColors.caramel)
                            .frame(width: geometry.size.width * CGFloat(value) / 10.0, height: 8)
                    }
                }
            }
            .frame(height: 8)

            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(BrewerColors.cream)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext

    let brew = Brew(context: context)
    let _ = {
        brew.id = UUID()
        brew.roasterName = "Blue Bottle Coffee"
        brew.date = Date()
        brew.rating = 4.0
        brew.grams = 18
        brew.waterAmount = 250
        brew.temperature = 94
        brew.tds = 1.35
        brew.acidity = 7
        brew.sweetness = 8
        brew.bitterness = 3
        brew.body = 6
        brew.notes = "Wonderful fruity notes with hints of blueberry and chocolate."
    }()

    BrewDetailSheet(brew: brew)
}
