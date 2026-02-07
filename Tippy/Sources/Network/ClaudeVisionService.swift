import UIKit

struct ReceiptAnalysis {
    var total: Double
    var subtotal: Double?
    var tax: Double?
    var serviceType: ServiceType?
    var numberOfGuests: Int?
    var venueName: String?
}

enum ClaudeVisionError: Error {
    case imageCompressionFailed
    case networkError(Error)
    case httpError(statusCode: Int)
    case noTextContent
    case jsonParsingFailed
    case noTotalFound
}

enum ClaudeVisionService {

    static func analyzeReceipt(image: UIImage) async throws -> ReceiptAnalysis {
        guard let jpeg = image.jpegData(compressionQuality: ClaudeAPIConfig.jpegQuality) else {
            throw ClaudeVisionError.imageCompressionFailed
        }

        let base64 = jpeg.base64EncodedString()

        let body: [String: Any] = [
            "model": ClaudeAPIConfig.model,
            "max_tokens": 512,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64
                            ]
                        ],
                        [
                            "type": "text",
                            "text": """
                            Analyze this receipt image. Return ONLY a JSON object with these fields:
                            - "total": number (the final total amount charged, required)
                            - "subtotal": number or null
                            - "tax": number or null
                            - "serviceType": one of "restaurant","bar","cafe","delivery","rideshare","salon","spa","tattoo","valet","hotel","movers","other" or null
                            - "numberOfGuests": integer or null (look for guest/cover count)
                            - "venueName": string or null
                            Return ONLY valid JSON, no markdown, no explanation.
                            """
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: ClaudeAPIConfig.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ClaudeAPIConfig.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(ClaudeAPIConfig.anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = ClaudeAPIConfig.timeoutSeconds
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            data = responseData
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw ClaudeVisionError.httpError(statusCode: http.statusCode)
            }
        } catch let error as ClaudeVisionError {
            throw error
        } catch {
            throw ClaudeVisionError.networkError(error)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String else {
            throw ClaudeVisionError.noTextContent
        }

        return try parseAnalysis(from: text)
    }

    private static func parseAnalysis(from text: String) throws -> ReceiptAnalysis {
        // Strip markdown code fences if present
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .replacingOccurrences(of: #"^```\w*\n?"#, with: "", options: .regularExpression)
                .replacingOccurrences(of: #"\n?```$"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard let data = cleaned.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ClaudeVisionError.jsonParsingFailed
        }

        guard let total = parsed["total"] as? Double, total > 0 else {
            throw ClaudeVisionError.noTotalFound
        }

        var serviceType: ServiceType?
        if let raw = parsed["serviceType"] as? String {
            serviceType = ServiceType(rawValue: raw)
        }

        return ReceiptAnalysis(
            total: total,
            subtotal: parsed["subtotal"] as? Double,
            tax: parsed["tax"] as? Double,
            serviceType: serviceType,
            numberOfGuests: parsed["numberOfGuests"] as? Int,
            venueName: parsed["venueName"] as? String
        )
    }
}
