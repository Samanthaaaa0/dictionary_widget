import SwiftUI

struct WordDetailView: View {
    let word: ChineseWord
    @State private var isFavorite: Bool
    @State private var isPinned: Bool
    @State private var category: WordCategory

    init(word: ChineseWord) {
        self.word = word
        _isFavorite = State(initialValue: word.isFavorite)
        _isPinned = State(initialValue: word.isPinnedToWidget)
        _category = State(initialValue: word.category)
    }

    private var senses: [GlossFormatter.Cleaned] {
        GlossFormatter.cleanList(word.allDefinitions)
    }

    var body: some View {
        ZStack {
            Y2KBackground()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text(word.hanzi)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .y2kFloating()

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

                        // Short gloss stays as a quick-glance line even when
                        // the fuller breakdown below is available.
                        if senses.isEmpty {
                            Text(word.englishShort)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.textSecondary)
                                .padding(.horizontal)
                        }

                        HStack(spacing: 8) {
                            Text(word.masteryLabel.uppercased())
                                .font(.caption2.weight(.bold))
                                .tracking(1.2)
                                .foregroundStyle(Theme.turquoise)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Theme.turquoise.opacity(0.12), in: Capsule())

                            categoryMenu
                        }
                    }
                    .padding(.top, 24)

                    if !senses.isEmpty {
                        meaningCard
                            .padding(.horizontal)
                    }

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

    /// Every sense of the word, cleaned of parenthetical clutter, with those
    /// parenthetical bits shown instead as small tags — the "cute" fuller
    /// explanation that doesn't fit in the one-line list views.
    private var meaningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MEANING")
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Theme.turquoise)

            ForEach(Array(senses.enumerated()), id: \.offset) { index, sense in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.background)
                        .frame(width: 18, height: 18)
                        .background(Theme.turquoise, in: Circle())

                    VStack(alignment: .leading, spacing: 6) {
                        Text(sense.text)
                            .font(.body)
                            .foregroundStyle(Theme.textPrimary)

                        if !sense.notes.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(sense.notes, id: \.self) { note in
                                    Text(note)
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(Theme.magenta)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Theme.magenta.opacity(0.14), in: Capsule())
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .y2kCard()
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(WordCategory.allCases) { cat in
                Button {
                    category = cat
                    persistCategory(cat)
                } label: {
                    Label(cat.label, systemImage: cat.icon)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                Text(category.label.uppercased())
            }
            .font(.caption2.weight(.bold))
            .tracking(1.0)
            .foregroundStyle(category.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(category.color.opacity(0.12), in: Capsule())
        }
    }

    /// Saves the word first if it isn't already in My Words — otherwise
    /// picking a category for a word you're just browsing in Dictionary
    /// would silently do nothing.
    private func persistCategory(_ cat: WordCategory) {
        var updated = word
        updated.category = cat
        if WordStore.loadAll().contains(where: { $0.id == word.id }) {
            WordStore.update(updated)
        } else {
            WordStore.add(updated)
        }
    }
}
