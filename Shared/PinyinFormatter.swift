import Foundation

/// Converts CC-CEDICT-style numbered pinyin ("ni3 hao3") into
/// tone-mark pinyin ("nǐ hǎo") for display.
enum PinyinFormatter {

    private static let toneMarks: [Character: [Character]] = [
        "a": ["ā", "á", "ǎ", "à", "a"],
        "e": ["ē", "é", "ě", "è", "e"],
        "i": ["ī", "í", "ǐ", "ì", "i"],
        "o": ["ō", "ó", "ǒ", "ò", "o"],
        "u": ["ū", "ú", "ǔ", "ù", "u"],
        "ü": ["ǖ", "ǘ", "ǚ", "ǜ", "ü"]
    ]

    static func toDiacritics(_ numbered: String) -> String {
        numbered
            .split(separator: " ")
            .map { toneMarkedSyllable(String($0)) }
            .joined(separator: " ")
    }

    private static func toneMarkedSyllable(_ raw: String) -> String {
        var s = raw.lowercased()
            .replacingOccurrences(of: "v", with: "ü")
            .replacingOccurrences(of: "u:", with: "ü")

        guard let last = s.last, let toneDigit = last.wholeNumberValue, (1...5).contains(toneDigit) else {
            // No recognizable tone number (e.g. already a neutral-tone syllable like "de") — return as-is.
            return raw.replacingOccurrences(of: "v", with: "ü")
        }
        s.removeLast()

        // tone 1-4 map to array index 0-3; tone 5 (neutral) maps to the plain vowel at index 4.
        let toneIndex = toneDigit == 5 ? 4 : toneDigit - 1

        guard let markIndex = indexOfVowelToMark(in: Array(s)) else { return s }
        var chars = Array(s)
        let vowel = chars[markIndex]
        if let marks = toneMarks[vowel] {
            chars[markIndex] = marks[toneIndex]
        }
        return String(chars)
    }

    /// Standard pinyin tone-placement rule:
    /// a > e > ou (mark the o) > last of i/o/u/ü
    private static func indexOfVowelToMark(in chars: [Character]) -> Int? {
        if let i = chars.firstIndex(of: "a") { return i }
        if let i = chars.firstIndex(of: "e") { return i }
        if let i = firstIndex(of: Array("ou"), in: chars) { return i } // marks the 'o'
        for i in stride(from: chars.count - 1, through: 0, by: -1) {
            if "iouü".contains(chars[i]) { return i }
        }
        return nil
    }

    private static func firstIndex(of pattern: [Character], in chars: [Character]) -> Int? {
        guard pattern.count <= chars.count else { return nil }
        for i in 0...(chars.count - pattern.count) {
            if Array(chars[i..<(i + pattern.count)]) == pattern { return i }
        }
        return nil
    }
}
