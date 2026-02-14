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
    @State private var primaryServices: [ServiceType] = defaultPrimary
    @State private var secondaryServices: [ServiceType] = defaultSecondary

    private static let defaultPrimary: [ServiceType] = [.restaurant, .bar, .cafe, .delivery, .rideshare, .salon]
    private static let defaultSecondary: [ServiceType] = [.spa, .tattoo, .valet, .hotel, .movers, .other]

    @AppStorage("hasSeenTippy") private var hasSeenTippy = false
    private var hasCameraHardware: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tippy")
                            .font(.tippyTitle)
                            .foregroundStyle(.tippyText)
                        Text("Know what to tip, always.")
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextSecondary)
                    }
                    .padding(.top, TippySpacing.sm)
                    .padding(.bottom, TippySpacing.xl)

                    // Inputs group: bill + service type (tighter spacing)
                    VStack(alignment: .leading, spacing: TippySpacing.base) {
                        billTotalSection()
                        serviceTypeSection()
                    }

                    Spacer(minLength: TippySpacing.xxxl)

                    // Actions group
                    VStack(alignment: .leading, spacing: TippySpacing.base) {
                        // No bill link — plain text, no pill
                        Button {
                            withAnimation(TippySpring.gentle) {
                                state.currentScreen = .noBill
                            }
                        } label: {
                            HStack(spacing: TippySpacing.xs) {
                                Text("No bill? Just need advice")
                                Image(systemName: "arrow.right")
                                    .font(.caption2.weight(.semibold))
                            }
                            .font(.subheadline)
                            .foregroundStyle(.tippyTextTertiary)
                        }

                        // Next button
                        Button {
                            withAnimation(TippySpring.gentle) {
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
                    }
                }
                .padding(.horizontal, TippySpacing.xl)
                .padding(.bottom, TippySpacing.xl)
                .frame(minHeight: geo.size.height)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
            runAutomationHooksIfNeeded()
            snapshotServiceGrid()
            if state.amount.isEmpty {
                amountFocused = true
            }
        }
        .onChange(of: state.serviceType) { _, newValue in
            if let newValue, secondaryServices.contains(newValue) {
                showMore = true
            }
        }
    }

    // MARK: - Scan Button

    @ViewBuilder
    private func scanButton() -> some View {
        if !isScanning {
            if cameraPermission == .denied || cameraPermission == .restricted {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    scanButtonIcon(systemName: "camera.badge.ellipsis")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Enable camera access")
            } else if hasCameraHardware {
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
                    scanButtonIcon(systemName: "camera.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Scan receipt")
            } else {
                Button {
                    amountFocused = false
                    showCamera = true
                } label: {
                    scanButtonIcon(systemName: "photo.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose receipt photo")
            }
        }
    }

    private func scanButtonIcon(systemName: String) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.tippyPrimaryLight)
                    .frame(width: 36, height: 36)
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tippyPrimary)
            }
            Text("Scan")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.tippyPrimary)
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
                HStack(spacing: TippySpacing.xs) {
                    Text("$")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.tippyTextSecondary)

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

                    Spacer(minLength: 0)

                    scanButton()
                }
                .padding(.horizontal, TippySpacing.base)
                .padding(.vertical, TippySpacing.lg)
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
            .background(Color.tippySurface.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TippyRadius.card, style: .continuous)
                    .stroke(
                        amountFocused ? Color.tippyPrimary.opacity(0.85) : Color.tippyBorder,
                        lineWidth: amountFocused ? 1.5 : 1
                    )
            )

}
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                scanReceipt(image)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Service Type

    @ViewBuilder
    private func serviceTypeSection() -> some View {
        VStack(alignment: .leading, spacing: TippySpacing.md) {
            Text("SERVICE TYPE")
                .font(.tippyLabel)
                .foregroundStyle(.tippyTextSecondary)
                .tracking(1.0)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: TippySpacing.sm),
                GridItem(.flexible(), spacing: TippySpacing.sm),
                GridItem(.flexible(), spacing: TippySpacing.sm),
            ], spacing: TippySpacing.sm) {
                ForEach(primaryServices) { type in
                    ServiceTypeButton(
                        type: type,
                        isSelected: state.serviceType == type
                    ) {
                        withAnimation(TippySpring.snappy) {
                            state.serviceType = type
                            amountFocused = false
                        }
                        Self.recordUsage(for: type)
                    }
                }

                if showMore {
                    ForEach(secondaryServices) { type in
                        ServiceTypeButton(
                            type: type,
                            isSelected: state.serviceType == type
                        ) {
                            withAnimation(TippySpring.snappy) {
                                state.serviceType = type
                                amountFocused = false
                            }
                            Self.recordUsage(for: type)
                        }
                    }
                }
            }

            if !showMore {
                Button {
                    withAnimation(TippySpring.gentle) {
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
                    withAnimation(TippySpring.gentle) {
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

    // MARK: - Service Usage Tracking

    private static let usageKey = "tippy_service_usage"

    private static func serviceUsage() -> [String: Int] {
        UserDefaults.standard.dictionary(forKey: usageKey) as? [String: Int] ?? [:]
    }

    static func recordUsage(for type: ServiceType) {
        var usage = serviceUsage()
        usage[type.rawValue, default: 0] += 1
        UserDefaults.standard.set(usage, forKey: usageKey)
    }

    private func snapshotServiceGrid() {
        let usage = Self.serviceUsage()
        let distinctUsed = usage.filter { $0.value > 0 }.count
        guard distinctUsed >= 3 else { return }
        let sorted = ServiceType.allCases.sorted { (usage[$0.rawValue] ?? 0) > (usage[$1.rawValue] ?? 0) }
        primaryServices = Array(sorted.prefix(6))
        let primarySet = Set(primaryServices)
        secondaryServices = ServiceType.allCases.filter { !primarySet.contains($0) }
    }
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
        .buttonStyle(TippyPressableStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    EntryView(state: TipState())
}
