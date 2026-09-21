import AVFoundation

/// Reads a Chinese word aloud using the on-device Mandarin voice.
/// No network or API key required.
final class SpeechHelper {
    static let shared = SpeechHelper()
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ hanzi: String) {
        let utterance = AVSpeechUtterance(string: hanzi)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.42
        synthesizer.speak(utterance)
    }
}
