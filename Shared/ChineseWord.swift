import Foundation

enum WordSource: String, Codable, Hashable {
    case dictionary
    case ai
    case manual
}

struct ChineseWord: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var hanzi: String
    var pinyinNumbered: String   // e.g. "ni3 hao3"
    var englishShort: String
    var source: WordSource = .dictionary
    var dateAdded: Date = Date()
    var isFavorite: Bool = false

    var category: WordCategory = .uncategorized

    // Every sense from the dictionary entry, raw (parentheses included) — used
    // to show a fuller explanation in Details. englishShort above is already
    // a cleaned, shortened version for list rows. Empty for seed/manual/AI words.
    var allDefinitions: [String] = []

    // Context — shown in the app only, not on the widget.
    var exampleHanzi: String? = nil
    var examplePinyinNumbered: String? = nil
    var exampleEnglish: String? = nil

    // Widget: pin a specific word so it shows instead of the daily rotation.
    var isPinnedToWidget: Bool = false

    // Learning + review system (simple Leitner-style spaced repetition).
    var reviewBox: Int = 0              // 0 = new, higher = better known
    var nextReviewDate: Date? = nil     // nil = never reviewed, due now
    var timesReviewed: Int = 0

    var pinyinDisplay: String {
        PinyinFormatter.toDiacritics(pinyinNumbered)
    }

    var examplePinyinDisplay: String? {
        guard let p = examplePinyinNumbered else { return nil }
        return PinyinFormatter.toDiacritics(p)
    }

    var masteryLabel: String {
        switch reviewBox {
        case 0: return "New"
        case 1, 2: return "Learning"
        case 3, 4: return "Familiar"
        default: return "Mastered"
        }
    }
}
