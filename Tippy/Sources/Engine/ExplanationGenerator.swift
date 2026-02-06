import Foundation

struct ExplanationGenerator {
    static func generate(
        amount: Double,
        serviceType: ServiceType,
        tags: Set<ContextTag>,
        freeText: String,
        percent: Int,
        tipDollars: Int
    ) -> String {
        let lowerFT = freeText.lowercased()
        var parts: [String] = []
        let bill = Int(amount)

        switch serviceType {
        case .restaurant:
            if tags.contains(.dateNight) {
                parts.append("Date night — you want the tip to be invisible. $\(tipDollars) on a $\(bill) bill is generous without making a thing of it.")
            } else if tags.contains(.businessDinner) {
                parts.append("Business dinner — the tip should be a non-event. $\(tipDollars) keeps it clean and professional.")
            } else if tags.contains(.poorService) {
                parts.append("Service wasn't great, and that's frustrating. In the US, servers earn most of their income from tips regardless of the shift they had. \(percent)% says \"I noticed\" without being punitive.")
            } else if tags.contains(.outstandingService) {
                parts.append("Outstanding service deserves to be recognized. $\(tipDollars) says \"we noticed and we appreciate you.\"")
            } else if tags.contains(.largeGroup) {
                parts.append("Large group — double-check the bill for auto-gratuity before adding more. If there's none, $\(tipDollars) (\(percent)%) handles it. Serving big tables is a workout.")
            } else {
                parts.append("$\(tipDollars) on this bill is solid — generous without overthinking it.")
            }

        case .bar:
            if amount < 20 {
                parts.append("On a small bar tab, a couple bucks per drink is the move. $\(tipDollars) keeps it friendly.")
            } else {
                parts.append("$\(tipDollars) (\(percent)%) on the bar tab. Your bartender remembers who tips well.")
            }

        case .cafe:
            parts.append("Counter tips run a little higher on percentage because the dollar amounts are small. $\(tipDollars) on this is solid.")

        case .delivery:
            if tipDollars <= 5 {
                parts.append("Even on a small order, $5 is the floor for delivery. They brought it to your door.")
            } else {
                parts.append("$\(tipDollars) for delivery is right. They brought it to your door — that's worth something.")
            }

        case .rideshare:
            parts.append("$\(tipDollars) for the ride. Drivers don't see the tip until after they rate you, so this is purely about doing right.")

        case .salon:
            parts.append("$\(tipDollars) (\(percent)%) for salon/barber is spot on. This is skilled personal service — tip like it.")

        case .spa:
            parts.append("$\(tipDollars) (\(percent)%) for spa or massage. Standard, generous, and well-earned.")

        case .tattoo:
            parts.append("$\(tipDollars) (\(percent)%) for your artist. Tattoo artists are tipped like other skilled personal service providers. If you love the work, this says so.")

        case .valet, .hotel, .movers:
            break // Handled by flat tip logic

        case .other:
            parts.append("$\(tipDollars) (\(percent)%) is the right call here. Generous without going overboard.")
        }

        // Weather addon
        if lowerFT.contains("rain") || lowerFT.contains("snow") || lowerFT.contains("storm") {
            parts.append("Weather bumps it — they came out in the rain for you.")
        }

        // Holiday addon
        if tags.contains(.holidaySeason) && !(parts.first?.contains("holiday") ?? false) {
            parts.append("Holiday season means rounding up. 'Tis the season to be generous.")
        }

        // Takeout note
        if tags.contains(.takeout) {
            parts.append("For takeout, a lighter tip is fine — no table service involved.")
        }

        // Big bill note
        if amount > 1000 {
            parts.append("On a bill this size, the percentage still applies — don't overthink it.")
        }

        return parts.joined(separator: " ")
    }
}
