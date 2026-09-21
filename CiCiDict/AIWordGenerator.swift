import Foundation

/// Fallback for words not found in the local CC-CEDICT / seed dictionary.
/// Calls the Claude API directly from the device using a key the user
/// pastes into Settings (stored in the Keychain — never hardcode a key here).
enum AIWordGenerator {
    enum GenerationError: Error { case missingAPIKey, badResponse, decodingFailed }

    static func generate(for hanzi: String) async throws -> ChineseWord {
        guard let apiKey = KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey), !apiKey.isEmpty else {
            throw GenerationError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let systemPrompt = """
        You are a Chinese dictionary generator. Given a Chinese word or phrase, respond with ONLY \
        a single-line JSON object, no markdown formatting, no extra text, in exactly this shape:
        {"hanzi":"<the word, simplified characters>","pinyin":"<numbered pinyin, syllables space \
        separated, e.g. \\"ni3 hao3\\"; use tone number 5 for a neutral tone>","english":"<a short \
        2-6 word gloss, not a full sentence>"}
        If the input isn't a real Chinese word, make your best reasonable guess rather than refusing.
        """

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 200,
            "system": systemPrompt,
            "messages": [["role": "user", "content": hanzi]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw GenerationError.badResponse
        }

        struct APIResponse: Decodable {
            struct Block: Decodable { let type: String; let text: String? }
            let content: [Block]
        }
        struct WordJSON: Decodable { let hanzi: String; let pinyin: String; let english: String }

        let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
        guard let text = decoded.content.first(where: { $0.type == "text" })?.text else {
            throw GenerationError.decodingFailed
        }

        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let jsonData = cleaned.data(using: .utf8),
              let wordJSON = try? JSONDecoder().decode(WordJSON.self, from: jsonData) else {
            throw GenerationError.decodingFailed
        }

        return ChineseWord(
            hanzi: wordJSON.hanzi,
            pinyinNumbered: wordJSON.pinyin,
            englishShort: wordJSON.english,
            source: .ai
        )
    }
}
