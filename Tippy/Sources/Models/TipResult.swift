import Foundation

struct TipResult: Equatable {
    let recommendedDollars: Int
    let recommendedPercent: Int
    let lowerDollars: Int
    let lowerPercent: Int
    let higherDollars: Int
    let higherPercent: Int
    let explanation: String
    let totalWithTip: Double
    let billAmount: Double
    let isRange: Bool
    let rangeText: String?
    let isOffline: Bool

    init(
        recommendedDollars: Int,
        recommendedPercent: Int,
        lowerDollars: Int,
        lowerPercent: Int,
        higherDollars: Int,
        higherPercent: Int,
        explanation: String,
        totalWithTip: Double,
        billAmount: Double,
        isOffline: Bool = true
    ) {
        self.recommendedDollars = recommendedDollars
        self.recommendedPercent = recommendedPercent
        self.lowerDollars = lowerDollars
        self.lowerPercent = lowerPercent
        self.higherDollars = higherDollars
        self.higherPercent = higherPercent
        self.explanation = explanation
        self.totalWithTip = totalWithTip
        self.billAmount = billAmount
        self.isRange = false
        self.rangeText = nil
        self.isOffline = isOffline
    }

    init(rangeText: String, explanation: String, isOffline: Bool = true) {
        self.recommendedDollars = 0
        self.recommendedPercent = 0
        self.lowerDollars = 0
        self.lowerPercent = 0
        self.higherDollars = 0
        self.higherPercent = 0
        self.explanation = explanation
        self.totalWithTip = 0
        self.billAmount = 0
        self.isRange = true
        self.rangeText = rangeText
        self.isOffline = isOffline
    }
}

enum TipOption {
    case lower, recommended, higher
}
