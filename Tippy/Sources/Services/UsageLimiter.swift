import Foundation

@Observable
final class UsageLimiter {
    private static let usageKey = "tippy_ai_usage"
    private static let dateKey = "tippy_ai_usage_date"
    private static let dailyLimit = 3

    var aiUsagesToday: Int
    var isPro: Bool = false
    var showUpgradePrompt: Bool = false

    var canUseAI: Bool {
        isPro || aiUsagesToday < Self.dailyLimit
    }

    init() {
        aiUsagesToday = UserDefaults.standard.integer(forKey: Self.usageKey)
        checkAndResetIfNewDay()
    }

    func recordAIUsage() {
        aiUsagesToday += 1
        UserDefaults.standard.set(aiUsagesToday, forKey: Self.usageKey)
        let today = Self.todayString()
        UserDefaults.standard.set(today, forKey: Self.dateKey)
    }

    func checkAndResetIfNewDay() {
        let stored = UserDefaults.standard.string(forKey: Self.dateKey) ?? ""
        let today = Self.todayString()
        if stored != today {
            aiUsagesToday = 0
            showUpgradePrompt = false
            UserDefaults.standard.set(0, forKey: Self.usageKey)
            UserDefaults.standard.set(today, forKey: Self.dateKey)
        }
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
