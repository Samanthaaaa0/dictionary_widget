import WidgetKit

struct WordEntry: TimelineEntry {
    let date: Date
    let word: ChineseWord
}

struct CiCiWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: SeedDictionary.words[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        let words = WordStore.loadAll()
        let word = WordStore.wordOfDay(from: words) ?? SeedDictionary.words[0]
        completion(WordEntry(date: Date(), word: word))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let words = WordStore.loadAll()
        let calendar = Calendar.current
        var entries: [WordEntry] = []

        // Pre-compute the next 7 days so the widget updates itself daily
        // without needing the app to be opened.
        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: Date()) else { continue }
            let word = WordStore.wordOfDay(from: words, on: date) ?? SeedDictionary.words[0]
            entries.append(WordEntry(date: calendar.startOfDay(for: date), word: word))
        }

        let refreshDate = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}
