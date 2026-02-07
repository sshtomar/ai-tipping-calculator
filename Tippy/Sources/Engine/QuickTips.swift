import Foundation

struct QuickTip {
    static let tips = [
        "In the U.S., restaurant servers often make $2-3/hour before tips.",
        "Tipping on the pre-tax amount is perfectly acceptable.",
        "For exceptional service during bad weather, add 3-5% extra.",
        "Cash tips ensure the server gets 100% immediately.",
        "Many European countries include service charges—tipping is optional.",
        "For takeout, 10% is a thoughtful gesture for packaging labor.",
        "Tip on the original price if you used a discount or coupon.",
        "Hotel housekeeping tip: leave it daily, not just at checkout.",
        "Bad service? Tip 15% minimum and talk to a manager.",
        "Split evenly or by item? Consider who ordered drinks vs. entrees.",
    ]
    
    static var random: String {
        tips.randomElement() ?? tips[0]
    }
}
