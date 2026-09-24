import Foundation

struct SentenceCheckResult: Decodable {
    let translation: String
    let isNatural: Bool
    let feedback: String
}

/// Checks a sentence the learner built from words they already know.
/// This genuinely needs a language model — a dictionary alone can't judge
/// whether word order makes sense — so it uses the same optional Anthropic
/// API key as AIWordGenerator. If no key is set, the UI just explains that
/// and everything else in the app keeps working without it.
enum SentenceChecker {
    enum CheckError: Error { case missingAPIKey, badResponse, decodingFailed }

    static func check(_ sentence: String) async throws -> SentenceCheckResult {
        guard let apiKey = KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey), !apiKey.isEmpty else {
            throw CheckError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let systemPrompt = """
        You are a friendly, encouraging Chinese tutor for beginners. The learner built a \
        sentence by tapping together words they've already learned — it may be in the wrong \
        order, or not a real sentence at all, and that's a normal part of practicing word order. \
        Respond with ONLY a single-line JSON object, no markdown, no extra text, in exactly this \
        shape: {"translation":"<your best-effort literal English reading, or a short note like \
        \\"not a standard sentence\\" if it truly can't be read as one>","isNatural":true or \
        false,"feedback":"<one short, encouraging, beginner-friendly sentence — if isNatural is \
        false, gently point toward the natural word order>"}
        """

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 250,
            "system": systemPrompt,
            "messages": [["role": "user", "content": sentence]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw CheckError.badResponse
        }

        struct APIResponse: Decodable {
            struct Block: Decodable { let type: String; let text: String? }
            let content: [Block]
        }

        let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
        guard let text = decoded.content.first(where: { $0.type == "text" })?.text else {
            throw CheckError.decodingFailed
        }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let jsonData = cleaned.data(using: .utf8),
              let result = try? JSONDecoder().decode(SentenceCheckResult.self, from: jsonData) else {
            throw CheckError.decodingFailed
        }
        return result
    }
}
