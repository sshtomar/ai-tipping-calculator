import SwiftUI

struct EntryView: View {
    @Bindable var state: TipState
    @FocusState private var amountFocused: Bool
    @State private var showMore = false
    @State private var showCamera = false
    @State private var isScanning = false

    private static let primary: [ServiceType] = [.restaurant, .bar, .cafe, .delivery, .rideshare, .salon]
    private static let secondary: [ServiceType] = [.spa, .tattoo, .valet, .hotel, .movers, .other]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Tippy")
                        .font(.custom("Georgia", size: 32))
                        .foregroundStyle(.tippyText)
                        .padding(.top, 8)

                    Button {
                        amountFocused = false
                        showCamera = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("Scan your receipt")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.tippyPrimaryDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tippyPrimaryLight)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.tippyPrimary, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraView { image in
                            scanReceipt(image)
                        }
                        .ignoresSafeArea()
                    }

                    HStack(spacing: 12) {
                        Rectangle().fill(Color.tippyBorder).frame(height: 1)
                        Text("or enter manually")
                            .font(.system(size: 13))
                            .foregroundStyle(.tippyTextTertiary)
                        Rectangle().fill(Color.tippyBorder).frame(height: 1)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("BILL TOTAL")
                            .font(.tippyLabel)
                            .foregroundStyle(.tippyTextSecondary)
                            .tracking(0.8)

                        ZStack {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("$")
                                    .font(.custom("Georgia", size: 36))
                                    .foregroundStyle(.tippyTextTertiary)

                                TextField("0.00", text: $state.amount)
                                    .font(.custom("Georgia", size: 42))
                                    .foregroundStyle(.tippyText)
                                    .keyboardType(.decimalPad)
                                    .focused($amountFocused)
                            }
                            .padding(16)
                            .opacity(isScanning ? 0.3 : 1)

                            if isScanning {
                                HStack(spacing: 10) {
                                    ProgressView()
                                    Text("Reading receipt…")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.tippyTextSecondary)
                                }
                            }
                        }
                        .background(Color.tippySurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(amountFocused ? Color.tippyPrimary : Color.tippyBorder, lineWidth: 2)
                        )
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("WHAT KIND OF SERVICE?")
                            .font(.tippyLabel)
                            .foregroundStyle(.tippyTextSecondary)
                            .tracking(0.8)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                        ], spacing: 10) {
                            ForEach(Self.primary) { type in
                                ServiceTypeButton(
                                    type: type,
                                    isSelected: state.serviceType == type
                                ) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        state.serviceType = type
                                        amountFocused = false
                                    }
                                }
                            }

                            if showMore {
                                ForEach(Self.secondary) { type in
                                    ServiceTypeButton(
                                        type: type,
                                        isSelected: state.serviceType == type
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            state.serviceType = type
                                            amountFocused = false
                                        }
                                    }
                                }
                            }
                        }

                        if !showMore {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showMore = true
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("More services")
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .font(.system(size: 14))
                                .foregroundStyle(.tippyTextTertiary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                        }
                    }

                    Button {
                        withAnimation {
                            state.currentScreen = .noBill
                        }
                    } label: {
                        Text("No bill? Just need advice →")
                            .font(.system(size: 15))
                            .foregroundStyle(.tippyTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)

            // Sticky bottom button
            VStack(spacing: 0) {
                Divider()
                Button {
                    withAnimation {
                        state.currentScreen = .context
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(state.canProceed ? Color.tippyPrimary : Color.tippyBorder)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!state.canProceed)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .background(Color.tippyBackground)
        }
        .onChange(of: state.serviceType) { _, newValue in
            if let newValue, Self.secondary.contains(newValue) {
                showMore = true
            }
        }
    }

    private func scanReceipt(_ image: UIImage) {
        isScanning = true
        Task {
            if let result = await ReceiptScanner.scan(image: image) {
                let formatted = result.amount.truncatingRemainder(dividingBy: 1) == 0
                    ? String(format: "%.0f", result.amount)
                    : String(format: "%.2f", result.amount)
                state.amount = formatted

                // Use Claude-detected service type, or fall back to restaurant
                if state.serviceType == nil {
                    state.serviceType = result.detectedServiceType ?? .restaurant
                }

                // Auto-tag large group if Claude detected 6+ guests
                if let guests = result.numberOfGuests, guests >= 6 {
                    state.contextTags.insert(.largeGroup)
                }
            }
            isScanning = false
        }
    }
}

// MARK: - Service Type Button

private struct ServiceTypeButton: View {
    let type: ServiceType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ServiceIcon(
                    type: type,
                    size: 28,
                    color: isSelected ? .tippyPrimaryDark : .tippyTextSecondary
                )

                Text(type.displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .tippyPrimaryDark : .tippyTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 4)
            .background(isSelected ? Color.tippyPrimaryLight : Color.tippySurface)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.tippyPrimary : Color.tippyBorder, lineWidth: isSelected ? 2 : 1.5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    EntryView(state: TipState())
}
