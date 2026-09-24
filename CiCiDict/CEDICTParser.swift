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
        guard let rawText = try? String(contentsOf: fileURL, encoding: .utf8) else {
            print("⚠️ CEDICTParser: couldn't read \(fileURL.lastPathComponent) as UTF-8 text at all — the file is either not text, or Swift can't open it from this path.")
            return [:]
        }
        // IMPORTANT: strip \r before splitting. Swift's String treats a "\r\n"
        // pair as a single Character (grapheme cluster), so on a file with
        // Windows-style line endings, split(separator: "\n") silently matches
        // nothing at all — the whole file comes out as "one line" even though
        // tools like `wc -l` (which count raw bytes) report the real line count.
        // Dropping \r entirely makes this safe regardless of which style the
        // source file uses (\n, \r\n, or even lone \r).
        let text = rawText.replacingOccurrences(of: "\r", with: "")
        print("🔎 CEDICTParser: read \(text.count) characters from \(fileURL.lastPathComponent).")

        var map: [String: CEDICTEntry] = [:]
        var totalLines = 0
        var commentLines = 0
        var unparsedDataLines = 0

        for line in text.split(separator: "\n") {
            totalLines += 1
            if line.hasPrefix("#") { commentLines += 1; continue }
            guard let entry = parseLine(String(line)) else { unparsedDataLines += 1; continue }
            // Key by both simplified and traditional so lookups work either way.
            // Keep the first (most common, per CC-CEDICT ordering) sense for duplicates.
            if map[entry.simplified] == nil { map[entry.simplified] = entry }
            if map[entry.traditional] == nil { map[entry.traditional] = entry }
        }

        print("🔎 CEDICTParser: \(totalLines) lines total, \(commentLines) comment lines, \(unparsedDataLines) lines that looked like data but failed to parse, \(map.count) keys produced.")
        if totalLines <= 1 {
            print("⚠️ CEDICTParser: the whole file came out as \(totalLines) line(s) even after stripping \\r — that's unusual, double-check the file actually contains the dictionary content and isn't empty/corrupted.")
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
