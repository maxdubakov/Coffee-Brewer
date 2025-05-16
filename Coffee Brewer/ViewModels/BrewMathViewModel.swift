import SwiftUI

class BrewMathViewModel: ObservableObject {
    @Published var grams: Int16 {
        didSet {
            guard !isUpdating else { return }
            updateWater()
        }
    }

    @Published var ratio: Double {
        didSet {
            guard !isUpdating else { return }
            updateWater()
        }
    }

    @Published var water: Int16 {
        didSet {
            guard !isUpdating else { return }
            updateRatio()
        }
    }

    private var isUpdating = false

    init(grams: Int16, ratio: Double, water: Int16) {
        self.grams = grams
        self.ratio = ratio
        self.water = water
    }

    private func updateWater() {
        isUpdating = true
        water = Int16((Double(grams) * ratio).rounded())
        isUpdating = false
    }

    private func updateRatio() {
        guard grams != 0 else { return }
        isUpdating = true
        let rawRatio = Double(water) / Double(grams)
        ratio = (rawRatio * 100).rounded() / 100
        isUpdating = false
    }
}
