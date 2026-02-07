import SwiftUI

struct HistoryView: View {
    @State private var history: [[String: String]] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tippy")
                            .font(.custom("Georgia", size: 32, relativeTo: .largeTitle))
                            .foregroundStyle(.tippyText)
                        Text("Your tipping history and preferences")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                    }
                    .padding(.top, 8)
                    
                    // Stats Card
                    if !history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STATS")
                                .font(.tippyLabel)
                                .foregroundStyle(.tippyTextSecondary)
                                .tracking(0.8)
                            
                            HStack(spacing: 20) {
                                StatItem(
                                    value: "\(history.count)",
                                    label: "Tips"
                                )
                                StatItem(
                                    value: "\(feedbackCount("just_right"))",
                                    label: "Just Right"
                                )
                                StatItem(
                                    value: "\(feedbackCount("too_low"))",
                                    label: "Too Low"
                                )
                                StatItem(
                                    value: "\(feedbackCount("too_high"))",
                                    label: "Too High"
                                )
                            }
                        }
                        .padding(16)
                        .tippyCard()
                    }
                    
                    // History List
                    if history.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(.largeTitle))
                                .foregroundStyle(.tippyTextTertiary)
                            Text("No history yet")
                                .font(.callout.weight(.medium))
                            Text("Your tipping feedback will appear here")
                                .font(.subheadline)
                                .foregroundStyle(.tippyTextTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("RECENT ACTIVITY")
                                .font(.tippyLabel)
                                .foregroundStyle(.tippyTextSecondary)
                                .tracking(0.8)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(history.reversed().prefix(20), id: \.self) { entry in
                                    HistoryCard(entry: entry)
                                }
                            }
                        }
                    }
                    
                    // Clear history button
                    if !history.isEmpty {
                        Button(role: .destructive) {
                            clearHistory()
                        } label: {
                            Text("Clear History")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .tippyCard()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.tippyBackground)
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
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Georgia", size: 24, relativeTo: .title2))
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
        HStack(spacing: 12) {
            feedbackIcon
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(serviceLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.tippyText)
                Text(dateLabel)
                    .font(.footnote)
                    .foregroundStyle(.tippyTextSecondary)
            }
            
            Spacer()
        }
        .padding(12)
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
            .background(color.opacity(0.1))
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
