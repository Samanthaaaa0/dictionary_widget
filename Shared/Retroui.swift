import SwiftUI

// MARK: - Background: scrolling vaporwave grid + twinkling stars + CRT scanlines
// This is the "old PC / retro computer" feel, built entirely from shape

struct Y2KBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.background, Color(red: 0.07, green: 0.03, blue: 0.11)],
                startPoint: .top, endPoint: .bottom
            )
            VaporwaveGrid()
            SparkleField()
            CRTScanlines()
        }
        .ignoresSafeArea()
    }
}

private struct VaporwaveGrid: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 12, paused: false)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let horizonY = size.height * 0.6
                let rows = 12
                let scroll = t.truncatingRemainder(dividingBy: 2.4) / 2.4

                // Horizontal lines, converging toward the horizon, slowly scrolling "toward" the viewer.
                for i in 0..<rows {
                    let progress = (Double(i) + scroll) / Double(rows)
                    guard progress > 0 else { continue }
                    let y = horizonY + pow(progress, 2.3) * (size.height - horizonY)
                    guard y <= size.height else { continue }
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(Theme.turquoise.opacity((1 - progress) * 0.22)), lineWidth: 1)
                }

                // Vertical lines converging to a single vanishing point.
                let vanish = CGPoint(x: size.width / 2, y: horizonY)
                let columns = 9
                for i in 0...columns {
                    let x = size.width * CGFloat(i) / CGFloat(columns)
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: size.height))
                    path.addLine(to: vanish)
                    context.stroke(path, with: .color(Theme.purple.opacity(0.12)), lineWidth: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SparkleField: View {
    private struct Spark: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let delay: Double
        let color: Color
    }

    @State private var sparks: [Spark] = (0..<14).map { i in
        Spark(x: .random(in: 0...1), y: .random(in: 0...1), size: .random(in: 2...4),
              delay: .random(in: 0...2), color: i.isMultiple(of: 3) ? Theme.magenta : Theme.turquoise)
    }
    @State private var twinkle = false

    var body: some View {
        GeometryReader { geo in
            ForEach(sparks) { spark in
                Circle()
                    .fill(spark.color)
                    .frame(width: spark.size, height: spark.size)
                    .position(x: spark.x * geo.size.width, y: spark.y * geo.size.height)
                    .opacity(twinkle ? 0.85 : 0.1)
                    .animation(
                        .easeInOut(duration: 1.7).repeatForever(autoreverses: true).delay(spark.delay),
                        value: twinkle
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear { twinkle = true }
    }
}

private struct CRTScanlines: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)), with: .color(.black.opacity(0.05)))
                y += 3
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Retro window title bar (classic old-OS chrome, dots + label)

struct RetroTitleBar: View {
    let title: String
    var accent: Color = Theme.turquoise

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.red.opacity(0.75)).frame(width: 9, height: 9)
            Circle().fill(Color.yellow.opacity(0.75)).frame(width: 9, height: 9)
            Circle().fill(Color.green.opacity(0.75)).frame(width: 9, height: 9)
            Spacer()
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(accent)
            Spacer()
            Color.clear.frame(width: 33)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Theme.surfaceBorder, lineWidth: 1))
    }
}

// MARK: - Word chip button (used by the sentence-builder word bank)

struct WordChipStyle: ButtonStyle {
    var color: Color = Theme.turquoise

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Theme.textPrimary)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(color.opacity(configuration.isPressed ? 0.35 : 0.16), in: Capsule())
            .overlay(Capsule().stroke(color, lineWidth: 1.5))
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Flow layout — wraps chips onto multiple lines like a word bank

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Small interactive flourishes

/// Gentle up/down bob for hero elements (a big hanzi character, say).
struct FloatingModifier: ViewModifier {
    @State private var floating = false
    func body(content: Content) -> some View {
        content
            .offset(y: floating ? -5 : 5)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: floating)
            .onAppear { floating = true }
    }
}

extension View {
    func y2kFloating() -> some View { modifier(FloatingModifier()) }
}

/// A burst of little stars/sparkles fired outward from the center — for celebrating a correct answer.
struct SparkleBurst: View {
    private let symbols = ["sparkle", "star.fill", "sparkles"]
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<10, id: \.self) { i in
                    let angle = Double(i) / 10 * 2 * .pi
                    Image(systemName: symbols[i % symbols.count])
                        .font(.system(size: CGFloat.random(in: 12...20)))
                        .foregroundStyle(i.isMultiple(of: 2) ? Theme.turquoise : Theme.magenta)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .offset(x: animate ? cos(angle) * 120 : 0, y: animate ? sin(angle) * 120 : 0)
                        .opacity(animate ? 0 : 1)
                        .animation(.easeOut(duration: 0.9), value: animate)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
