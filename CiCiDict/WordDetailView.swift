import SwiftUI

struct WordDetailView: View {
    let word: ChineseWord
    @State private var isFavorite: Bool
    @State private var isPinned: Bool

    init(word: ChineseWord) {
        self.word = word
        _isFavorite = State(initialValue: word.isFavorite)
        _isPinned = State(initialValue: word.isPinnedToWidget)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text(word.hanzi)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        HStack(spacing: 10) {
                            Text(word.pinyinDisplay)
                                .font(.title2)
                                .foregroundStyle(Theme.turquoise)
                                .y2kGlowText()

                            Button {
                                SpeechHelper.shared.speak(word.hanzi)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                            .foregroundStyle(Theme.turquoise)
                        }

                        Text(word.englishShort)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal)

                        Text(word.masteryLabel.uppercased())
                            .font(.caption2.weight(.bold))
                            .tracking(1.2)
                            .foregroundStyle(Theme.turquoise)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Theme.turquoise.opacity(0.12), in: Capsule())
                    }
                    .padding(.top, 24)

                    if let exHanzi = word.exampleHanzi, !exHanzi.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("EXAMPLE")
                                .font(.caption2.weight(.bold))
                                .tracking(1.2)
                                .foregroundStyle(Theme.turquoise)
                            Text(exHanzi)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                            if let p = word.examplePinyinDisplay {
                                Text(p).font(.footnote).foregroundStyle(Theme.turquoiseDim)
                            }
                            if let en = word.exampleEnglish {
                                Text(en).font(.footnote).foregroundStyle(Theme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .y2kCard()
                        .padding(.horizontal)
                    }

                    Button {
                        isPinned.toggle()
                        if isPinned { WordStore.pin(word) } else { WordStore.unpin(word) }
                    } label: {
                        Label(isPinned ? "Pinned to Widget" : "Pin to Widget",
                              systemImage: isPinned ? "pin.fill" : "pin")
                    }
                    .buttonStyle(Y2KButtonStyle(filled: isPinned))
                    .padding(.horizontal)

                    if isPinned {
                        Text("Shows on your Home Screen widget. Lock screen widgets always render in the system's own tint, so this only affects colors on the Home Screen one.")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFavorite.toggle()
                    WordStore.toggleFavorite(word)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(Theme.turquoise)
                }
            }
        }
    }
}
