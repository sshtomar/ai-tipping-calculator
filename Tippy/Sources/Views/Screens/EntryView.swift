import SwiftUI
import AVFoundation
import UIKit

struct EntryView: View {
    @Bindable var state: TipState
    @FocusState private var amountFocused: Bool
    @State private var showMore = false
    @State private var showCamera = false
    @State private var isScanning = false
    @State private var cameraPermission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var didRunAutomationHooks = false

    private static let primary: [ServiceType] = [.restaurant, .bar, .cafe, .delivery, .rideshare, .salon]
    private static let secondary: [ServiceType] = [.spa, .tattoo, .valet, .hotel, .movers, .other]

    @AppStorage("hasSeenTippy") private var hasSeenTippy = false
    private var hasCameraHardware: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: TippySpacing.xl) {
                    VStack(alignment: .leading, spacing: TippySpacing.sm) {
                        Text("TIP CALCULATOR")
                            .font(.tippyMono)
                            .foregroundStyle(.tippyTextTertiary)
                            .tracking(1.0)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tippy")
                                .font(.tippyTitle)
                                .foregroundStyle(.tippyText)

                            Text("Know what to tip, always.")
                                .font(.subheadline)
                                .foregroundStyle(.tippyTextSecondary)
                        }
                    }
                    .padding(.top, TippySpacing.sm)

                    // Receipt scan
                    receiptScanSection()

                    // Divider
                    HStack(spacing: TippySpacing.md) {
                        Rectangle().fill(Color.tippyBorder).frame(height: 0.5)
                        Text("or enter manually")
                            .font(.caption)
                            .foregroundStyle(.tippyTextTertiary)
                        Rectangle().fill(Color.tippyBorder).frame(height: 0.5)
                    }

                    // Bill total
                    billTotalSection()

                    // Service type
                    serviceTypeSection()

                    // No bill link
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            state.currentScreen = .noBill
                        }
                    } label: {
                        HStack(spacing: TippySpacing.sm) {
                            Text("No bill? Just need advice")
                            Image(systemName: "arrow.right")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.subheadline)
                        .foregroundStyle(.tippyTextSecondary)
                        .padding(.horizontal, TippySpacing.base)
                        .padding(.vertical, TippySpacing.sm)
                        .background(Color.tippySurface.opacity(0.8))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.tippyBorder, lineWidth: 1))
                    }
                }
                .padding(.horizontal, TippySpacing.xl)
                .padding(.bottom, TippySpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)

            // Sticky bottom
            VStack(spacing: 0) {
                Divider()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state.currentScreen = .context
                    }
                } label: {
                    HStack {
                        Text("Next")
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.medium))
                    }
                    .tippyPrimaryButton(enabled: state.canProceed)
                }
                .disabled(!state.canProceed)
                .padding(.horizontal, TippySpacing.xl)
                .padding(.top, TippySpacing.md)
                .padding(.bottom, TippySpacing.sm)
            }
            .background(.ultraThinMaterial)
        }
        .onAppear {
            cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
            runAutomationHooksIfNeeded()
        }
        .onChange(of: state.serviceType) { _, newValue in
            if let newValue, Self.secondary.contains(newValue) {
                showMore = true
            }
        }
    }

    // MARK: - Receipt Scan

    @ViewBuilder
    private func receiptScanSection() -> some View {
        if !hasCameraHardware {
            Button {
                amountFocused = false
                showCamera = true
            } label: {
                HStack(spacing: TippySpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.tippyPrimaryLight)
                            .frame(width: TippySpacing.xxl + TippySpacing.xs, height: TippySpacing.xxl + TippySpacing.xs)
                        Image(systemName: "photo.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tippyPrimary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Choose receipt photo")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.tippyText)
                        Text("Camera unavailable on this device")
                            .font(.caption)
                            .foregroundStyle(.tippyTextTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tippyTextTertiary)
                }
                .padding(.horizontal, TippySpacing.base)
                .padding(.vertical, TippySpacing.md)
                .background(
                    LinearGradient(
                        colors: [
                            Color.tippyYellow.opacity(0.16),
                            Color.tippySky.opacity(0.08),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                        .stroke(Color.tippyBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    scanReceipt(image)
                }
                .ignoresSafeArea()
            }
        } else if cameraPermission == .denied || cameraPermission == .restricted {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: TippySpacing.sm) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.body)
                    Text("Enable camera to scan receipts")
                        .font(.subheadline)
                }
                .tippySecondaryButton()
            }
            .buttonStyle(.plain)
        } else {
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
                HStack(spacing: TippySpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.tippyPrimaryLight)
                            .frame(width: TippySpacing.xxl + TippySpacing.xs, height: TippySpacing.xxl + TippySpacing.xs)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tippyPrimary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scan your receipt")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.tippyText)
                        Text("Auto-detect bill total")
                            .font(.caption)
                            .foregroundStyle(.tippyTextTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tippyTextTertiary)
                }
                .padding(.horizontal, TippySpacing.base)
                .padding(.vertical, TippySpacing.md)
                .background(
                    LinearGradient(
                        colors: [
                            Color.tippyYellow.opacity(0.16),
                            Color.tippySky.opacity(0.08),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                        .stroke(Color.tippyBorder, lineWidth: 1)
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
    }

    // MARK: - Bill Total

    @ViewBuilder
    private func billTotalSection() -> some View {
        VStack(alignment: .leading, spacing: TippySpacing.md) {
            Text("BILL TOTAL")
                .font(.tippyLabel)
                .foregroundStyle(.tippyTextSecondary)
                .tracking(1.0)

            ZStack {
                HStack(alignment: .firstTextBaseline, spacing: TippySpacing.xs) {
                    Text("$")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.tippyTextTertiary)

                    TextField("0.00", text: $state.amount)
                        .font(.tippyMoneyLarge)
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
                .padding(.horizontal, TippySpacing.base)
                .padding(.vertical, TippySpacing.base)
                .opacity(isScanning ? 0.3 : 1)

                if isScanning {
                    VStack(spacing: TippySpacing.sm) {
                        ProgressView()
                        Text("Reading receipt...")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.tippyTextSecondary)
                        Text("This may take a few seconds")
                            .font(.caption)
                            .foregroundStyle(.tippyTextTertiary)
                    }
                }
            }
            .tippyCard(isActive: amountFocused)

            // Quick amounts — bordered capsules
            if state.amount.isEmpty && !isScanning {
                HStack(spacing: TippySpacing.sm) {
                    ForEach([20, 50, 100], id: \.self) { amount in
                        Button {
                            state.amount = "\(amount)"
                            amountFocused = false
                        } label: {
                            Text("$\(amount)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.tippyText)
                                .padding(.horizontal, TippySpacing.base)
                                .padding(.vertical, TippySpacing.sm)
                                .overlay(Capsule().stroke(Color.tippyBorder, lineWidth: 1))
                        }
                    }

                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Service Type

    @ViewBuilder
    private func serviceTypeSection() -> some View {
        VStack(alignment: .leading, spacing: TippySpacing.md) {
            HStack {
                Text("SERVICE TYPE")
                    .font(.tippyLabel)
                    .foregroundStyle(.tippyTextSecondary)
                    .tracking(1.0)

                Spacer()

                if let type = state.serviceType {
                    Text(type.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tippyPrimary)
                        .transition(.opacity)
                }
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: TippySpacing.sm),
                GridItem(.flexible(), spacing: TippySpacing.sm),
                GridItem(.flexible(), spacing: TippySpacing.sm),
            ], spacing: TippySpacing.sm) {
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
                    HStack(spacing: TippySpacing.sm) {
                        Text("More services")
                        Image(systemName: "chevron.down")
                            .font(.caption2.bold())
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tippyTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TippySpacing.sm)
                }
            }
        }
    }

    // MARK: - Receipt Scanning

    private func scanReceipt(_ image: UIImage) {
        isScanning = true
#if DEBUG
        UserDefaults.standard.set("scan-started", forKey: "tippy_automation_last_status")
#endif
        Task {
            if let result = await ReceiptScanner.scan(image: image) {
#if DEBUG
                UserDefaults.standard.set("scan-success:\(result.amount)", forKey: "tippy_automation_last_status")
#endif
                if result.autoGratuityIncluded == true {
                    state.autoGratuityAmount = result.autoGratuityAmount
                }

                if result.source == .onDeviceOCR && result.allAmounts.count > 1 {
                    state.pendingScanResult = result
                    isScanning = false
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state.currentScreen = .receiptConfirmation
                    }
                    return
                }

                let formatted = result.amount.truncatingRemainder(dividingBy: 1) == 0
                    ? String(format: "%.0f", result.amount)
                    : String(format: "%.2f", result.amount)
                state.amount = formatted

                if state.serviceType == nil {
                    state.serviceType = result.detectedServiceType ?? .restaurant
                }

                if let guests = result.numberOfGuests, guests >= 6 {
                    state.contextTags.insert(.largeGroup)
                }
            } else {
#if DEBUG
                UserDefaults.standard.set("scan-failed-no-result", forKey: "tippy_automation_last_status")
#endif
            }
            isScanning = false
        }
    }

    private func runAutomationHooksIfNeeded() {
#if DEBUG
        guard !didRunAutomationHooks else { return }
        didRunAutomationHooks = true

        let defaults = UserDefaults.standard
        defaults.set("hook-started", forKey: "tippy_automation_last_status")

        if defaults.bool(forKey: "tippy_automation_open_scan_sheet") {
            defaults.removeObject(forKey: "tippy_automation_open_scan_sheet")
            amountFocused = false
            showCamera = true
            defaults.set("opened-scan-sheet", forKey: "tippy_automation_last_status")
        }

        if let configuredPath = defaults.string(forKey: "tippy_automation_autoscan_receipt_path") {
            defaults.removeObject(forKey: "tippy_automation_autoscan_receipt_path")
            if let resolvedPath = resolveAutomationImagePath(configuredPath),
               let image = UIImage(contentsOfFile: resolvedPath) {
                amountFocused = false
                defaults.set("loaded-image:\(resolvedPath)", forKey: "tippy_automation_last_status")
                scanReceipt(image)
            } else {
                defaults.set("failed-to-load-image", forKey: "tippy_automation_last_status")
            }
        }
#endif
    }

#if DEBUG
    private func resolveAutomationImagePath(_ configuredPath: String) -> String? {
        let fileManager = FileManager.default
        var candidates: [String] = []

        // Absolute path
        candidates.append(configuredPath)

        // Relative path under app Documents
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            candidates.append((documentsPath as NSString).appendingPathComponent(configuredPath))

            // If a host/container path was configured, keep just the file name.
            let fileName = URL(fileURLWithPath: configuredPath).lastPathComponent
            if !fileName.isEmpty {
                candidates.append((documentsPath as NSString).appendingPathComponent(fileName))
            }
        }

        return candidates.first(where: { fileManager.fileExists(atPath: $0) })
    }
#endif
}

// MARK: - Service Type Button

private struct ServiceTypeButton: View {
    let type: ServiceType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: TippySpacing.sm) {
                ServiceIcon(
                    type: type,
                    size: 24,
                    color: isSelected ? .tippyPrimary : .tippyTextSecondary
                )

                Text(type.displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .tippyText : .tippyTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TippySpacing.md)
            .padding(.horizontal, TippySpacing.xs)
            .background(isSelected ? Color.tippyPrimaryLight : Color.tippySurface)
            .tippyCard(isActive: isSelected)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    EntryView(state: TipState())
}
