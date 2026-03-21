import SwiftUI

struct RoasterDetailSheet: View {
    let roaster: Roaster
    @Environment(\.dismiss) private var dismiss

    private var sortedCoffees: [Coffee] {
        (roaster.coffees as? Set<Coffee> ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    private var lastBrewDate: Date? {
        sortedCoffees
            .flatMap { ($0.brews as? Set<Brew> ?? []) }
            .compactMap { $0.date }
            .max()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main roaster card
            VStack(spacing: 0) {
                // Header section with flag and name
                VStack(spacing: 20) {
                    // Top: Flag and name horizontally aligned
                    HStack(spacing: 12) {
                        if let country = roaster.country {
                            Text(country.flag ?? "")
                                .font(.system(size: 32))
                        }

                        Text(roaster.name ?? "Unknown Roaster")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(BrewerColors.cream)
                            .lineLimit(2)

                        Spacer()
                    }

                    // Bottom: Country, founded year, and last brew info aligned left
                    HStack(spacing: 28) {
                        if let country = roaster.country {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Country")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                Text(country.name ?? "")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }

                        if roaster.foundedYear > 0 {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Founded")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                Text("\(roaster.foundedYear)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }

                        if let lastBrew = lastBrewDate {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Brew")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                Text(lastBrew.timeAgoDescription())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }

                        Spacer()
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
                                    BrewerColors.mocha.opacity(0.15)
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

            // Recent coffees section
            if !sortedCoffees.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Coffees")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedCoffees.prefix(4)) { coffee in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(BrewerColors.caramel)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 2)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(coffee.name ?? "Untitled")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(BrewerColors.cream)
                                            .lineLimit(1)

                                        if let process = coffee.process, !process.isEmpty {
                                            Text(process)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(BrewerColors.textSecondary)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                }
                .padding(.top, 24)
            }

            Spacer()
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }
}
