import Foundation

@Observable
final class UsageLimiter {
    private static let lifetimeKey = "tippy_ai_usage"
    private static let dailyKey = "tippy_ai_daily_usage"
    private static let dailyDateKey = "tippy_ai_daily_date"

    private static let onboardingLimit = 10
    private static let dailyLimit = 1

    var aiUsagesTotal: Int
    var aiUsagesToday: Int
    var isPro: Bool = false
    var showUpgradePrompt: Bool = false

    /// Whether the user is still in the onboarding phase (first 10 tips).
    var isOnboarding: Bool {
        aiUsagesTotal < Self.onboardingLimit
    }

    var canUseAI: Bool {
        if isPro { return true }
        if isOnboarding { return true }
        return aiUsagesToday < Self.dailyLimit
    }

    var remaining: Int {
        if isPro { return .max }
        if isOnboarding {
            return Self.onboardingLimit - aiUsagesTotal
        }
        return max(0, Self.dailyLimit - aiUsagesToday)
    }

    init() {
        aiUsagesTotal = UserDefaults.standard.integer(forKey: Self.lifetimeKey)
        aiUsagesToday = UserDefaults.standard.integer(forKey: Self.dailyKey)
    }

    func recordAIUsage() {
        aiUsagesTotal += 1
        UserDefaults.standard.set(aiUsagesTotal, forKey: Self.lifetimeKey)

        aiUsagesToday += 1
        UserDefaults.standard.set(aiUsagesToday, forKey: Self.dailyKey)
    }

    func checkAndResetIfNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let lastDate = UserDefaults.standard.string(forKey: Self.dailyDateKey)

        if lastDate != today {
            aiUsagesToday = 0
            UserDefaults.standard.set(0, forKey: Self.dailyKey)
            UserDefaults.standard.set(today, forKey: Self.dailyDateKey)
        }
    }
}
