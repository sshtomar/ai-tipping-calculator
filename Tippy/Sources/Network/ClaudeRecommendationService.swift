import Foundation

enum ClaudeRecommendationError: Error {
    case noAPIKey
    case networkError(Error)
    case httpError(statusCode: Int)
    case noTextContent
    case jsonParsingFailed
}

enum ClaudeRecommendationService {

    private static let systemPrompt = """
    You are Tippy, a tipping advisor. Your philosophy:
    - Tip generously but not absurdly. Default to 20% for sit-down restaurants.
    - Consider context: service quality, occasion, weather, group size.
    - Be warm, concise, and opinionated. One short sentence for explanation.
    - For flat-tip services (valet, hotel, movers), recommend dollar amounts not percentages.
    - Location matters: NYC/SF tips trend higher than rural areas.
    - Always respond with ONLY a JSON object, no markdown.
    """

    static func recommend(
        amount: Double,
        serviceType: ServiceType,
        tags: Set<ContextTag>,
        freeText: String,
        city: String?,
        state: String?
    ) async throws -> TipResult {
        let tagNames = tags.map(\.rawValue).joined(separator: ", ")
        let locationText = [city, state].compactMap { $0 }.joined(separator: ", ")

        let userMessage = """
        Bill amount: $\(String(format: "%.2f", amount))
        Service type: \(serviceType.rawValue)
        Context tags: \(tagNames.isEmpty ? "none" : tagNames)
        Free text: \(freeText.isEmpty ? "none" : freeText)
        Location: \(locationText.isEmpty ? "unknown" : locationText)

        Return ONLY a JSON object:
        {
          "recommended_tip_dollars": integer,
          "recommended_tip_percent": integer,
          "lower_tip_dollars": integer,
          "lower_tip_percent": integer,
          "higher_tip_dollars": integer,
          "higher_tip_percent": integer,
          "explanation": "short string",
          "total_with_tip": number
        }
        """

        return try await callAPI(systemPrompt: systemPrompt, userMessage: userMessage, billAmount: amount)
    }

    static func advise(
        text: String,
        city: String?,
        state: String?
    ) async throws -> TipResult {
        let locationText = [city, state].compactMap { $0 }.joined(separator: ", ")

        let userMessage = """
        Situation: \(text)
        Location: \(locationText.isEmpty ? "unknown" : locationText)

        Return ONLY a JSON object:
        {
          "range_text": "string like $20-50 or One week's pay",
          "explanation": "short helpful explanation"
        }
        """

        return try await callAdviseAPI(systemPrompt: systemPrompt, userMessage: userMessage)
    }

    // MARK: - Private

    private static func callAPI(systemPrompt: String, userMessage: String, billAmount: Double) async throws -> TipResult {
        let data = try await makeRequest(systemPrompt: systemPrompt, userMessage: userMessage)
        return try parseRecommendation(from: data, billAmount: billAmount)
    }

    private static func callAdviseAPI(systemPrompt: String, userMessage: String) async throws -> TipResult {
        let data = try await makeRequest(systemPrompt: systemPrompt, userMessage: userMessage)
        return try parseAdvice(from: data)
    }

    private static func makeRequest(systemPrompt: String, userMessage: String) async throws -> Data {
        guard let apiKey = ClaudeAPIConfig.apiKey else {
            throw ClaudeRecommendationError.noAPIKey
        }

        let body: [String: Any] = [
            "model": ClaudeAPIConfig.model,
            "max_tokens": 512,
            "system": systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": userMessage
                ]
            ]
        ]

        var request = URLRequest(url: ClaudeAPIConfig.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(ClaudeAPIConfig.anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 5
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let responseData: Data
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            responseData = data
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw ClaudeRecommendationError.httpError(statusCode: http.statusCode)
            }
        } catch let error as ClaudeRecommendationError {
            throw error
        } catch {
            throw ClaudeRecommendationError.networkError(error)
        }

        return responseData
    }

    private static func extractText(from data: Data) throws -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String else {
            throw ClaudeRecommendationError.noTextContent
        }

        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .replacingOccurrences(of: #"^```\w*\n?"#, with: "", options: .regularExpression)
                .replacingOccurrences(of: #"\n?```$"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return cleaned
    }

    private static func parseRecommendation(from data: Data, billAmount: Double) throws -> TipResult {
        let text = try extractText(from: data)

        guard let jsonData = text.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw ClaudeRecommendationError.jsonParsingFailed
        }

        guard let recDollars = parsed["recommended_tip_dollars"] as? Int,
              let recPercent = parsed["recommended_tip_percent"] as? Int else {
            throw ClaudeRecommendationError.jsonParsingFailed
        }

        let lowerDollars = parsed["lower_tip_dollars"] as? Int ?? max(1, recDollars - 3)
        let lowerPercent = parsed["lower_tip_percent"] as? Int ?? max(10, recPercent - 4)
        let higherDollars = parsed["higher_tip_dollars"] as? Int ?? recDollars + 3
        let higherPercent = parsed["higher_tip_percent"] as? Int ?? min(40, recPercent + 4)
        let explanation = parsed["explanation"] as? String ?? "AI-powered recommendation based on your context."
        let totalWithTip = parsed["total_with_tip"] as? Double ?? (billAmount + Double(recDollars))

        // Clamp percentages 10-40%
        let clampedRecPct = max(10, min(40, recPercent))
        let clampedLowerPct = max(10, min(40, lowerPercent))
        let clampedHigherPct = max(10, min(40, higherPercent))

        return TipResult(
            recommendedDollars: max(1, recDollars),
            recommendedPercent: clampedRecPct,
            lowerDollars: max(1, lowerDollars),
            lowerPercent: clampedLowerPct,
            higherDollars: max(1, higherDollars),
            higherPercent: clampedHigherPct,
            explanation: explanation,
            totalWithTip: totalWithTip,
            billAmount: billAmount,
            isOffline: false
        )
    }

    private static func parseAdvice(from data: Data) throws -> TipResult {
        let text = try extractText(from: data)

        guard let jsonData = text.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw ClaudeRecommendationError.jsonParsingFailed
        }

        let rangeText = parsed["range_text"] as? String ?? "$20–50"
        let explanation = parsed["explanation"] as? String ?? "AI-powered advice based on your situation."

        return TipResult(rangeText: rangeText, explanation: explanation, isOffline: false)
    }
}
