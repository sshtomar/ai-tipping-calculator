import Foundation

struct TipEngine {
    private static let baseRates: [ServiceType: Double] = [
        .restaurant: 0.20,
        .bar: 0.20,
        .cafe: 0.18,
        .delivery: 0.18,
        .rideshare: 0.18,
        .salon: 0.20,
        .spa: 0.20,
        .tattoo: 0.20,
        .other: 0.20,
    ]

    private static let flatTips: [ServiceType: Int] = [
        .valet: 5,
        .hotel: 5,
        .movers: 20,
    ]

    static func calculate(
        amount: Double,
        serviceType: ServiceType,
        tags: Set<ContextTag>,
        freeText: String
    ) -> TipResult {
        if let flat = flatTips[serviceType] {
            return flatTipResult(billAmount: amount, flat: flat, serviceType: serviceType, tags: tags)
        }

        let baseRate = baseRates[serviceType] ?? 0.20
        var adjustment: Double = 0

        // Universal tags
        if tags.contains(.outstandingService) { adjustment += 0.04 }
        if tags.contains(.poorService) { adjustment -= 0.05 }
        if tags.contains(.holidaySeason) { adjustment += 0.03 }

        // Restaurant/bar/cafe tags
        if tags.contains(.largeGroup) { adjustment += 0.02 }
        if tags.contains(.takeout) { adjustment -= 0.07 }
        if tags.contains(.buffet) { adjustment -= 0.06 }
        if tags.contains(.dateNight) { adjustment += 0.01 }

        // Service-specific tags
        if tags.contains(.badWeather) { adjustment += 0.03 }
        if tags.contains(.largeOrder) { adjustment += 0.02 }
        if tags.contains(.lateNight) { adjustment += 0.03 }
        if tags.contains(.longRide) { adjustment += 0.02 }
        if tags.contains(.helpedWithBags) { adjustment += 0.02 }
        if tags.contains(.complexStyle) { adjustment += 0.03 }
        if tags.contains(.regularClient) { adjustment += 0.02 }
        if tags.contains(.longSession) { adjustment += 0.02 }
        if tags.contains(.complexDesign) { adjustment += 0.03 }

        let lower = freeText.lowercased()
        if lower.contains("rain") || lower.contains("snow") || lower.contains("storm") || lower.contains("weather") {
            adjustment += 0.04
        }
        if lower.contains("late") || lower.contains("stayed open") || lower.contains("extra") {
            adjustment += 0.03
        }

        var recPct = Int(round((baseRate + adjustment) * 100))

        // Floor: 15% for sit-down even with poor service
        if (serviceType == .restaurant || serviceType == .bar) && recPct < 15 {
            recPct = 15
        }

        // Clamp 10–40%
        recPct = max(10, min(40, recPct))

        let lowerPct = max(10, recPct - 4)
        let higherPct = min(40, recPct + 4)

        var recDollars = max(1, Int(round(amount * Double(recPct) / 100)))
        var lowerDollars = max(1, Int(round(amount * Double(lowerPct) / 100)))
        var higherDollars = max(1, Int(round(amount * Double(higherPct) / 100)))

        // Delivery floor
        if serviceType == .delivery {
            recDollars = max(5, recDollars)
            lowerDollars = max(5, lowerDollars)
            higherDollars = max(5, higherDollars)
        }

        // Round to clean numbers for business dinners
        if tags.contains(.businessDinner) && amount > 100 {
            recDollars = roundToFive(recDollars)
            lowerDollars = roundToFive(lowerDollars)
            higherDollars = roundToFive(higherDollars)
        }

        let explanation = ExplanationGenerator.generate(
            amount: amount,
            serviceType: serviceType,
            tags: tags,
            freeText: freeText,
            percent: recPct,
            tipDollars: recDollars
        )

        return TipResult(
            recommendedDollars: recDollars,
            recommendedPercent: recPct,
            lowerDollars: lowerDollars,
            lowerPercent: lowerPct,
            higherDollars: higherDollars,
            higherPercent: higherPct,
            explanation: explanation,
            totalWithTip: amount + Double(recDollars),
            billAmount: amount
        )
    }

    static func advise(text: String) -> TipResult {
        let lower = text.lowercased()

        if lower.contains("barber") || lower.contains("hair") {
            let price = extractPrice(from: lower) ?? 40
            if lower.contains("holiday") {
                return TipResult(
                    rangeText: "$\(price)–\(Int(Double(price) * 1.5))",
                    explanation: "Holiday tip for your barber: the cost of one visit is the classic move. If you've been going a while, the higher end says \"I appreciate you.\""
                )
            }
            return TipResult(
                rangeText: "$\(Int(Double(price) * 0.2))–\(Int(Double(price) * 0.25))",
                explanation: "20–25% of the usual cut price is standard for barbers. They remember who tips well."
            )
        }

        if lower.contains("doorman") || lower.contains("building") || lower.contains("super") {
            if lower.contains("nyc") || lower.contains("new york") || lower.contains("manhattan") {
                return TipResult(rangeText: "$100–150", explanation: "Standard holiday range for a NYC doorman. If they handle your packages and always remember your name, lean toward $150.")
            }
            return TipResult(rangeText: "$50–100", explanation: "Holiday tip for building staff depends on how much they do for you. $50 is solid; $100 if they go above and beyond.")
        }

        if lower.contains("nanny") || lower.contains("babysit") {
            return TipResult(rangeText: "One week's pay", explanation: "The standard holiday tip for a nanny or regular babysitter is the equivalent of one week's pay. It's a big number, but it reflects the trust involved.")
        }

        if lower.contains("cleaner") || lower.contains("housekeeper") || lower.contains("cleaning") {
            return TipResult(rangeText: "One session's pay", explanation: "Holiday tip for your house cleaner: the cost of one cleaning session is standard. They take care of your space — this says you notice.")
        }

        if lower.contains("mail") || lower.contains("postal") || lower.contains("carrier") {
            return TipResult(rangeText: "$20–25", explanation: "USPS carriers can accept gifts up to $20 in value per occasion. A gift card to a coffee shop is the classic move.")
        }

        if lower.contains("garbage") || lower.contains("trash") || lower.contains("sanitation") {
            return TipResult(rangeText: "$20–30", explanation: "Holiday tip for garbage collectors: $20–30 each is the norm. Cash in an envelope taped to the bin works great.")
        }

        if lower.contains("teacher") || lower.contains("tutor") || lower.contains("music lesson") {
            return TipResult(rangeText: "$25–50", explanation: "A gift card or cash in the $25–50 range is a thoughtful holiday gesture for a teacher or tutor. It doesn't have to be huge — it's the thought.")
        }

        if lower.contains("trainer") || lower.contains("gym") || lower.contains("fitness") {
            return TipResult(rangeText: "One session's cost", explanation: "Holiday tip for a personal trainer: the cost of one session is standard. They keep you accountable — return the favor.")
        }

        if lower.contains("dog") || lower.contains("pet") || lower.contains("groomer") {
            return TipResult(rangeText: "One session's cost", explanation: "Holiday tip for a pet groomer or dog walker: one session's cost. They deal with your pet's chaos with a smile.")
        }

        return TipResult(rangeText: "$20–50", explanation: "Without more details, that's a reasonable range for most personal service tips. Adjust up if they go above and beyond.")
    }

    private static func flatTipResult(billAmount: Double, flat: Int, serviceType: ServiceType, tags: Set<ContextTag>) -> TipResult {
        var adjusted = flat

        // Universal tag adjustments
        if tags.contains(.outstandingService) { adjusted += 3 }
        if tags.contains(.poorService) { adjusted -= 2 }
        if tags.contains(.holidaySeason) { adjusted += 2 }

        // Service-specific dollar adjustments
        if tags.contains(.badWeather) { adjusted += 2 }
        if tags.contains(.specialEvent) { adjusted += 2 }
        if tags.contains(.multiNight) { adjusted += 2 }
        if tags.contains(.extraRequests) { adjusted += 2 }
        if tags.contains(.stairs) { adjusted += 5 }
        if tags.contains(.heavyItems) { adjusted += 5 }
        if tags.contains(.longMove) { adjusted += 5 }

        adjusted = max(1, adjusted)

        let lower = max(1, adjusted - 2)
        let higher = adjusted + 3

        let explanations: [ServiceType: String] = [
            .valet: "$\(adjusted) is standard for valet. Straightforward — hand it over with the ticket.",
            .hotel: "$\(adjusted) per night is the standard for hotel housekeeping. Leave it on the pillow with a note so they know it's for them.",
            .movers: "$\(adjusted) per mover is the sweet spot. If they handled stairs or heavy furniture, lean higher.",
        ]

        let pct = billAmount > 0 ? Int(round(Double(adjusted) / billAmount * 100)) : 0
        let lowerPct = billAmount > 0 ? Int(round(Double(lower) / billAmount * 100)) : 0
        let higherPct = billAmount > 0 ? Int(round(Double(higher) / billAmount * 100)) : 0

        return TipResult(
            recommendedDollars: adjusted,
            recommendedPercent: pct,
            lowerDollars: lower,
            lowerPercent: lowerPct,
            higherDollars: higher,
            higherPercent: higherPct,
            explanation: explanations[serviceType] ?? "$\(adjusted) is the standard flat tip for this service.",
            totalWithTip: billAmount + Double(adjusted),
            billAmount: billAmount
        )
    }

    private static func roundToFive(_ value: Int) -> Int {
        Int(round(Double(value) / 5.0)) * 5
    }

    private static func extractPrice(from text: String) -> Int? {
        let pattern = #"\$?(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return Int(text[range])
    }
}
