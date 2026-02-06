import SwiftUI

struct GuideView: View {
    @State private var searchText = ""

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
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tippy")
                            .font(.custom("Georgia", size: 32))
                            .foregroundStyle(.tippyText)
                        Text("Your pocket tipping reference")
                            .font(.system(size: 15))
                            .foregroundStyle(.tippyTextSecondary)
                    }
                    .padding(.top, 8)

                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.tippyTextTertiary)
                        TextField("Search (e.g., barber, hotel, movers)", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(14)
                    .background(Color.tippySurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.tippyBorder, lineWidth: 2)
                    )

                    // Guide cards
                    if filteredEntries.isEmpty {
                        VStack(spacing: 8) {
                            Text("No results")
                                .font(.system(size: 16, weight: .medium))
                            Text("Try a different search term")
                                .font(.system(size: 14))
                                .foregroundStyle(.tippyTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredEntries) { entry in
                                GuideCard(entry: entry)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.tippyBackground)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Guide Card

private struct GuideCard: View {
    let entry: GuideEntry
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    GuideIcon(name: entry.iconName)
                        .frame(width: 36, height: 36)
                        .foregroundStyle(isExpanded ? .tippyPrimaryDark : .tippyTextSecondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.tippyText)
                        Text(entry.range)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tippyPrimaryDark)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tippyTextTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(entry.text)
                        .font(.system(size: 15))
                        .foregroundStyle(.tippyTextSecondary)
                        .lineSpacing(4)

                    Text(entry.fallback)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.tippyPrimaryDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.tippyPrimaryLight)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.leading, 50)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.tippySurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isExpanded ? Color.tippyPrimary : Color.tippyBorder, lineWidth: 1.5)
        )
    }
}

// MARK: - Guide Icon (reuses service icons where possible, SF Symbols otherwise)

private struct GuideIcon: View {
    let name: String

    var body: some View {
        if let serviceType = ServiceType(rawValue: name) {
            ServiceIcon(type: serviceType, size: 28)
        } else {
            Image(systemName: sfSymbol(for: name))
                .font(.system(size: 20))
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
