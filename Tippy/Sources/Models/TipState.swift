import SwiftUI

@Observable
final class TipState {
    var amount: String = ""
    var serviceType: ServiceType?
    var contextTags: Set<ContextTag> = []
    var freeText: String = ""
    var noBillText: String = ""

    var result: TipResult?
    var selectedOption: TipOption = .recommended
    var splitCount: Int = 1
    var isDiscreet: Bool = false
    var feedbackGiven: String?

    // Navigation
    var currentScreen: Screen = .entry

    enum Screen {
        case entry, noBill, context, loading, result
    }

    var parsedAmount: Double? {
        Double(amount)
    }

    var canProceed: Bool {
        guard let value = parsedAmount, value > 0 else { return false }
        return serviceType != nil
    }

    var currentTipDollars: Int {
        guard let result, !result.isRange else { return 0 }
        switch selectedOption {
        case .lower: return result.lowerDollars
        case .recommended: return result.recommendedDollars
        case .higher: return result.higherDollars
        }
    }

    var currentTotal: Double {
        guard let result, !result.isRange else { return 0 }
        return result.billAmount + Double(currentTipDollars)
    }

    var perPersonAmount: Double {
        guard splitCount > 0 else { return currentTotal }
        return currentTotal / Double(splitCount)
    }

    func reset() {
        amount = ""
        serviceType = nil
        contextTags = []
        freeText = ""
        noBillText = ""
        result = nil
        selectedOption = .recommended
        splitCount = 1
        isDiscreet = false
        feedbackGiven = nil
        currentScreen = .entry
    }
}
