import SwiftUI

struct GuideView: View {
    @State private var searchText = ""
    private let previewExpandFirstGuideCard = UserDefaults.standard.bool(forKey: "tippy_preview_expand_first_guide_card")

    private var filteredEntries: [GuideEntry] {
        if searchText.isEmpty { return GuideData.entries }
        let search = searchText.lowercased()
        return GuideData.entries.filter { entry in
            entry.title.lowercased().contains(search) ||
            entry.tags.contains(where: { $0.contains(search) }) ||
            entry.text.lowercased().contains(search)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TippySpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: TippySpacing.sm) {
                        Text("REFERENCE")
                            .font(.tippyMono)
                            .foregroundStyle(.tippyTextTertiary)
                            .tracking(1.0)

                        Text("Guide")
                            .font(.tippyTitle)
                            .foregroundStyle(.tippyText)
                        Text("Your pocket tipping reference")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                    }
                    .padding(.top, TippySpacing.sm)

                    // Search
                    HStack(spacing: TippySpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.tippyTextTertiary)
                        TextField("Search (e.g., barber, hotel, movers)", text: $searchText)
                            .font(.callout)
                    }
                    .padding(TippySpacing.md)
                    .tippyCard()

                    // Guide cards
                    if filteredEntries.isEmpty {
                        VStack(spacing: TippySpacing.sm) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundStyle(.tippyTextTertiary)
                            Text("No results")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.tippyText)
                            Text("Try a different search term")
                                .font(.subheadline)
                                .foregroundStyle(.tippyTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TippySpacing.xxl + TippySpacing.sm)
                    } else {
                        LazyVStack(spacing: TippySpacing.sm) {
                            ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                                GuideCard(
                                    entry: entry,
                                    initiallyExpanded: previewExpandFirstGuideCard && index == 0
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, TippySpacing.xl)
                .padding(.bottom, TippySpacing.lg)
            }
            .tippyScreenBackground()
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Guide Card

private struct GuideCard: View {
    let entry: GuideEntry
    @State private var isExpanded: Bool

    init(entry: GuideEntry, initiallyExpanded: Bool = false) {
        self.entry = entry
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: TippySpacing.md) {
                    GuideIcon(name: entry.iconName)
                        .frame(width: TippySpacing.xxl + TippySpacing.xs, height: TippySpacing.xxl + TippySpacing.xs)
                        .foregroundStyle(isExpanded ? .tippyPrimaryTextAccent : .tippyTextSecondary)

                    VStack(alignment: .leading, spacing: TippySpacing.xs) {
                        Text(entry.title)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.tippyText)
                        Text(entry.range)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.tippyPrimaryTextAccent)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tippyTextTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(TippySpacing.base)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: TippySpacing.md) {
                    Text(entry.text)
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                        .lineSpacing(5)

                    // Fallback tip badge
                    HStack(spacing: TippySpacing.sm) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.caption2)
                        Text(entry.fallback)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.tippyPrimaryTextAccent)
                    .padding(.horizontal, TippySpacing.md)
                    .padding(.vertical, TippySpacing.sm)
                    .background(Color.tippyPrimaryTextAccent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: TippyRadius.chip, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: TippyRadius.chip, style: .continuous)
                            .stroke(Color.tippyPrimaryTextAccent.opacity(0.24), lineWidth: 1)
                    )
                }
                .padding(.horizontal, TippySpacing.base)
                .padding(.leading, TippySpacing.xxl + TippySpacing.base + TippySpacing.xs)
                .padding(.bottom, TippySpacing.base)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .tippyCard()
    }
}

// MARK: - Guide Icon

private struct GuideIcon: View {
    let name: String

    var body: some View {
        if let serviceType = ServiceType(rawValue: name) {
            ServiceIcon(type: serviceType, size: 28)
        } else {
            Image(systemName: sfSymbol(for: name))
                .font(.title3)
        }
    }

    private func sfSymbol(for name: String) -> String {
        switch name {
        case "bellhop": return "bell.fill"
        case "coat_check": return "hanger"
        case "grocery_delivery": return "cart"
        case "furniture_delivery": return "sofa"
        case "dog_groomer": return "pawprint"
        case "tour_guide": return "map"
        case "ski_instructor": return "figure.skiing.downhill"
        case "photographer": return "camera"
        case "caterer": return "frying.pan"
        case "dj_band": return "music.note.list"
        case "wedding_vendor": return "heart.circle"
        case "building_staff": return "building.2"
        case "garbage_collector": return "trash"
        case "mail_carrier": return "envelope"
        case "nanny": return "figure.and.child.holdinghands"
        case "house_cleaner": return "sparkles"
        case "personal_trainer": return "figure.run"
        case "music_teacher": return "pianokeys"
        default: return "questionmark.circle"
        }
    }
}

#Preview {
    GuideView()
}
