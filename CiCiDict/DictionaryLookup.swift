import Foundation

/// Looks up words first in the full CC-CEDICT file (if you've bundled one —
/// see README), then falls back to the small built-in SeedDictionary.
/// If neither has the word, AddWordView offers manual entry (or AI, if you've
/// set up a key later).
final class DictionaryLookup {
    static let shared = DictionaryLookup()

    private var entries: [String: CEDICTEntry] = [:]
    private var isLoaded = false

    private init() {}

    /// Call once at launch (see CiCiDictApp.swift). Parsing ~120k lines is fast,
    /// but it's still done off the main thread.
    func loadIfNeeded() async {
        guard !isLoaded else { return }
        if let url = Bundle.main.url(forResource: "cedict_ts", withExtension: "u8") {
            entries = await Task.detached(priority: .utility) {
                CEDICTParser.parse(fileURL: url)
            }.value
        }
        isLoaded = true
    }

    /// Exact-match lookup by hanzi.
    func lookup(_ hanzi: String) -> ChineseWord? {
        let trimmed = hanzi.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let entry = entries[trimmed] {
            return ChineseWord(
                hanzi: entry.simplified,
                pinyinNumbered: entry.pinyinNumbered,
                englishShort: Self.shorten(entry.definitions),
                source: .dictionary
            )
        }
        return SeedDictionary.words.first { $0.hanzi == trimmed }
    }

    /// Fuzzy search across hanzi, pinyin, and English — for browsing in the
    /// Dictionary tab. Exact hanzi match comes first, then substring matches.
    func search(_ query: String, limit: Int = 40) -> [ChineseWord] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        var results: [ChineseWord] = []
        var seen = Set<String>()

        if let exact = lookup(q) {
            results.append(exact)
            seen.insert(exact.hanzi)
        }

        for entry in entries.values {
            if results.count >= limit { break }
            guard !seen.contains(entry.simplified) else { continue }
            let matches = entry.simplified.contains(q)
                || entry.traditional.contains(q)
                || entry.pinyinNumbered.localizedCaseInsensitiveContains(q)
                || entry.definitions.contains { $0.localizedCaseInsensitiveContains(q) }
            if matches {
                seen.insert(entry.simplified)
                results.append(ChineseWord(
                    hanzi: entry.simplified,
                    pinyinNumbered: entry.pinyinNumbered,
                    englishShort: Self.shorten(entry.definitions),
                    source: .dictionary
                ))
            }
        }

        for seedWord in SeedDictionary.words {
            if results.count >= limit { break }
            guard !seen.contains(seedWord.hanzi) else { continue }
            if seedWord.hanzi.contains(q)
                || seedWord.pinyinDisplay.localizedCaseInsensitiveContains(q)
                || seedWord.englishShort.localizedCaseInsensitiveContains(q) {
                seen.insert(seedWord.hanzi)
                results.append(seedWord)
            }
        }

        return results
    }

    /// Keeps things short and widget-friendly — just the first sense or two.
    private static func shorten(_ defs: [String]) -> String {
        let picked = defs.prefix(2).joined(separator: "; ")
        return picked.count > 60 ? String(picked.prefix(57)) + "…" : picked
    }
}
