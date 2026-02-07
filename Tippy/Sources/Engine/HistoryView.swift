import SwiftUI

struct HistoryView: View {
    @State private var history: [[String: String]] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TippySpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: TippySpacing.sm) {
                        Text("FEEDBACK LOG")
                            .font(.tippyMono)
                            .foregroundStyle(.tippyTextTertiary)
                            .tracking(1.0)

                        Text("History")
                            .font(.tippyTitle)
                            .foregroundStyle(.tippyText)
                        Text("Your tipping feedback")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                    }
                    .padding(.top, TippySpacing.sm)

                    // Stats Card
                    if !history.isEmpty {
                        VStack(alignment: .leading, spacing: TippySpacing.md) {
                            Text("STATS")
                                .font(.tippyLabel)
                                .foregroundStyle(.tippyTextSecondary)
                                .tracking(1.0)

                            HStack(spacing: 0) {
                                StatItem(value: "\(history.count)", label: "Tips")
                                Spacer()
                                StatItem(value: "\(feedbackCount("just_right"))", label: "Just Right")
                                Spacer()
                                StatItem(value: "\(feedbackCount("too_low"))", label: "Too Low")
                                Spacer()
                                StatItem(value: "\(feedbackCount("too_high"))", label: "Too High")
                            }
                        }
                        .padding(TippySpacing.base)
                        .tippyCard()
                    }

                    // History List
                    if history.isEmpty {
                        VStack(spacing: TippySpacing.md) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(.title2))
                                .foregroundStyle(.tippyTextTertiary)
                            Text("No history yet")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.tippyText)
                            Text("Your tipping feedback will appear here")
                                .font(.subheadline)
                                .foregroundStyle(.tippyTextTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TippySpacing.xxl + TippySpacing.xxl)
                    } else {
                        VStack(alignment: .leading, spacing: TippySpacing.sm) {
                            Text("RECENT")
                                .font(.tippyLabel)
                                .foregroundStyle(.tippyTextSecondary)
                                .tracking(1.0)

                            LazyVStack(spacing: TippySpacing.sm) {
                                ForEach(history.reversed().prefix(20), id: \.self) { entry in
                                    HistoryCard(entry: entry)
                                }
                            }
                        }
                    }

                    // Clear
                    if !history.isEmpty {
                        Button(role: .destructive) {
                            clearHistory()
                        } label: {
                            Text("Clear History")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, TippySpacing.xl)
                                .padding(.vertical, TippySpacing.base)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [.tippyPrimary, .tippyPrimaryDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, TippySpacing.xl)
                .padding(.bottom, TippySpacing.lg)
            }
            .tippyScreenBackground()
        }
        .onAppear {
            loadHistory()
        }
    }

    private func loadHistory() {
        history = UserDefaults.standard.array(forKey: "tippy_feedback") as? [[String: String]] ?? []
    }

    private func clearHistory() {
        UserDefaults.standard.removeObject(forKey: "tippy_feedback")
        history = []
    }

    private func feedbackCount(_ type: String) -> Int {
        history.filter { $0["type"] == type }.count
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: TippySpacing.xs) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.tippyText)
            Text(label)
                .font(.caption)
                .foregroundStyle(.tippyTextSecondary)
        }
    }
}

// MARK: - History Card

private struct HistoryCard: View {
    let entry: [String: String]

    var body: some View {
        HStack(spacing: TippySpacing.md) {
            feedbackIcon
                .frame(width: TippySpacing.xxl, height: TippySpacing.xxl)

            VStack(alignment: .leading, spacing: 2) {
                Text(serviceLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.tippyText)
                Text(dateLabel)
                    .font(.caption)
                    .foregroundStyle(.tippyTextSecondary)
            }

            Spacer()
        }
        .padding(TippySpacing.md)
        .tippyCard()
    }

    @ViewBuilder
    private var feedbackIcon: some View {
        let type = entry["type"] ?? ""
        let (icon, color) = iconForType(type)

        Image(systemName: icon)
            .font(.callout)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(0.08))
            .clipShape(Circle())
    }

    private func iconForType(_ type: String) -> (String, Color) {
        switch type {
        case "just_right": return ("checkmark.circle.fill", .tippyGreen)
        case "too_low": return ("arrow.down.circle.fill", .red)
        case "too_high": return ("arrow.up.circle.fill", .tippyYellow)
        default: return ("circle.fill", .tippyTextTertiary)
        }
    }

    private var serviceLabel: String {
        guard let service = entry["service"] else { return "Unknown" }
        if service == "advice" { return "Tipping advice" }
        return ServiceType(rawValue: service)?.displayName ?? service.capitalized
    }

    private var dateLabel: String {
        guard let dateString = entry["date"],
              let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Unknown date"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    HistoryView()
}
