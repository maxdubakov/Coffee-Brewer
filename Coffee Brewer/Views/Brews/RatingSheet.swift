import SwiftUI
import CoreData

struct RatingSheet: View {
    @ObservedObject var brew: Brew
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var rating: Double
    @State private var acidity: Double
    @State private var sweetness: Double
    @State private var bitterness: Double
    @State private var bodyValue: Double
    @State private var notes: String
    @State private var tasteProfileExpanded: Bool = false
    @State private var tasteProfileInitialized: Bool

    init(brew: Brew) {
        self.brew = brew
        _rating = State(initialValue: brew.rating > 0 ? brew.rating : 0.0)
        _acidity = State(initialValue: brew.acidity > 0 ? Double(brew.acidity) : 0.0)
        _sweetness = State(initialValue: brew.sweetness > 0 ? Double(brew.sweetness) : 0.0)
        _bitterness = State(initialValue: brew.bitterness > 0 ? Double(brew.bitterness) : 0.0)
        _bodyValue = State(initialValue: brew.body > 0 ? Double(brew.body) : 0.0)
        _notes = State(initialValue: brew.notes ?? "")
        _tasteProfileInitialized = State(
            initialValue: brew.acidity > 0 || brew.sweetness > 0 || brew.bitterness > 0 || brew.body > 0
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 28)

                ratingSection
                    .padding(.top, 24)
                    .padding(.horizontal, 20)

                tasteProfileSection
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                notesSection
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                saveButton
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
            }
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(brew.coffeeName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(BrewerColors.cream)
                .lineLimit(2)

            HStack(spacing: 6) {
                Text(brew.coffeeRoasterName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BrewerColors.textSecondary)

                if let date = brew.date {
                    Text("·")
                        .foregroundColor(BrewerColors.textSecondary)
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Star Rating

    private var ratingSection: some View {
        VStack(spacing: 12) {
            HalfStarRating(rating: $rating, starSize: 40, spacing: 10)

            Text(ratingLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(rating > 0 ? BrewerColors.caramel : BrewerColors.placeholder)
                .animation(.easeInOut(duration: 0.15), value: rating)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.cardBackground)
        )
    }

    private var ratingLabel: String {
        switch rating {
        case 0:    return "Tap to rate"
        case 0.5:  return "½ — Poor"
        case 1.0:  return "★ — Poor"
        case 1.5:  return "★½ — Below Average"
        case 2.0:  return "★★ — Below Average"
        case 2.5:  return "★★½ — Average"
        case 3.0:  return "★★★ — Average"
        case 3.5:  return "★★★½ — Good"
        case 4.0:  return "★★★★ — Good"
        case 4.5:  return "★★★★½ — Great"
        case 5.0:  return "★★★★★ — Perfect"
        default:   return String(format: "%.1f", rating)
        }
    }

    // MARK: - Taste Profile

    private var tasteProfileSection: some View {
        VStack(spacing: 0) {
            // Collapsible header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tasteProfileExpanded.toggle()
                    if tasteProfileExpanded && !tasteProfileInitialized {
                        acidity = 5
                        sweetness = 5
                        bitterness = 5
                        bodyValue = 5
                        tasteProfileInitialized = true
                    }
                }
            } label: {
                HStack {
                    Text("Taste Profile")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    Text("(optional)")
                        .font(.system(size: 13))
                        .foregroundColor(BrewerColors.placeholder)
                    Spacer()
                    Image(systemName: tasteProfileExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if tasteProfileExpanded {
                VStack(spacing: 14) {
                    Rectangle()
                        .fill(BrewerColors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, 16)

                    TasteSlider(label: "Acidity", value: $acidity)
                        .padding(.horizontal, 16)
                    TasteSlider(label: "Sweetness", value: $sweetness)
                        .padding(.horizontal, 16)
                    TasteSlider(label: "Bitterness", value: $bitterness)
                        .padding(.horizontal, 16)
                    TasteSlider(label: "Body", value: $bodyValue)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BrewerColors.cardBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(BrewerColors.cream)

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Add tasting notes…")
                        .font(.system(size: 15))
                        .foregroundColor(BrewerColors.placeholder)
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $notes)
                    .frame(minHeight: 80)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .foregroundColor(BrewerColors.textPrimary)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BrewerColors.cardBackground)
            )
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveBrew()
        } label: {
            Text("Save Rating")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(BrewerColors.espresso)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(BrewerColors.caramel)
                )
        }
        .buttonStyle(.plain)
        .disabled(rating == 0)
        .opacity(rating == 0 ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: rating)
    }

    // MARK: - Save Action

    private func saveBrew() {
        brew.rating = rating
        brew.acidity = Int16(acidity.rounded())
        brew.sweetness = Int16(sweetness.rounded())
        brew.bitterness = Int16(bitterness.rounded())
        brew.body = Int16(bodyValue.rounded())
        brew.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        brew.isAssessed = true

        do {
            try viewContext.save()
        } catch {
            print("RatingSheet: failed to save context: \(error)")
        }

        dismiss()
    }
}

// MARK: - Taste Slider

private struct TasteSlider: View {
    let label: String
    @Binding var value: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
                .frame(width: 78, alignment: .leading)

            Slider(value: $value, in: 0...10, step: 1)
                .tint(BrewerColors.caramel)

            Text("\(Int(value))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(BrewerColors.cream)
                .frame(width: 22, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview("Rating Sheet") {
    let context = PersistenceController.preview.container.viewContext
    let brew = context.registeredObjects
        .compactMap { $0 as? Brew }
        .first(where: { !$0.isAssessed }) ?? context.registeredObjects.compactMap { $0 as? Brew }.first!

    RatingSheet(brew: brew)
        .environment(\.managedObjectContext, context)
}
