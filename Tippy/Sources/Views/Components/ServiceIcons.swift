import SwiftUI

// MARK: - Handcrafted Service Icons
// Each icon is a custom SwiftUI shape — warm, minimal line-art style.

struct ServiceIcon: View {
    let type: ServiceType
    var size: CGFloat = 28
    var color: Color = .tippyTextSecondary

    var body: some View {
        Group {
            switch type {
            case .restaurant: RestaurantIcon()
            case .bar: BarIcon()
            case .cafe: CafeIcon()
            case .delivery: DeliveryIcon()
            case .rideshare: RideshareIcon()
            case .salon: SalonIcon()
            case .spa: SpaIcon()
            case .tattoo: TattooIcon()
            case .valet: ValetIcon()
            case .hotel: HotelIcon()
            case .movers: MoversIcon()
            case .other: OtherIcon()
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(color)
    }
}

// MARK: - Restaurant (plate with fork & knife)

private struct RestaurantIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h / 2

            // Plate circle
            var plate = Path()
            plate.addArc(center: CGPoint(x: cx, y: cy), radius: w * 0.38,
                         startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(plate, with: .foreground, lineWidth: 1.8)

            // Inner plate
            var inner = Path()
            inner.addArc(center: CGPoint(x: cx, y: cy), radius: w * 0.24,
                         startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(inner, with: .foreground, lineWidth: 1.2)

            // Fork (left)
            var fork = Path()
            fork.move(to: CGPoint(x: w * 0.18, y: h * 0.22))
            fork.addLine(to: CGPoint(x: w * 0.18, y: h * 0.50))
            fork.move(to: CGPoint(x: w * 0.12, y: h * 0.22))
            fork.addLine(to: CGPoint(x: w * 0.12, y: h * 0.38))
            fork.addQuadCurve(to: CGPoint(x: w * 0.24, y: h * 0.38),
                              control: CGPoint(x: w * 0.18, y: h * 0.46))
            fork.addLine(to: CGPoint(x: w * 0.24, y: h * 0.22))
            context.stroke(fork, with: .foreground, lineWidth: 1.5)

            // Knife (right)
            var knife = Path()
            knife.move(to: CGPoint(x: w * 0.82, y: h * 0.22))
            knife.addLine(to: CGPoint(x: w * 0.82, y: h * 0.50))
            knife.move(to: CGPoint(x: w * 0.82, y: h * 0.22))
            knife.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.42),
                               control: CGPoint(x: w * 0.90, y: h * 0.32))
            context.stroke(knife, with: .foreground, lineWidth: 1.5)
        }
    }
}

// MARK: - Bar (cocktail glass)

private struct BarIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            var glass = Path()
            // V-shape glass
            glass.move(to: CGPoint(x: w * 0.15, y: h * 0.18))
            glass.addLine(to: CGPoint(x: w * 0.50, y: h * 0.58))
            glass.addLine(to: CGPoint(x: w * 0.85, y: h * 0.18))
            // Rim
            glass.move(to: CGPoint(x: w * 0.12, y: h * 0.18))
            glass.addLine(to: CGPoint(x: w * 0.88, y: h * 0.18))
            // Stem
            glass.move(to: CGPoint(x: w * 0.50, y: h * 0.58))
            glass.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            // Base
            glass.move(to: CGPoint(x: w * 0.30, y: h * 0.78))
            glass.addLine(to: CGPoint(x: w * 0.70, y: h * 0.78))
            context.stroke(glass, with: .foreground, lineWidth: 1.8)

            // Olive
            var olive = Path()
            olive.addEllipse(in: CGRect(x: w * 0.42, y: h * 0.30, width: w * 0.10, height: w * 0.10))
            context.stroke(olive, with: .foreground, lineWidth: 1.5)
        }
    }
}

// MARK: - Cafe (steaming cup)

private struct CafeIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Cup body
            var cup = Path()
            cup.move(to: CGPoint(x: w * 0.15, y: h * 0.38))
            cup.addLine(to: CGPoint(x: w * 0.22, y: h * 0.78))
            cup.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.78),
                             control: CGPoint(x: w * 0.42, y: h * 0.86))
            cup.addLine(to: CGPoint(x: w * 0.68, y: h * 0.38))
            cup.closeSubpath()
            context.stroke(cup, with: .foreground, lineWidth: 1.8)

            // Handle
            var handle = Path()
            handle.move(to: CGPoint(x: w * 0.68, y: h * 0.44))
            handle.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.66),
                                control: CGPoint(x: w * 0.88, y: h * 0.55))
            context.stroke(handle, with: .foreground, lineWidth: 1.8)

            // Steam
            for i in 0..<3 {
                let xOff = w * (0.28 + CGFloat(i) * 0.12)
                var steam = Path()
                steam.move(to: CGPoint(x: xOff, y: h * 0.30))
                steam.addQuadCurve(to: CGPoint(x: xOff, y: h * 0.14),
                                   control: CGPoint(x: xOff + w * 0.06, y: h * 0.22))
                context.stroke(steam, with: .foreground, lineWidth: 1.2)
            }
        }
    }
}

// MARK: - Delivery (box with motion lines)

private struct DeliveryIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Box
            var box = Path()
            box.addRoundedRect(in: CGRect(x: w * 0.20, y: h * 0.30, width: w * 0.60, height: h * 0.45),
                               cornerSize: CGSize(width: 3, height: 3))
            context.stroke(box, with: .foreground, lineWidth: 1.8)

            // Box flap
            var flap = Path()
            flap.move(to: CGPoint(x: w * 0.20, y: h * 0.30))
            flap.addLine(to: CGPoint(x: w * 0.30, y: h * 0.18))
            flap.addLine(to: CGPoint(x: w * 0.70, y: h * 0.18))
            flap.addLine(to: CGPoint(x: w * 0.80, y: h * 0.30))
            context.stroke(flap, with: .foreground, lineWidth: 1.8)

            // Center fold line
            var fold = Path()
            fold.move(to: CGPoint(x: w * 0.50, y: h * 0.18))
            fold.addLine(to: CGPoint(x: w * 0.50, y: h * 0.30))
            context.stroke(fold, with: .foreground, lineWidth: 1.2)

            // Motion lines
            for i in 0..<3 {
                let y = h * (0.40 + CGFloat(i) * 0.12)
                var line = Path()
                line.move(to: CGPoint(x: w * 0.05, y: y))
                line.addLine(to: CGPoint(x: w * 0.15, y: y))
                context.stroke(line, with: .foreground, lineWidth: 1.2)
            }
        }
    }
}

// MARK: - Rideshare (car outline)

private struct RideshareIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Car body
            var car = Path()
            car.move(to: CGPoint(x: w * 0.10, y: h * 0.58))
            car.addLine(to: CGPoint(x: w * 0.18, y: h * 0.58))
            car.addLine(to: CGPoint(x: w * 0.25, y: h * 0.35))
            car.addLine(to: CGPoint(x: w * 0.72, y: h * 0.35))
            car.addLine(to: CGPoint(x: w * 0.88, y: h * 0.50))
            car.addLine(to: CGPoint(x: w * 0.92, y: h * 0.58))
            car.addLine(to: CGPoint(x: w * 0.92, y: h * 0.62))
            car.addLine(to: CGPoint(x: w * 0.10, y: h * 0.62))
            car.closeSubpath()
            context.stroke(car, with: .foreground, lineWidth: 1.8)

            // Windows
            var window = Path()
            window.move(to: CGPoint(x: w * 0.30, y: h * 0.38))
            window.addLine(to: CGPoint(x: w * 0.28, y: h * 0.54))
            window.addLine(to: CGPoint(x: w * 0.48, y: h * 0.54))
            window.addLine(to: CGPoint(x: w * 0.48, y: h * 0.38))
            window.closeSubpath()
            context.stroke(window, with: .foreground, lineWidth: 1.2)

            var window2 = Path()
            window2.move(to: CGPoint(x: w * 0.52, y: h * 0.38))
            window2.addLine(to: CGPoint(x: w * 0.52, y: h * 0.54))
            window2.addLine(to: CGPoint(x: w * 0.76, y: h * 0.54))
            window2.addLine(to: CGPoint(x: w * 0.70, y: h * 0.38))
            window2.closeSubpath()
            context.stroke(window2, with: .foreground, lineWidth: 1.2)

            // Wheels
            for xc in [w * 0.28, w * 0.74] {
                var wheel = Path()
                wheel.addArc(center: CGPoint(x: xc, y: h * 0.66),
                             radius: w * 0.07, startAngle: .zero,
                             endAngle: .degrees(360), clockwise: false)
                context.fill(wheel, with: .foreground)
            }
        }
    }
}

// MARK: - Salon (scissors)

private struct SalonIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Top blade
            var blade1 = Path()
            blade1.addArc(center: CGPoint(x: w * 0.30, y: h * 0.30),
                          radius: w * 0.14, startAngle: .degrees(-30),
                          endAngle: .degrees(210), clockwise: false)
            context.stroke(blade1, with: .foreground, lineWidth: 1.8)

            // Bottom blade
            var blade2 = Path()
            blade2.addArc(center: CGPoint(x: w * 0.30, y: h * 0.70),
                          radius: w * 0.14, startAngle: .degrees(30),
                          endAngle: .degrees(-210), clockwise: true)
            context.stroke(blade2, with: .foreground, lineWidth: 1.8)

            // Handles
            var handles = Path()
            handles.move(to: CGPoint(x: w * 0.42, y: h * 0.38))
            handles.addLine(to: CGPoint(x: w * 0.85, y: h * 0.25))
            handles.move(to: CGPoint(x: w * 0.42, y: h * 0.62))
            handles.addLine(to: CGPoint(x: w * 0.85, y: h * 0.75))
            context.stroke(handles, with: .foreground, lineWidth: 1.8)

            // Pivot
            var pivot = Path()
            pivot.addArc(center: CGPoint(x: w * 0.42, y: h * 0.50),
                         radius: w * 0.04, startAngle: .zero,
                         endAngle: .degrees(360), clockwise: false)
            context.fill(pivot, with: .foreground)
        }
    }
}

// MARK: - Spa (lotus/leaf)

private struct SpaIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2

            // Center petal
            var petal = Path()
            petal.move(to: CGPoint(x: cx, y: h * 0.15))
            petal.addQuadCurve(to: CGPoint(x: cx, y: h * 0.65),
                               control: CGPoint(x: cx + w * 0.18, y: h * 0.40))
            petal.addQuadCurve(to: CGPoint(x: cx, y: h * 0.15),
                               control: CGPoint(x: cx - w * 0.18, y: h * 0.40))
            context.stroke(petal, with: .foreground, lineWidth: 1.8)

            // Left petal
            var lp = Path()
            lp.move(to: CGPoint(x: cx - w * 0.05, y: h * 0.58))
            lp.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.35),
                            control: CGPoint(x: w * 0.10, y: h * 0.58))
            lp.addQuadCurve(to: CGPoint(x: cx - w * 0.05, y: h * 0.58),
                            control: CGPoint(x: w * 0.22, y: h * 0.30))
            context.stroke(lp, with: .foreground, lineWidth: 1.5)

            // Right petal
            var rp = Path()
            rp.move(to: CGPoint(x: cx + w * 0.05, y: h * 0.58))
            rp.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.35),
                            control: CGPoint(x: w * 0.90, y: h * 0.58))
            rp.addQuadCurve(to: CGPoint(x: cx + w * 0.05, y: h * 0.58),
                            control: CGPoint(x: w * 0.78, y: h * 0.30))
            context.stroke(rp, with: .foreground, lineWidth: 1.5)

            // Base arc
            var base = Path()
            base.addArc(center: CGPoint(x: cx, y: h * 0.75), radius: w * 0.18,
                        startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            context.stroke(base, with: .foreground, lineWidth: 1.5)
        }
    }
}

// MARK: - Tattoo (pen/needle with ink)

private struct TattooIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Pen body (diagonal)
            var pen = Path()
            pen.move(to: CGPoint(x: w * 0.75, y: h * 0.15))
            pen.addLine(to: CGPoint(x: w * 0.82, y: h * 0.22))
            pen.addLine(to: CGPoint(x: w * 0.32, y: h * 0.72))
            pen.addLine(to: CGPoint(x: w * 0.22, y: h * 0.82))
            pen.addLine(to: CGPoint(x: w * 0.18, y: h * 0.78))
            pen.addLine(to: CGPoint(x: w * 0.68, y: h * 0.28))
            pen.closeSubpath()
            context.stroke(pen, with: .foreground, lineWidth: 1.6)

            // Tip
            var tip = Path()
            tip.move(to: CGPoint(x: w * 0.22, y: h * 0.82))
            tip.addLine(to: CGPoint(x: w * 0.16, y: h * 0.88))
            context.stroke(tip, with: .foreground, lineWidth: 1.8)

            // Ink drops
            for (dx, dy) in [(0.28, 0.82), (0.20, 0.90), (0.34, 0.88)] as [(CGFloat, CGFloat)] {
                var drop = Path()
                drop.addArc(center: CGPoint(x: w * dx, y: h * dy),
                            radius: 2, startAngle: .zero,
                            endAngle: .degrees(360), clockwise: false)
                context.fill(drop, with: .foreground)
            }

            // Star decorative element
            var star = Path()
            let sx = w * 0.70
            let sy = h * 0.65
            star.move(to: CGPoint(x: sx, y: sy - 4))
            star.addLine(to: CGPoint(x: sx, y: sy + 4))
            star.move(to: CGPoint(x: sx - 4, y: sy))
            star.addLine(to: CGPoint(x: sx + 4, y: sy))
            context.stroke(star, with: .foreground, lineWidth: 1.2)
        }
    }
}

// MARK: - Valet (key)

private struct ValetIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Key head (circle)
            var head = Path()
            head.addArc(center: CGPoint(x: w * 0.32, y: h * 0.42),
                        radius: w * 0.18, startAngle: .zero,
                        endAngle: .degrees(360), clockwise: false)
            context.stroke(head, with: .foreground, lineWidth: 1.8)

            // Key hole
            var hole = Path()
            hole.addArc(center: CGPoint(x: w * 0.32, y: h * 0.42),
                        radius: w * 0.07, startAngle: .zero,
                        endAngle: .degrees(360), clockwise: false)
            context.stroke(hole, with: .foreground, lineWidth: 1.5)

            // Shaft
            var shaft = Path()
            shaft.move(to: CGPoint(x: w * 0.50, y: h * 0.42))
            shaft.addLine(to: CGPoint(x: w * 0.88, y: h * 0.42))
            context.stroke(shaft, with: .foreground, lineWidth: 1.8)

            // Teeth
            var teeth = Path()
            teeth.move(to: CGPoint(x: w * 0.72, y: h * 0.42))
            teeth.addLine(to: CGPoint(x: w * 0.72, y: h * 0.55))
            teeth.move(to: CGPoint(x: w * 0.80, y: h * 0.42))
            teeth.addLine(to: CGPoint(x: w * 0.80, y: h * 0.52))
            teeth.move(to: CGPoint(x: w * 0.88, y: h * 0.42))
            teeth.addLine(to: CGPoint(x: w * 0.88, y: h * 0.55))
            context.stroke(teeth, with: .foreground, lineWidth: 1.5)
        }
    }
}

// MARK: - Hotel (bell)

private struct HotelIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Bell dome
            var dome = Path()
            dome.move(to: CGPoint(x: w * 0.12, y: h * 0.68))
            dome.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.22),
                              control: CGPoint(x: w * 0.12, y: h * 0.30))
            dome.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.68),
                              control: CGPoint(x: w * 0.88, y: h * 0.30))
            context.stroke(dome, with: .foreground, lineWidth: 1.8)

            // Base line
            var base = Path()
            base.move(to: CGPoint(x: w * 0.08, y: h * 0.68))
            base.addLine(to: CGPoint(x: w * 0.92, y: h * 0.68))
            context.stroke(base, with: .foreground, lineWidth: 2.0)

            // Platform
            var platform = Path()
            platform.move(to: CGPoint(x: w * 0.15, y: h * 0.74))
            platform.addLine(to: CGPoint(x: w * 0.85, y: h * 0.74))
            context.stroke(platform, with: .foreground, lineWidth: 1.8)

            // Top button
            var button = Path()
            button.addArc(center: CGPoint(x: w * 0.50, y: h * 0.20),
                          radius: w * 0.04, startAngle: .zero,
                          endAngle: .degrees(360), clockwise: false)
            context.fill(button, with: .foreground)

            // Ding lines
            var ding = Path()
            ding.move(to: CGPoint(x: w * 0.42, y: h * 0.12))
            ding.addLine(to: CGPoint(x: w * 0.38, y: h * 0.08))
            ding.move(to: CGPoint(x: w * 0.58, y: h * 0.12))
            ding.addLine(to: CGPoint(x: w * 0.62, y: h * 0.08))
            context.stroke(ding, with: .foreground, lineWidth: 1.2)
        }
    }
}

// MARK: - Movers (hand truck / dolly)

private struct MoversIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // L-shaped dolly frame
            var frame = Path()
            frame.move(to: CGPoint(x: w * 0.35, y: h * 0.12))
            frame.addLine(to: CGPoint(x: w * 0.35, y: h * 0.72))
            frame.addLine(to: CGPoint(x: w * 0.75, y: h * 0.72))
            context.stroke(frame, with: .foreground, lineWidth: 2.0)

            // Box on dolly
            var box = Path()
            box.addRoundedRect(in: CGRect(x: w * 0.38, y: h * 0.28, width: w * 0.28, height: h * 0.28),
                               cornerSize: CGSize(width: 2, height: 2))
            context.stroke(box, with: .foreground, lineWidth: 1.5)

            // Tape line
            var tape = Path()
            tape.move(to: CGPoint(x: w * 0.52, y: h * 0.28))
            tape.addLine(to: CGPoint(x: w * 0.52, y: h * 0.56))
            context.stroke(tape, with: .foreground, lineWidth: 1.0)

            // Wheels
            for xc in [w * 0.40, w * 0.70] {
                var wheel = Path()
                wheel.addArc(center: CGPoint(x: xc, y: h * 0.80),
                             radius: w * 0.06, startAngle: .zero,
                             endAngle: .degrees(360), clockwise: false)
                context.stroke(wheel, with: .foreground, lineWidth: 1.5)
                var axle = Path()
                axle.addArc(center: CGPoint(x: xc, y: h * 0.80),
                             radius: w * 0.02, startAngle: .zero,
                             endAngle: .degrees(360), clockwise: false)
                context.fill(axle, with: .foreground)
            }
        }
    }
}

// MARK: - Other (sparkle/star)

private struct OtherIcon: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h / 2

            // 4-point sparkle
            var sparkle = Path()
            // Top
            sparkle.move(to: CGPoint(x: cx, y: h * 0.10))
            sparkle.addQuadCurve(to: CGPoint(x: cx, y: h * 0.90),
                                 control: CGPoint(x: cx + w * 0.15, y: cy))
            sparkle.addQuadCurve(to: CGPoint(x: cx, y: h * 0.10),
                                 control: CGPoint(x: cx - w * 0.15, y: cy))
            context.stroke(sparkle, with: .foreground, lineWidth: 1.5)

            var sparkle2 = Path()
            sparkle2.move(to: CGPoint(x: w * 0.10, y: cy))
            sparkle2.addQuadCurve(to: CGPoint(x: w * 0.90, y: cy),
                                  control: CGPoint(x: cx, y: cy + h * 0.15))
            sparkle2.addQuadCurve(to: CGPoint(x: w * 0.10, y: cy),
                                  control: CGPoint(x: cx, y: cy - h * 0.15))
            context.stroke(sparkle2, with: .foreground, lineWidth: 1.5)

            // Center dot
            var dot = Path()
            dot.addArc(center: CGPoint(x: cx, y: cy), radius: 2,
                       startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.fill(dot, with: .foreground)
        }
    }
}

// MARK: - Preview

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
