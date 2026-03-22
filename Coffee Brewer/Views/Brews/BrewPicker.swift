import SwiftUI
import CoreData

// MARK: - Brew Picker

struct BrewPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.date, ascending: false)],
        animation: .none
    )
    private var recentBrews: FetchedResults<Brew>

    private var lastBrew: Brew? { recentBrews.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PageTitleH2("Start Brewing", subtitle: "Choose your starting point")
                    .padding(.bottom, 4)

                // V60
                Button {
                    navigationCoordinator.brewPath.append(BrewEditorRoute.template(.v60))
                } label: {
                    BrewPickerCard(
                        iconName: BrewMethod.v60.iconName,
                        title: "V60",
                        subtitle: "18g · 306ml · 96°C",
                        accentIcon: true
                    )
                }
                .buttonStyle(.plain)

                // Orea V4
                Button {
                    navigationCoordinator.brewPath.append(BrewEditorRoute.template(.oreaV4))
                } label: {
                    BrewPickerCard(
                        iconName: BrewMethod.oreaV4.iconName,
                        title: "Orea V4",
                        subtitle: "18g · 306ml · 96°C",
                        accentIcon: true
                    )
                }
                .buttonStyle(.plain)

                // Last Brew (only shown when brews exist)
                if let brew = lastBrew {
                    Button {
                        navigationCoordinator.brewPath.append(BrewEditorRoute.cloneFromBrew(brew.objectID))
                    } label: {
                        BrewPickerCard(
                            iconName: "history",
                            title: "Last Brew — \(brew.coffeeName)",
                            subtitle: lastBrewSubtitle(brew),
                            accentIcon: false
                        )
                    }
                    .buttonStyle(.plain)

                    // Browse past brews link
                    Button {
                        navigationCoordinator.navigateToHistory()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Browse past brews")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(BrewerColors.caramel)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
    }

    private func lastBrewSubtitle(_ brew: Brew) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: brew.date ?? Date())
        let water = brew.waterAmount > 0 ? "\(brew.waterAmount)ml" : "\(brew.totalStageWater)ml"
        return "\(brew.brewMethodEnum.displayName) · \(water) · \(dateStr)"
    }
}

// MARK: - Brew Picker Card

private struct BrewPickerCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let accentIcon: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            SVGIcon(
                iconName,
                size: 26,
                color: accentIcon ? BrewerColors.caramel : BrewerColors.textSecondary
            )
            .frame(width: 46, height: 46)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        accentIcon
                            ? BrewerColors.caramel.opacity(0.15)
                            : BrewerColors.textSecondary.opacity(0.1)
                    )
            )

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(BrewerColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(BrewerColors.cardBackground)
        .cornerRadius(14)
    }
}

// MARK: - Preview

#Preview {
    GlobalBackground {
        NavigationStack {
            BrewPicker()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
