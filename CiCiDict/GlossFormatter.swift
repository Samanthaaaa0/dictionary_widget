import Foundation

/// CC-CEDICT definitions are often cluttered with parenthetical asides —
/// "(coll.) A-list; top-tier", "(Internet slang) thank you (loanword)" — which
/// read fine in a dictionary but look messy in a one-line list row. This pulls
/// those asides out so short views can stay clean, while Details can still
/// show them as small, readable tags instead of losing the nuance entirely.
enum GlossFormatter {
    struct Cleaned {
        let text: String     // gloss with "(...)" content removed
        let notes: [String]  // whatever was inside those parentheses, in order
    }

    static func clean(_ raw: String) -> Cleaned {
        var notes: [String] = []
        var result = ""
        var depth = 0
        var buffer = ""

        for ch in raw {
            if ch == "(" {
                depth += 1
                if depth == 1 { buffer = ""; continue }
            }
            if ch == ")" {
                if depth == 1 {
                    let trimmed = buffer.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty { notes.append(trimmed) }
                }
                depth = max(0, depth - 1)
                continue
            }
            if depth > 0 {
                buffer.append(ch)
            } else {
                result.append(ch)
            }
        }

        let cleanedText = result
            .replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+([,;.])"#, with: "$1", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ",;"))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Cleaned(text: cleanedText, notes: notes)
    }

    /// Cleans a whole list of senses (CC-CEDICT entries can have several),
    /// dropping any sense that turns out to be empty once parens are removed
    /// (rare — happens if a "sense" was only ever a parenthetical note).
    static func cleanList(_ raw: [String]) -> [Cleaned] {
        raw.map(clean).filter { !$0.text.isEmpty }
    }
}
