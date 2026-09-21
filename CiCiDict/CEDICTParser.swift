import Foundation

struct CEDICTEntry {
    let traditional: String
    let simplified: String
    let pinyinNumbered: String
    let definitions: [String]
}

/// Parses the standard CC-CEDICT text format:
/// TRAD SIMP [pin1 yin1] /definition 1/definition 2/.../
enum CEDICTParser {
    static func parse(fileURL: URL) -> [String: CEDICTEntry] {
        guard let text = try? String(contentsOf: fileURL, encoding: .utf8) else { return [:] }
        var map: [String: CEDICTEntry] = [:]
        for line in text.split(separator: "\n") {
            if line.hasPrefix("#") { continue }
            guard let entry = parseLine(String(line)) else { continue }
            // Key by both simplified and traditional so lookups work either way.
            // Keep the first (most common, per CC-CEDICT ordering) sense for duplicates.
            if map[entry.simplified] == nil { map[entry.simplified] = entry }
            if map[entry.traditional] == nil { map[entry.traditional] = entry }
        }
        return map
    }

    private static func parseLine(_ line: String) -> CEDICTEntry? {
        guard let bracketOpen = line.firstIndex(of: "["),
              let bracketClose = line.firstIndex(of: "]"),
              bracketOpen < bracketClose else { return nil }

        let head = line[line.startIndex..<bracketOpen].trimmingCharacters(in: .whitespaces)
        let headParts = head.split(separator: " ", maxSplits: 1)
        guard headParts.count == 2 else { return nil }
        let traditional = String(headParts[0])
        let simplified = String(headParts[1])

        let pinyin = line[line.index(after: bracketOpen)..<bracketClose]
            .trimmingCharacters(in: .whitespaces)

        let rest = line[line.index(after: bracketClose)...]
        let defs = rest.split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return CEDICTEntry(traditional: traditional, simplified: simplified, pinyinNumbered: pinyin, definitions: defs)
    }
}
