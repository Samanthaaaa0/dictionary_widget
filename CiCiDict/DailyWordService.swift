import Foundation

/// Runs once per calendar day: picks a word you haven't saved yet and adds
/// it straight into My Words (and therefore the Review queue), instead of
/// the widget just *showing* a new word each day without it ever counting
/// for anything. Seed words go first since they're curated for a beginner;
/// once you've saved all of those, it deterministically picks from the full
/// bundled dictionary (if you've added cedict_ts.u8) so there's always
/// something new.
enum DailyWordService {
    private static let lastRunDayKey = "cicidict.dailyWord.lastRunDay"
    private static let lastAddedHanziKey = "cicidict.dailyWord.lastAddedHanzi"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.id) ?? .standard
    }

    /// Call after DictionaryLookup has finished loading (see CiCiDictApp).
    /// Safe to call on every launch — it only actually adds a new word the
    /// first time it runs each day; later calls that same day just return
    /// the word it already picked, without re-rolling.
    @discardableResult
    static func ensureTodaysWordAdded(on date: Date = Date()) -> ChineseWord? {
        let today = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0

        if defaults.integer(forKey: lastRunDayKey) == today,
           let hanzi = defaults.string(forKey: lastAddedHanziKey),
           let existing = WordStore.loadAll().first(where: { $0.hanzi == hanzi }) {
            return existing
        }

        guard let word = pickTodaysWord(day: today) else { return nil }
        WordStore.add(HSKWordList.apply(to: word))
        defaults.set(today, forKey: lastRunDayKey)
        defaults.set(word.hanzi, forKey: lastAddedHanziKey)
        return word
    }

    private static func pickTodaysWord(day: Int) -> ChineseWord? {
        let savedHanzi = Set(WordStore.loadAll().map(\.hanzi))

        // Curated beginner words first — friendlier than a random pull from
        // 120k+ CC-CEDICT entries of wildly varying rarity and usefulness.
        let unseenSeed = SeedDictionary.words.filter { !savedHanzi.contains($0.hanzi) }
        if !unseenSeed.isEmpty {
            return unseenSeed[day % unseenSeed.count]
        }

        return DictionaryLookup.shared.deterministicUnseenWord(excluding: savedHanzi, day: day)
    }
}
