import SwiftUI

struct SentencePracticeView: View {
    @State private var bank: [ChineseWord] = []
    @State private var built: [ChineseWord] = []
    @State private var aiResult: SentenceCheckResult?
    @State private var isChecking = false
    @State private var errorMessage: String?
    @State private var celebrate = false
    @State private var hasAPIKey = false
    @State private var practiceConfirmation: String?

    /// Best-known first — practicing with words you're more confident on
    /// tends to produce sentences that actually feel rewarding to build.
    private let categoryOrder = ["Mastered", "Familiar", "Learning", "New"]

    private var localReading: String {
        LocalSentenceTranslator.translate(built)
    }

    private var bankByCategory: [(label: String, words: [ChineseWord])] {
        categoryOrder.compactMap { label in
            let matches = bank.filter { $0.masteryLabel == label }
            return matches.isEmpty ? nil : (label, matches)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                if bank.isEmpty && built.isEmpty {
                    ContentUnavailableView(
                        "Learn a few words first",
                        systemImage: "square.stack.3d.up.slash",
                        description: Text("Save some words in Dictionary or My Words, then come back to build sentences with them ✦")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            RetroTitleBar(title: "SENTENCE BUILDER", accent: Theme.magenta)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            // Your sentence — words you've tapped, in order.
                            VStack(alignment: .leading, spacing: 10) {
                                Text("YOUR SENTENCE")
                                    .font(.caption2.weight(.bold))
                                    .tracking(1.2)
                                    .foregroundStyle(Theme.magenta)

                                if built.isEmpty {
                                    Text("Tap words below to build a sentence — tap a word here to undo it.")
                                        .font(.footnote)
                                        .foregroundStyle(Theme.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 12)
                                } else {
                                    FlowLayout(spacing: 8) {
                                        ForEach(built) { word in
                                            Button {
                                                withAnimation(.spring(response: 0.3)) { returnToBank(word) }
                                            } label: {
                                                wordChipLabel(word)
                                            }
                                            .buttonStyle(WordChipStyle(color: Theme.magenta))
                                        }
                                    }

                                    // Instant, offline literal reading — updates live as you build,
                                    // no button, no network, no AI. This is the core of the feature.
                                    if !localReading.isEmpty {
                                        Text(localReading)
                                            .font(.footnote.weight(.medium))
                                            .foregroundStyle(Theme.turquoise)
                                            .padding(.top, 4)
                                            .transition(.opacity)
                                    }
                                }
                            }
                            .padding()
                            .y2kCard()
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.2), value: built)

                            // Word bank — your saved vocabulary, grouped by how well you know it.
                            ForEach(bankByCategory, id: \.label) { group in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Circle().fill(color(for: group.label)).frame(width: 7, height: 7)
                                        Text(group.label.uppercased())
                                            .font(.caption2.weight(.bold))
                                            .tracking(1.2)
                                            .foregroundStyle(color(for: group.label))
                                    }

                                    FlowLayout(spacing: 8) {
                                        ForEach(group.words) { word in
                                            Button {
                                                withAnimation(.spring(response: 0.3)) { addToSentence(word) }
                                            } label: {
                                                wordChipLabel(word)
                                            }
                                            .buttonStyle(WordChipStyle(color: color(for: group.label)))
                                        }
                                    }
                                }
                                .padding()
                                .y2kCard()
                                .padding(.horizontal)
                            }

                            HStack(spacing: 12) {
                                Button("Reset") {
                                    withAnimation { loadBank() }
                                }
                                .buttonStyle(Y2KButtonStyle(filled: false))

                                // Optional AI "does this sound natural?" — only shown once you've
                                // added a key in Settings. Everything above works without it.
                                if hasAPIKey {
                                    Button {
                                        Task { await checkWithAI() }
                                    } label: {
                                        if isChecking {
                                            ProgressView().tint(Theme.background)
                                        } else {
                                            Text("Ask AI: sound natural?")
                                        }
                                    }
                                    .buttonStyle(Y2KButtonStyle(filled: true))
                                    .disabled(built.isEmpty || isChecking)
                                } else if !built.isEmpty {
                                    Button {
                                        markPracticed()
                                    } label: {
                                        Text("Nice! ✦")
                                    }
                                    .buttonStyle(Y2KButtonStyle(filled: true))
                                }
                            }
                            .padding(.horizontal)

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            if let practiceConfirmation {
                                confirmationCard(practiceConfirmation)
                                    .padding(.horizontal)
                            }

                            if let aiResult {
                                resultCard(aiResult)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }

                if celebrate {
                    SparkleBurst()
                }
            }
            .navigationTitle("Practice")
            .onAppear {
                loadBank()
                hasAPIKey = !(KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey) ?? "").isEmpty
            }
        }
    }

    private func wordChipLabel(_ word: ChineseWord) -> some View {
        VStack(spacing: 1) {
            Text(word.hanzi)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(word.pinyinDisplay)
                .font(.system(size: 10, weight: .medium))
                .opacity(0.85)
        }
    }

    private func color(for masteryLabel: String) -> Color {
        switch masteryLabel {
        case "Mastered": return Theme.lime
        case "Familiar": return Theme.turquoise
        case "Learning": return Theme.amber
        default: return Theme.purple // "New"
        }
    }

    private func confirmationCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.lime)
                Text("Nice! Here's your sentence")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
            }
            Text(text)
                .font(.body)
                .foregroundStyle(Theme.turquoise)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .y2kCard()
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    private func resultCard(_ result: SentenceCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: result.isNatural ? "checkmark.seal.fill" : "questionmark.circle.fill")
                    .foregroundStyle(result.isNatural ? Theme.lime : Theme.amber)
                Text(result.isNatural ? "Looks natural!" : "Not quite standard yet")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
            }
            Text(result.translation)
                .font(.body)
                .foregroundStyle(Theme.turquoise)
            Text(result.feedback)
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .y2kCard()
    }

    private func loadBank() {
        // Learned words only — this screen used to fall back to the full seed
        // dictionary when you had nothing saved yet, which made it look like
        // it was full of words you'd never actually learned. Now it's purely
        // whatever's in My Words, and shows the empty state otherwise.
        bank = WordStore.loadAll()
        built = []
        aiResult = nil
        errorMessage = nil
        practiceConfirmation = nil
    }

    private func addToSentence(_ word: ChineseWord) {
        guard let idx = bank.firstIndex(of: word) else { return }
        bank.remove(at: idx)
        built.append(word)
        practiceConfirmation = nil
        aiResult = nil
    }

    private func returnToBank(_ word: ChineseWord) {
        guard let idx = built.firstIndex(of: word) else { return }
        built.remove(at: idx)
        bank.append(word)
        practiceConfirmation = nil
        aiResult = nil
    }

    /// No-AI path: a real, visible confirmation — not just a brief sparkle
    /// that's easy to miss — showing exactly what you just built.
    private func markPracticed() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            practiceConfirmation = "\(built.map(\.hanzi).joined())  —  \(localReading)"
        }
        celebrate = true
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            celebrate = false
        }
    }

    private func checkWithAI() async {
        errorMessage = nil
        aiResult = nil
        practiceConfirmation = nil
        isChecking = true
        defer { isChecking = false }

        let sentence = built.map(\.hanzi).joined()
        do {
            let outcome = try await SentenceChecker.check(sentence)
            aiResult = outcome
            if outcome.isNatural {
                celebrate = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_100_000_000)
                    celebrate = false
                }
            }
        } catch SentenceChecker.CheckError.missingAPIKey {
            errorMessage = "Add a free Anthropic API key in Settings to check sentences — everything else in the app works without it."
        } catch {
            errorMessage = "Couldn't check that sentence. Check your connection and try again."
        }
    }
}
