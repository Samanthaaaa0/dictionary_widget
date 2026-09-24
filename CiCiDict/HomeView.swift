import SwiftUI

/// The app's front door. Since the widget is the main feature, Home mirrors
/// it: one hero word, big and tappable, that you can shuffle through like
/// flipping a Polaroid. This is the screen that's supposed to make opening
/// the app feel like a little treat instead of a chore.
struct HomeView: View {
    @State private var words: [ChineseWord] = []
    @State private var current: ChineseWord?
    @State private var isPinned = false
    @State private var isFavorite = false
    @State private var spin = false
    @State private var celebrate = false
    @State private var dueCount = 0

    private let deco = ["✦", "☆", "♡", "✧", "⋆", "◇"]

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        header

                        if let current {
                            heroCard(current)
                                .padding(.horizontal)
                        }

                        statStrip
                            .padding(.horizontal)

                        Button {
                            shuffle(haptic: true)
                        } label: {
                            Label("Shuffle word", systemImage: "shuffle")
                        }
                        .buttonStyle(Y2KButtonStyle(filled: true))
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }

                if celebrate {
                    SparkleBurst()
                }
            }
            .navigationTitle("CiCi")
            .onAppear(perform: refresh)
        }
    }

    private var header: some View {
        HStack {
            Text("\(deco.randomElement() ?? "✦") today's word")
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    private func heroCard(_ word: ChineseWord) -> some View {
        VStack(spacing: 16) {
            RetroTitleBar(title: "CICI ✦ WIDGET PREVIEW", accent: Theme.magenta)

            VStack(spacing: 10) {
                Text(word.hanzi)
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .y2kGlowText()
                    .rotation3DEffect(.degrees(spin ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                    .id(word.id) // forces a fresh transition per word

                HStack(spacing: 8) {
                    Text(word.pinyinDisplay)
                        .font(.title3)
                        .foregroundStyle(Theme.turquoise)
                    Button {
                        SpeechHelper.shared.speak(word.hanzi)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .foregroundStyle(Theme.turquoise)
                }

                Text(word.englishShort)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)

                if word.category != .uncategorized {
                    Label(word.category.label, systemImage: word.category.icon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(word.category.color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(word.category.color.opacity(0.14), in: Capsule())
                }
            }
            .y2kFloating()
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))

            HStack(spacing: 12) {
                iconToggle(isPinned ? "pin.fill" : "pin", tint: Theme.turquoise) {
                    isPinned.toggle()
                    if isPinned { WordStore.pin(word) } else { WordStore.unpin(word) }
                }
                iconToggle(isFavorite ? "heart.fill" : "heart", tint: Theme.magenta) {
                    isFavorite.toggle()
                    ensureSaved(word)
                    WordStore.toggleFavorite(word)
                    if isFavorite {
                        celebrate = true
                        Task {
                            try? await Task.sleep(nanoseconds: 700_000_000)
                            celebrate = false
                        }
                    }
                }
                NavigationLink(value: word) {
                    Label("Details", systemImage: "info.circle")
                        .font(.footnote.weight(.semibold))
                }
                .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
        }
        .padding()
        .y2kCard(cornerRadius: 28)
        .navigationDestination(for: ChineseWord.self) { WordDetailView(word: $0) }
    }

    private func iconToggle(_ systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .padding(9)
                .background(tint.opacity(0.14), in: Circle())
        }
    }

    private var statStrip: some View {
        HStack(spacing: 12) {
            statChip(value: "\(words.count)", label: "words saved", color: Theme.turquoise, icon: "star.fill")
            statChip(value: "\(dueCount)", label: "due to review", color: Theme.amber, icon: "brain.head.profile")
        }
    }

    private func statChip(value: String, label: String, color: Color, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(.headline).foregroundStyle(Theme.textPrimary)
                Text(label).font(.caption2).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(12)
        .y2kCard(cornerRadius: 16)
    }

    private func refresh() {
        words = WordStore.loadAll()
        dueCount = WordStore.wordsDueForReview(from: words).count
        // Only pick a fresh word on first appear — NavigationStack re-fires
        // onAppear every time you pop back from Details, and re-rolling here
        // was silently throwing away whatever you'd shuffled to.
        if current == nil {
            current = WordStore.wordOfDay(from: words)
        } else if let hanzi = current?.hanzi, let match = words.first(where: { $0.hanzi == hanzi }) {
            // Keep showing the same word, but pick up any pin/favorite change
            // made from the Details screen you just came back from.
            current = match
        }
        isPinned = current?.isPinnedToWidget ?? false
        isFavorite = current?.isFavorite ?? false
    }

    private func shuffle(haptic: Bool) {
        let pool = words.isEmpty ? SeedDictionary.words : words
        guard !pool.isEmpty else { return }
        var next = current
        // avoid landing on the same word twice in a row when there's a choice
        while next?.id == current?.id && pool.count > 1 {
            next = pool.randomElement()
        }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
            current = next
            spin.toggle()
            isPinned = current?.isPinnedToWidget ?? false
            isFavorite = current?.isFavorite ?? false
        }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    /// Favoriting/pinning a seed word (not yet in "My Words") should save it first.
    private func ensureSaved(_ word: ChineseWord) {
        guard !words.contains(where: { $0.hanzi == word.hanzi }) else { return }
        WordStore.add(word)
        words = WordStore.loadAll()
    }
}

#Preview {
    HomeView()
}
