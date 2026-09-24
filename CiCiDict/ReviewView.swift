import SwiftUI

struct ReviewView: View {
    @State private var queue: [ChineseWord] = []
    @State private var revealed = false
    @State private var celebrate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                if queue.isEmpty {
                    ContentUnavailableView(
                        "All caught up ✦",
                        systemImage: "checkmark.seal.fill",
                        description: Text("No words due for review right now.")
                    )
                } else {
                    VStack(spacing: 24) {
                        Text("\(queue.count) due")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.turquoise)
                            .padding(.top, 8)

                        Spacer()

                        flipCard

                        Spacer()

                        if revealed {
                            HStack(spacing: 16) {
                                Button("Still learning") { answer(correct: false) }
                                    .buttonStyle(Y2KButtonStyle(filled: false))
                                Button("Got it") { answer(correct: true) }
                                    .buttonStyle(Y2KButtonStyle(filled: true))
                            }
                        } else {
                            Button("Tap to flip") {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                    revealed = true
                                }
                            }
                            .buttonStyle(Y2KButtonStyle(filled: true))
                        }
                    }
                    .padding()
                }

                if celebrate {
                    SparkleBurst()
                }
            }
            .navigationTitle("Review")
            .onAppear(perform: loadQueue)
        }
    }

    /// A genuine 3D flip: the whole card rotates 180°, and the back face is
    /// pre-rotated 180° so it reads correctly once the flip completes.
    private var flipCard: some View {
        ZStack {
            cardFace {
                Text(queue[0].hanzi)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .y2kFloating()
            }
            .opacity(revealed ? 0 : 1)

            cardFace {
                VStack(spacing: 12) {
                    Text(queue[0].pinyinDisplay)
                        .font(.title2)
                        .foregroundStyle(Theme.turquoise)
                    Text(queue[0].englishShort)
                        .font(.body)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(revealed ? 1 : 0)
        }
        .rotation3DEffect(.degrees(revealed ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                revealed.toggle()
            }
        }
    }

    private func cardFace<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            RetroTitleBar(title: "FLASHCARD")
            content()
                .frame(maxWidth: .infinity, minHeight: 140)
        }
        .padding()
        .y2kCard(cornerRadius: 28)
    }

    private func loadQueue() {
        let words = WordStore.loadAll()
        queue = WordStore.wordsDueForReview(from: words).shuffled()
        revealed = false
    }

    private func answer(correct: Bool) {
        guard !queue.isEmpty else { return }
        let word = queue.removeFirst()
        WordStore.recordReview(word, correct: correct)
        revealed = false

        if correct {
            celebrate = true
            Task {
                try? await Task.sleep(nanoseconds: 900_000_000)
                celebrate = false
            }
        }
    }
}
