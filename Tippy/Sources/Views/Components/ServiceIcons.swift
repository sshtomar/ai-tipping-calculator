import SwiftUI

struct ServiceIcon: View {
    let type: ServiceType
    var size: CGFloat = 28
    var color: Color = .tippyTextSecondary

    var body: some View {
        Image(systemName: type.sfSymbol)
            .font(.system(size: size * 0.7))
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

#Preview("All Service Icons") {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
        ForEach(ServiceType.allCases) { type in
            VStack(spacing: 8) {
                ServiceIcon(type: type, size: 36, color: .tippyPrimary)
                Text(type.displayName)
                    .font(.caption2)
            }
        }
    }
    .padding()
}
