import SwiftUI
import WidgetKit

struct CiCiWidget: Widget {
    let kind = "CiCiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CiCiWidgetProvider()) { entry in
            CiCiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CiCi Word")
        .description("A little Chinese word, every day. Pin one from the app, or let it rotate daily.")
        .supportedFamilies([
            .accessoryCircular, .accessoryRectangular, .accessoryInline,
            .systemSmall, .systemMedium
        ])
    }
}

struct CiCiWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WordEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView(word: entry.word)
        case .accessoryRectangular:
            RectangularView(word: entry.word)
        case .accessoryInline:
            Text("\(entry.word.hanzi) · \(entry.word.pinyinDisplay) · \(entry.word.englishShort)")
        case .systemMedium:
            MediumCardView(word: entry.word)
        default:
            SmallCardView(word: entry.word)
        }
    }
}

// MARK: - Lock screen families
// iOS always renders these in its own system tint/monochrome style —
// your custom colors are ignored here by design, so keep them simple.

private struct CircularView: View {
    let word: ChineseWord
    var body: some View {
        VStack(spacing: 2) {
            Text(word.hanzi).font(.system(size: 22, weight: .bold, design: .rounded))
            Text(word.pinyinDisplay).font(.system(size: 9))
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct RectangularView: View {
    let word: ChineseWord
    var body: some View {
        HStack(spacing: 8) {
            Text(word.hanzi).font(.system(size: 24, weight: .bold, design: .rounded))
            VStack(alignment: .leading, spacing: 1) {
                Text(word.pinyinDisplay).font(.caption2)
                Text(word.englishShort).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Home screen families — dark + turquoise, this is where the theme shows

private struct SmallCardView: View {
    let word: ChineseWord
    var body: some View {
        VStack(spacing: 6) {
            Text(word.hanzi)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(word.pinyinDisplay)
                .font(.subheadline)
                .foregroundStyle(Theme.turquoise)
            Text(word.englishShort)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Theme.background
        }
    }
}

private struct MediumCardView: View {
    let word: ChineseWord
    var body: some View {
        HStack(spacing: 16) {
            Text(word.hanzi)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            VStack(alignment: .leading, spacing: 4) {
                Text(word.pinyinDisplay).font(.headline).foregroundStyle(Theme.turquoise)
                Text(word.englishShort).font(.subheadline).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Theme.background
        }
    }
}
