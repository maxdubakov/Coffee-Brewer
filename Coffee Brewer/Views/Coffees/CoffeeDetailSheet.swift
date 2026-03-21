import SwiftUI

struct CoffeeDetailSheet: View {
    let coffee: Coffee
    @Environment(\.dismiss) private var dismiss

    private var sortedBrews: [Brew] {
        coffee.brewsArray
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main coffee card
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    // Top: flag and name horizontally aligned
                    HStack(spacing: 12) {
                        if let flag = coffee.country?.flag {
                            Text(flag)
                                .font(.system(size: 32))
                        }

                        Text(coffee.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(BrewerColors.cream)
                            .lineLimit(2)

                        Spacer()
                    }

                    // Bottom: roaster, origin, process info aligned left
                    HStack(spacing: 28) {
                        if let roasterName = coffee.roaster?.name {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Roaster")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                Text(roasterName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                                    .lineLimit(1)
                            }
                        }

                        if let country = coffee.country {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Origin")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                Text("\(country.flag ?? "") \(country.name ?? "")".trimmingCharacters(in: .whitespaces))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }

                        if let process = coffee.process, !process.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Process")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))

                                Text(process)
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

            // Recent brews section
            if !sortedBrews.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brews")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedBrews.prefix(4)) { brew in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(BrewerColors.caramel)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 2)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(brew.name ?? "Untitled Brew")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(BrewerColors.cream)
                                            .lineLimit(1)

                                        if let date = brew.date {
                                            Text(date.timeAgoDescription())
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(BrewerColors.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    if brew.rating > 0 {
                                        Text("\(brew.rating)★")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(BrewerColors.caramel)
                                    }
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
