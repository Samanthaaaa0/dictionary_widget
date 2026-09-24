import Foundation

/// A fully local, offline "read my sentence" for the word-order practice
/// game — no API key, no network call. It glues together the English
/// glosses of the words you tapped, in the order you tapped them, so you
/// can eyeball whether your word order reads sensibly.
///
/// This is intentionally NOT a grammar checker — it can't tell you if the
/// order is "correct" Chinese, only show a literal, word-by-word reading of
/// what you built. That matches how the feature was described: build a
/// sentence, see a translation, judge for yourself if it makes sense.
/// (SentenceChecker.swift is still there as an optional AI upgrade later,
/// behind the same opt-in API key as AIWordGenerator — nothing here needs it.)
enum LocalSentenceTranslator {
    static func translate(_ words: [ChineseWord]) -> String {
        guard !words.isEmpty else { return "" }
        return words.map { firstGloss($0.englishShort) }.joined(separator: " · ")
    }

    /// englishShort can be "very; extremely" — take just the first sense
    /// so the literal reading doesn't get cluttered.
    private static func firstGloss(_ gloss: String) -> String {
        gloss.split(separator: ";").first.map { $0.trimmingCharacters(in: .whitespaces) } ?? gloss
    }
}
