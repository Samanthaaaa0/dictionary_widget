import Foundation

/// Looks up words first in the full CC-CEDICT file (if you've bundled one —
/// see README), then falls back to the small built-in SeedDictionary.
/// If neither has the word, AddWordView offers manual entry (or AI, if you've
/// set up a key later).
final class DictionaryLookup {
    static let shared = DictionaryLookup()

    /// What happened the last time loadIfNeeded() ran — check this from
    /// Settings (or the console) if search still only shows the ~56 seed
    /// words after bundling cedict_ts.u8. Parsing fails silently otherwise,
    /// which makes a bundling mistake very hard to tell apart from "it just
    /// doesn't have that word."
    enum LoadStatus {
        case notLoadedYet
        case fileNotFoundInBundle
        case loaded(entryCount: Int)
    }

    private(set) var loadStatus: LoadStatus = .notLoadedYet

    private var entries: [String: CEDICTEntry] = [:]
    private var isLoaded = false

    private init() {}

    /// Call once at launch (see CiCiDictApp.swift). Parsing ~120k lines is fast,
    /// but it's still done off the main thread.
    func loadIfNeeded() async {
        guard !isLoaded else { return }
        guard let url = Bundle.main.url(forResource: "cedict_ts", withExtension: "u8") else {
            // This is the #1 symptom of "I bundled the file but search still
            // shows only the old words": Bundle.main can't find a file named
            // EXACTLY cedict_ts.u8 with Target Membership checked for the
            // CiCiDict app (not just added to the project, and not the widget).
            // A very common trap: Finder silently naming it "cedict_ts.u8.txt".
            print("⚠️ CiCiDict: cedict_ts.u8 not found in app bundle — using the small built-in dictionary only.")
            loadStatus = .fileNotFoundInBundle
            isLoaded = true
            return
        }
        let parsed = await Task.detached(priority: .utility) {
            CEDICTParser.parse(fileURL: url)
        }.value
        entries = parsed
        // parsed contains each entry keyed by BOTH simplified and traditional,
        // so the true entry count is roughly half this number — still, 0 or a
        // suspiciously tiny number here means parsing failed, not that the
        // file is genuinely empty.
        print("✅ CiCiDict: loaded \(parsed.count) dictionary keys from cedict_ts.u8.")
        loadStatus = .loaded(entryCount: parsed.count)
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
                source: .dictionary,
                allDefinitions: entry.definitions
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
                    source: .dictionary,
                    allDefinitions: entry.definitions
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

    /// A deterministic pick from the full bundled dictionary, skipping
    /// anything already saved — used by DailyWordService once you've saved
    /// every seed word, so there's still something new to offer each day.
    func deterministicUnseenWord(excluding saved: Set<String>, day: Int) -> ChineseWord? {
        guard !entries.isEmpty else { return nil }
        let keys = entries.keys.sorted()
        guard !keys.isEmpty else { return nil }
        for offset in 0..<keys.count {
            let key = keys[(day + offset) % keys.count]
            if !saved.contains(key), let entry = entries[key] {
                return ChineseWord(
                    hanzi: entry.simplified,
                    pinyinNumbered: entry.pinyinNumbered,
                    englishShort: Self.shorten(entry.definitions),
                    source: .dictionary,
                    allDefinitions: entry.definitions
                )
            }
        }
        return nil
    }

    /// Keeps things short and widget-friendly — just the first sense or two,
    /// with any "(...)" asides (usage notes, region tags, etc.) stripped out.
    /// The full raw definitions are kept separately in allDefinitions so
    /// Details can still show that nuance, just not crammed into one line.
    private static func shorten(_ defs: [String]) -> String {
        let cleaned = GlossFormatter.cleanList(defs)
        let picked = cleaned.prefix(2).map(\.text).joined(separator: "; ")
        return picked.count > 60 ? String(picked.prefix(57)) + "…" : picked
    }
}
