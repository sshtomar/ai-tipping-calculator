import Foundation

enum TipCoordinator {

    static func calculate(
        amount: Double,
        serviceType: ServiceType,
        tags: Set<ContextTag>,
        freeText: String,
        city: String?,
        state: String?,
        usageLimiter: UsageLimiter
    ) async -> TipResult {
        let hasContext = !tags.isEmpty || !freeText.trimmingCharacters(in: .whitespaces).isEmpty

        // Simple case: no context tags, no free text — use local engine
        guard hasContext else {
            return TipEngine.calculate(
                amount: amount,
                serviceType: serviceType,
                tags: tags,
                freeText: freeText
            )
        }

        // Nuanced case: user added context — route to Claude API
        guard usageLimiter.canUseAI else {
            usageLimiter.showUpgradePrompt = true
            return TipEngine.calculate(
                amount: amount,
                serviceType: serviceType,
                tags: tags,
                freeText: freeText
            )
        }

        do {
            let result = try await ClaudeRecommendationService.recommend(
                amount: amount,
                serviceType: serviceType,
                tags: tags,
                freeText: freeText,
                city: city,
                state: state
            )
            usageLimiter.recordAIUsage()
            return result
        } catch {
            return TipEngine.calculate(
                amount: amount,
                serviceType: serviceType,
                tags: tags,
                freeText: freeText
            )
        }
    }

    static func advise(
        text: String,
        city: String?,
        state: String?,
        usageLimiter: UsageLimiter
    ) async -> TipResult {
        guard usageLimiter.canUseAI else {
            usageLimiter.showUpgradePrompt = true
            return TipEngine.advise(text: text)
        }

        do {
            let result = try await ClaudeRecommendationService.advise(
                text: text,
                city: city,
                state: state
            )
            usageLimiter.recordAIUsage()
            return result
        } catch {
            return TipEngine.advise(text: text)
        }
    }
}
