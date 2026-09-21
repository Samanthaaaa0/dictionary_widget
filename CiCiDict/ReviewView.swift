import SwiftUI

struct ReviewView: View {
    @State private var queue: [ChineseWord] = []
    @State private var revealed = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

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

                        card

                        Spacer()

                        if revealed {
                            HStack(spacing: 16) {
                                Button("Still learning") { answer(correct: false) }
                                    .buttonStyle(Y2KButtonStyle(filled: false))
                                Button("Got it") { answer(correct: true) }
                                    .buttonStyle(Y2KButtonStyle(filled: true))
                            }
                        } else {
                            Button("Reveal") {
                                withAnimation(.spring(response: 0.35)) { revealed = true }
                            }
                            .buttonStyle(Y2KButtonStyle(filled: true))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Review")
            .onAppear(perform: loadQueue)
        }
    }

    private var card: some View {
        VStack(spacing: 16) {
            Text(queue[0].hanzi)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            if revealed {
                Text(queue[0].pinyinDisplay)
                    .font(.title3)
                    .foregroundStyle(Theme.turquoise)
                Text(queue[0].englishShort)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .y2kCard(cornerRadius: 28)
        .padding(.horizontal)
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
    }
}
