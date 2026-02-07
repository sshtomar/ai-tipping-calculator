import SwiftUI

struct ContextView: View {
    @Bindable var state: TipState
    var locationService: LocationService
    var usageLimiter: UsageLimiter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Back button
                Button {
                    withAnimation {
                        state.currentScreen = .entry
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Back")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Any context?")
                        .font(.custom("Georgia", size: 28, relativeTo: .title))
                        .foregroundStyle(.tippyText)

                    Text("Totally optional — but it helps dial in the tip.")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                    
                    // Show selected count
                    if !state.contextTags.isEmpty {
                        Text("\(state.contextTags.count) selected")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.tippyPrimaryDark)
                            .padding(.top, 2)
                    }
                }

                // Context chips
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                ], spacing: 10) {
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

                // Free text
                VStack(alignment: .leading, spacing: 8) {
                    Text("ANYTHING ELSE?")
                        .font(.tippyLabel)
                        .foregroundStyle(.tippyTextSecondary)
                        .tracking(0.8)

                    TextField("e.g., it's raining, they stayed open late", text: $state.freeText)
                        .font(.callout)
                        .padding(14)
                        .background(Color.tippySurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.tippyBorder, lineWidth: 2)
                        )
                }
                .padding(.top, 4)

                // Calculate button
                Button {
                    calculate()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Get My Tip")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.tippyText)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.top, 4)

                // Skip link
                Button {
                    calculate()
                } label: {
                    Text("Skip — just calculate →")
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 80)
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

        withAnimation {
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

            // Ensure minimum 0.5s loading display
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 0.5 {
                try? await Task.sleep(for: .seconds(0.5 - elapsed))
            }

            state.result = result
            state.selectedOption = .recommended
            state.splitCount = 1
            state.isDiscreet = false
            state.feedbackGiven = nil

            withAnimation(.easeInOut(duration: 0.4)) {
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
            HStack(spacing: 6) {
                Image(systemName: tag.iconName)
                    .font(.footnote)
                Text(tag.displayName)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.tippyPrimaryLight : Color.tippySurface)
            .foregroundStyle(isSelected ? .tippyPrimaryDark : .tippyText)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.tippyPrimary : Color.tippyBorder, lineWidth: 1.5)
            )
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
