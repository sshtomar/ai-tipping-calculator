import Vision
import UIKit

struct ReceiptScanner {

    enum ScanSource {
        case claudeVision
        case claudeText
        case onDeviceOCR
    }

    struct ScanResult {
        let amount: Double
        let allAmounts: [Double]
        var subtotal: Double?
        var tax: Double?
        var detectedServiceType: ServiceType?
        var numberOfGuests: Int?
        var venueName: String?
        var autoGratuityIncluded: Bool?
        var autoGratuityAmount: Double?
        var source: ScanSource = .onDeviceOCR
    }

    static func scan(image: UIImage) async -> ScanResult? {
        guard let cgImage = image.cgImage else { return nil }

        // Step 1: On-device OCR to get text lines
        let lines = await recognizeTextLines(in: cgImage)

        // Step 2: Send text to Claude Haiku for structured extraction
        if !lines.isEmpty,
           let result = try? await scanWithClaudeText(lines: lines) {
            return result
        }

        // Step 3: Fallback to heuristic amount extraction from OCR lines
        if !lines.isEmpty {
            let amounts = extractAmounts(from: lines)
            if !amounts.isEmpty {
                return ScanResult(amount: amounts[0], allAmounts: amounts)
            }
        }

        return nil
    }

    // MARK: - Claude Text Analysis (Haiku, text-only)

    private static func scanWithClaudeText(lines: [String]) async throws -> ScanResult {
        let analysis = try await ClaudeVisionService.analyzeReceiptText(lines: lines)
        return ScanResult(
            amount: analysis.total,
            allAmounts: [analysis.total],
            subtotal: analysis.subtotal,
            tax: analysis.tax,
            detectedServiceType: analysis.serviceType,
            numberOfGuests: analysis.numberOfGuests,
            venueName: analysis.venueName,
            autoGratuityIncluded: analysis.autoGratuityIncluded,
            autoGratuityAmount: analysis.autoGratuityAmount,
            source: .claudeText
        )
    }

    // MARK: - On-Device OCR

    private static func recognizeTextLines(in image: CGImage) async -> [String] {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    private static func extractAmounts(from lines: [String]) -> [Double] {
        let dollarPattern = #"\$?\s?(\d{1,6}(?:[.,]\d{1,2})?)"#
        let totalKeywords = ["total", "amount due", "balance due", "grand total", "amount", "due"]

        guard let regex = try? NSRegularExpression(pattern: dollarPattern, options: .caseInsensitive) else {
            return []
        }

        var totalLineAmounts: [Double] = []
        var allAmounts: [Double] = []

        for line in lines {
            let lower = line.lowercased()
            let nsLine = line as NSString
            let matches = regex.matches(in: line, range: NSRange(location: 0, length: nsLine.length))

            for match in matches {
                guard let range = Range(match.range(at: 1), in: line) else { continue }
                let raw = line[range].replacingOccurrences(of: ",", with: "")
                guard let value = Double(raw), value > 0, value < 10000 else { continue }

                allAmounts.append(value)

                let isTotalLine = totalKeywords.contains(where: { lower.contains($0) })
                if isTotalLine {
                    totalLineAmounts.append(value)
                }
            }
        }

        // Prefer the largest "total" line amount, then fall back to largest overall
        if let best = totalLineAmounts.max() {
            return [best] + allAmounts.filter { $0 != best }.sorted(by: >)
        }
        return allAmounts.sorted(by: >)
    }
}
