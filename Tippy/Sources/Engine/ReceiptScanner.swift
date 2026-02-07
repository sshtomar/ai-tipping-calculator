import Vision
import UIKit

struct ReceiptScanner {

    enum ScanSource {
        case claudeVision
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
        var source: ScanSource = .onDeviceOCR
    }

    static func scan(image: UIImage) async -> ScanResult? {
        // Try Claude Vision first for richer data
        if let result = try? await scanWithClaude(image: image) {
            return result
        }
        // Fall back to on-device OCR
        return await scanWithOCR(image: image)
    }

    // MARK: - Claude Vision

    private static func scanWithClaude(image: UIImage) async throws -> ScanResult {
        let analysis = try await ClaudeVisionService.analyzeReceipt(image: image)
        return ScanResult(
            amount: analysis.total,
            allAmounts: [analysis.total],
            subtotal: analysis.subtotal,
            tax: analysis.tax,
            detectedServiceType: analysis.serviceType,
            numberOfGuests: analysis.numberOfGuests,
            venueName: analysis.venueName,
            source: .claudeVision
        )
    }

    // MARK: - On-Device OCR (existing logic, unchanged)

    private static func scanWithOCR(image: UIImage) async -> ScanResult? {
        guard let cgImage = image.cgImage else { return nil }

        let amounts = await recognizeAmounts(in: cgImage)
        guard !amounts.isEmpty else { return nil }

        return ScanResult(amount: amounts[0], allAmounts: amounts)
    }

    private static func recognizeAmounts(in image: CGImage) async -> [Double] {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let amounts = extractAmounts(from: lines)
                continuation.resume(returning: amounts)
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
