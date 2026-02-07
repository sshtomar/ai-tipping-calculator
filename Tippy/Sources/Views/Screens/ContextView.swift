import SwiftUI

struct ContextView: View {
    @Bindable var state: TipState
    var locationService: LocationService
    var usageLimiter: UsageLimiter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TippySpacing.xl) {
                // Back button
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state.currentScreen = .entry
                    }
                } label: {
                    HStack(spacing: TippySpacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Back")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                }

                // Header
                VStack(alignment: .leading, spacing: TippySpacing.sm) {
                    Text("OPTIONAL INPUT")
                        .font(.tippyMono)
                        .foregroundStyle(.tippyTextTertiary)
                        .tracking(1.0)

                    Text("Any context?")
                        .font(.tippyTitle)
                        .foregroundStyle(.tippyText)

                    Text("Optional — but it helps dial in the tip.")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                }

                // Context chips
                VStack(alignment: .leading, spacing: TippySpacing.sm) {
                    HStack {
                        Text("SITUATION")
                            .font(.tippyLabel)
                            .foregroundStyle(.tippyTextSecondary)
                            .tracking(1.0)

                        Spacer()

                        if !state.contextTags.isEmpty {
                            Text("\(state.contextTags.count) selected")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tippyPrimary)
                        }
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: TippySpacing.sm),
                        GridItem(.flexible(), spacing: TippySpacing.sm),
                    ], spacing: TippySpacing.sm) {
                        ForEach(ContextTag.tags(for: state.serviceType ?? .other)) { tag in
                            ContextChip(
                                tag: tag,
                                isSelected: state.contextTags.contains(tag)
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if state.contextTags.contains(tag) {
                                        state.contextTags.remove(tag)
                                    } else {
                                        state.contextTags.insert(tag)
                                    }
                                }
                            }
                        }
                    }
                }

                // Free text
                VStack(alignment: .leading, spacing: TippySpacing.sm) {
                    Text("ANYTHING ELSE?")
                        .font(.tippyLabel)
                        .foregroundStyle(.tippyTextSecondary)
                        .tracking(1.0)

                    TextField("e.g., it's raining, they stayed open late", text: $state.freeText)
                        .font(.callout)
                        .padding(TippySpacing.base)
                        .tippyCard()
                }

                // Calculate button
                Button {
                    calculate()
                } label: {
                    HStack {
                        HStack(spacing: TippySpacing.sm) {
                            Image(systemName: "sparkles")
                            Text("Get My Tip")
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.medium))
                    }
                    .tippyPrimaryButton()
                }

                // Skip link
                Button {
                    calculate()
                } label: {
                    HStack(spacing: TippySpacing.sm) {
                        Text("Skip — just calculate")
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.semibold))
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.tippyTextSecondary)
                    .padding(.horizontal, TippySpacing.base)
                    .padding(.vertical, TippySpacing.sm)
                    .background(Color.tippySurface.opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.tippyBorder, lineWidth: 1))
                }
            }
            .padding(.horizontal, TippySpacing.xl)
            .padding(.top, TippySpacing.base)
            .padding(.bottom, TippySpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            let valid = Set(ContextTag.tags(for: state.serviceType ?? .other))
            state.contextTags = state.contextTags.intersection(valid)
        }
    }

    private func calculate() {
        guard let amount = state.parsedAmount,
              let serviceType = state.serviceType else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            state.currentScreen = .loading
        }

        let startTime = Date()

        Task {
            let result = await TipCoordinator.calculate(
                amount: amount,
                serviceType: serviceType,
                tags: state.contextTags,
                freeText: state.freeText,
                city: locationService.city,
                state: locationService.state,
                usageLimiter: usageLimiter
            )

            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 0.5 {
                try? await Task.sleep(for: .seconds(0.5 - elapsed))
            }

            state.result = result
            state.selectedOption = .recommended
            state.splitCount = 1
            state.isDiscreet = false
            state.feedbackGiven = nil

            withAnimation(.easeInOut(duration: 0.3)) {
                state.currentScreen = .result
            }
        }
    }
}

// MARK: - Context Chip

struct ContextChip: View {
    let tag: ContextTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TippySpacing.sm) {
                Image(systemName: tag.iconName)
                    .font(.system(size: 12))
                    .frame(width: TippySpacing.base)
                Text(tag.displayName)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, TippySpacing.md)
            .padding(.vertical, TippySpacing.md)
            .foregroundStyle(isSelected ? .tippyPrimary : .tippyText)
            .background(isSelected ? Color.tippyPrimaryLight : Color.tippySurface)
            .tippyCard(isActive: isSelected)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

#Preview {
    let state = TipState()
    state.amount = "142"
    state.serviceType = .restaurant
    return ContextView(state: state, locationService: LocationService(), usageLimiter: UsageLimiter())
}
