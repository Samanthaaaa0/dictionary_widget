import AVFoundation

/// Reads a Chinese word aloud using the on-device Mandarin voice.
final class SpeechHelper {
    static let shared = SpeechHelper()
    private let synthesizer = AVSpeechSynthesizer()
    private var sessionConfigured = false

    func speak(_ hanzi: String) {
        configureSessionIfNeeded()

        let utterance = AVSpeechUtterance(string: hanzi)
        utterance.voice = bestAvailableChineseVoice()
        utterance.rate = 0.42

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        synthesizer.speak(utterance)
    }

    /// AVSpeechSynthesizer plays through the "ambient" audio category by
    /// default, which iOS silences whenever the hardware mute switch is on —
    /// that's almost certainly why speech "sometimes doesn't work": it was
    /// always playing, just muted. Using .playback makes pronunciation audible
    /// regardless of the mute switch, the same way a video or podcast app is.
    private func configureSessionIfNeeded() {
        guard !sessionConfigured else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            sessionConfigured = true
        } catch {
            print("⚠️ SpeechHelper: couldn't configure audio session (\(error.localizedDescription)) — playback may stay silent if the mute switch is on.")
        }
    }

    /// Picks the best-quality installed zh-CN voice rather than whatever the
    /// system defaults to. If the person has downloaded an Enhanced/Premium
    /// Chinese voice (Settings → Accessibility → Spoken Content → Voices),
    /// this uses it; otherwise it falls back to the standard compact voice
    /// that ships on every device.
    private func bestAvailableChineseVoice() -> AVSpeechSynthesisVoice? {
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "zh-CN" }
        if let enhanced = candidates.first(where: { $0.quality == .enhanced || $0.quality == .premium }) {
            return enhanced
        }
        if let any = candidates.first { return any }
        // Last resort — the default constructor almost always succeeds since
        // zh-CN ships on every iOS device, but guard against a nil voice
        // silently producing no audio at all.
        return AVSpeechSynthesisVoice(language: "zh-CN")
    }
}
