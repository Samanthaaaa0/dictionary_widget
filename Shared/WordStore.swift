import Foundation
import WidgetKit

enum AppGroup {
    // ⚠️ Replace with your own App Group ID. Must exactly match the
    // "App Groups" capability you add to BOTH the app target and the
    // widget extension target in Xcode → Signing & Capabilities.
    static let id = "group.com.yourname.cicidict"
}

/// Simple JSON-in-UserDefaults store, shared via App Group so both the
/// app and the widget extension can read/write the same word list.
enum WordStore {
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.id) ?? .standard
    }
    private static let key = "cicidict.savedWords"

    static func loadAll() -> [ChineseWord] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ChineseWord].self, from: data)) ?? []
    }

    static func save(_ words: [ChineseWord]) {
        guard let data = try? JSONEncoder().encode(words) else { return }
        defaults.set(data, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func add(_ word: ChineseWord) {
        var words = loadAll()
        words.removeAll { $0.hanzi == word.hanzi } // no duplicates, keep the newest
        words.insert(word, at: 0)
        save(words)
    }

    static func delete(_ word: ChineseWord) {
        var words = loadAll()
        words.removeAll { $0.id == word.id }
        save(words)
    }

    static func toggleFavorite(_ word: ChineseWord) {
        var words = loadAll()
        if let i = words.firstIndex(where: { $0.id == word.id }) {
            words[i].isFavorite.toggle()
            save(words)
        }
    }

    // MARK: - Widget pinning

    /// Pins a specific word to the widget, overriding the daily rotation.
    /// Adds it to your vocabulary first if it isn't saved yet.
    static func pin(_ word: ChineseWord) {
        var words = loadAll()
        for i in words.indices { words[i].isPinnedToWidget = false }
        if let idx = words.firstIndex(where: { $0.hanzi == word.hanzi }) {
            words[idx].isPinnedToWidget = true
        } else {
            var newWord = word
            newWord.isPinnedToWidget = true
            words.insert(newWord, at: 0)
        }
        save(words)
    }

    static func unpin(_ word: ChineseWord) {
        var words = loadAll()
        if let idx = words.firstIndex(where: { $0.hanzi == word.hanzi }) {
            words[idx].isPinnedToWidget = false
            save(words)
        }
    }

    /// The word the widget should show right now: the pinned word if there is
    /// one, otherwise a deterministic "word of the day" that rotates daily.
    static func wordOfDay(from words: [ChineseWord], on date: Date = Date()) -> ChineseWord? {
        if let pinned = words.first(where: { $0.isPinnedToWidget }) {
            return pinned
        }
        let pool = words.isEmpty ? SeedDictionary.words : words
        guard !pool.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return pool[day % pool.count]
    }

    // MARK: - Review / spaced repetition (simple Leitner system)

    private static let intervalDaysByBox = [0, 1, 3, 7, 14, 30]

    static func wordsDueForReview(from words: [ChineseWord], on date: Date = Date()) -> [ChineseWord] {
        words.filter { word in
            guard let next = word.nextReviewDate else { return true } // never reviewed -> due now
            return next <= date
        }
    }

    static func recordReview(_ word: ChineseWord, correct: Bool) {
        var words = loadAll()
        guard let idx = words.firstIndex(where: { $0.id == word.id }) else { return }

        let newBox = correct ? min(words[idx].reviewBox + 1, intervalDaysByBox.count - 1) : 0
        words[idx].reviewBox = newBox
        words[idx].nextReviewDate = Calendar.current.date(
            byAdding: .day, value: intervalDaysByBox[newBox], to: Date()
        )
        words[idx].timesReviewed += 1
        save(words)
    }
}
