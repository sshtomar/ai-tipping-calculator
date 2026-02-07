import SwiftUI
import AVFoundation

struct EntryView: View {
    @Bindable var state: TipState
    @FocusState private var amountFocused: Bool
    @State private var showMore = false
    @State private var showCamera = false
    @State private var isScanning = false
    @State private var cameraPermission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    private static let primary: [ServiceType] = [.restaurant, .bar, .cafe, .delivery, .rideshare, .salon]
    private static let secondary: [ServiceType] = [.spa, .tattoo, .valet, .hotel, .movers, .other]

    @AppStorage("hasSeenTippy") private var hasSeenTippy = false
    @State private var showQuickTip = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack(alignment: .top) {
                        Text("Tippy")
                            .font(.custom("Georgia", size: 32, relativeTo: .largeTitle))
                            .foregroundStyle(.tippyText)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        // Quick tip of the day
                        Button {
                            showQuickTip = true
                        } label: {
                            Image(systemName: "lightbulb.fill")
                                .font(.callout)
                                .foregroundStyle(.tippyYellow)
                                .padding(8)
                                .background(Color.tippyYellow.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .alert("Quick Tip", isPresented: $showQuickTip) {
                        Button("Got it", role: .cancel) {}
                    } message: {
                        Text(QuickTip.random)
                    }

                    if cameraPermission == .denied || cameraPermission == .restricted {
                        // Camera denied — show settings banner
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.badge.ellipsis")
                                    .font(.subheadline)
                                Text("Enable camera in Settings to scan receipts")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.tippyTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.tippySurfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Camera available or not yet determined
                        Button {
                            amountFocused = false
                            if cameraPermission == .notDetermined {
                                AVCaptureDevice.requestAccess(for: .video) { granted in
                                    DispatchQueue.main.async {
                                        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
                                        if granted {
                                            showCamera = true
                                        }
                                    }
                                }
                            } else {
                                showCamera = true
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.body)
                                Text("Scan your receipt")
                                    .font(.body.weight(.semibold))
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
                    }

                    HStack(spacing: 12) {
                        Rectangle().fill(Color.tippyBorder).frame(height: 1)
                        Text("or enter manually")
                            .font(.footnote)
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
                                    .font(.custom("Georgia", size: 36, relativeTo: .largeTitle))
                                    .foregroundStyle(.tippyTextTertiary)

                                TextField("0.00", text: $state.amount)
                                    .font(.custom("Georgia", size: 42, relativeTo: .largeTitle))
                                    .foregroundStyle(.tippyText)
                                    .keyboardType(.decimalPad)
                                    .focused($amountFocused)
                                    .accessibilityLabel("Bill total amount")
                                    .accessibilityHint("Enter the bill amount in dollars")
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                amountFocused = false
                                            }
                                            .tint(.tippyPrimary)
                                        }
                                    }
                            }
                            .padding(16)
                            .opacity(isScanning ? 0.3 : 1)

                            if isScanning {
                                VStack(spacing: 8) {
                                    ProgressView()
                                    Text("Reading receipt…")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.tippyTextSecondary)
                                    Text("This may take a few seconds")
                                        .font(.caption)
                                        .foregroundStyle(.tippyTextTertiary)
                                }
                            }
                        }
                        .background(Color.tippySurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(amountFocused ? Color.tippyPrimary : Color.tippyBorder, lineWidth: 2)
                        )
                        
                        // Quick amount buttons
                        if state.amount.isEmpty && !isScanning {
                            HStack(spacing: 8) {
                                Text("Quick:")
                                    .font(.footnote)
                                    .foregroundStyle(.tippyTextTertiary)
                                
                                ForEach([20, 50, 100], id: \.self) { amount in
                                    Button {
                                        state.amount = "\(amount)"
                                        amountFocused = false
                                    } label: {
                                        Text("$\(amount)")
                                            .font(.footnote.weight(.medium))
                                            .foregroundStyle(.tippyPrimaryDark)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.tippyPrimaryLight)
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
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
                                        .font(.caption2.bold())
                                }
                                .font(.subheadline)
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
                            .font(.subheadline)
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
                            .font(.subheadline.bold())
                    }
                    .font(.body.weight(.semibold))
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
        .onAppear {
            cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
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
                // Propagate auto-gratuity
                if result.autoGratuityIncluded == true {
                    state.autoGratuityAmount = result.autoGratuityAmount
                }

                // If on-device OCR with multiple amounts, show confirmation
                if result.source == .onDeviceOCR && result.allAmounts.count > 1 {
                    state.pendingScanResult = result
                    isScanning = false
                    withAnimation {
                        state.currentScreen = .receiptConfirmation
                    }
                    return
                }

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
                    .font(.caption.weight(isSelected ? .semibold : .medium))
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
