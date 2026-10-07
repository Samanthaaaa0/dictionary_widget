import Foundation

enum PhraseCategory: String, CaseIterable, Identifiable {
    case greetings, food, shopping, gettingAround, help

    var id: String { rawValue }

    var label: String {
        switch self {
        case .greetings: return "Greetings"
        case .food: return "Food & Dining"
        case .shopping: return "Shopping"
        case .gettingAround: return "Getting Around"
        case .help: return "Help & Emergencies"
        }
    }

    var icon: String {
        switch self {
        case .greetings: return "hand.wave.fill"
        case .food: return "fork.knife"
        case .shopping: return "bag.fill"
        case .gettingAround: return "figure.walk"
        case .help: return "cross.case.fill"
        }
    }
}

struct Phrase: Identifiable {
    let id = UUID()
    let hanzi: String
    let pinyinNumbered: String
    let english: String
    let category: PhraseCategory

    var pinyinDisplay: String { PinyinFormatter.toDiacritics(pinyinNumbered) }
}

/// A curated, static set of common two-way phrases — not a translator, since
/// a real one needs either an ML model or a huge hand-built grammar, neither
/// of which is realistic to maintain solo. This covers a lot of the same
/// "how do I say this" need for common situations, with zero AI involved.
enum Phrasebook {
    static let phrases: [Phrase] = [
        Phrase(hanzi: "你好", pinyinNumbered: "ni3 hao3", english: "Hello", category: .greetings),
        Phrase(hanzi: "你好吗？", pinyinNumbered: "ni3 hao3 ma5", english: "How are you?", category: .greetings),
        Phrase(hanzi: "我很好，谢谢", pinyinNumbered: "wo3 hen3 hao3, xie4 xie5", english: "I'm good, thank you", category: .greetings),
        Phrase(hanzi: "你叫什么名字？", pinyinNumbered: "ni3 jiao4 shen2 me5 ming2 zi5", english: "What's your name?", category: .greetings),
        Phrase(hanzi: "很高兴认识你", pinyinNumbered: "hen3 gao1 xing4 ren4 shi5 ni3", english: "Nice to meet you", category: .greetings),
        Phrase(hanzi: "再见", pinyinNumbered: "zai4 jian4", english: "Goodbye", category: .greetings),

        Phrase(hanzi: "我要一杯咖啡", pinyinNumbered: "wo3 yao4 yi4 bei1 ka1 fei1", english: "I'd like a coffee", category: .food),
        Phrase(hanzi: "这个多少钱？", pinyinNumbered: "zhe4 ge4 duo1 shao3 qian2", english: "How much is this?", category: .food),
        Phrase(hanzi: "买单，谢谢", pinyinNumbered: "mai3 dan1, xie4 xie5", english: "Check, please", category: .food),
        Phrase(hanzi: "我不吃辣", pinyinNumbered: "wo3 bu4 chi1 la4", english: "I don't eat spicy food", category: .food),
        Phrase(hanzi: "很好吃！", pinyinNumbered: "hen3 hao3 chi1", english: "It's delicious!", category: .food),

        Phrase(hanzi: "可以便宜一点吗？", pinyinNumbered: "ke3 yi3 pian2 yi5 yi4 dianr3 ma5", english: "Can it be a little cheaper?", category: .shopping),
        Phrase(hanzi: "我只是看看", pinyinNumbered: "wo3 zhi3 shi4 kan4 kan5", english: "I'm just looking", category: .shopping),
        Phrase(hanzi: "我要这个", pinyinNumbered: "wo3 yao4 zhe4 ge4", english: "I want this one", category: .shopping),
        Phrase(hanzi: "可以刷卡吗？", pinyinNumbered: "ke3 yi3 shua1 ka3 ma5", english: "Can I pay by card?", category: .shopping),

        Phrase(hanzi: "洗手间在哪儿？", pinyinNumbered: "xi3 shou3 jian1 zai4 nar3", english: "Where's the bathroom?", category: .gettingAround),
        Phrase(hanzi: "我要去机场", pinyinNumbered: "wo3 yao4 qu4 ji1 chang3", english: "I want to go to the airport", category: .gettingAround),
        Phrase(hanzi: "请等一下", pinyinNumbered: "qing3 deng3 yi2 xia4", english: "Please wait a moment", category: .gettingAround),
        Phrase(hanzi: "我迷路了", pinyinNumbered: "wo3 mi2 lu4 le5", english: "I'm lost", category: .gettingAround),
        Phrase(hanzi: "离这儿远吗？", pinyinNumbered: "li2 zhe4r yuan3 ma5", english: "Is it far from here?", category: .gettingAround),

        Phrase(hanzi: "救命！", pinyinNumbered: "jiu4 ming4", english: "Help!", category: .help),
        Phrase(hanzi: "我需要帮助", pinyinNumbered: "wo3 xu1 yao4 bang1 zhu4", english: "I need help", category: .help),
        Phrase(hanzi: "请叫医生", pinyinNumbered: "qing3 jiao4 yi1 sheng1", english: "Please call a doctor", category: .help),
        Phrase(hanzi: "我不舒服", pinyinNumbered: "wo3 bu4 shu1 fu5", english: "I don't feel well", category: .help),
        Phrase(hanzi: "我听不懂", pinyinNumbered: "wo3 ting1 bu5 dong3", english: "I don't understand", category: .help),
    ]
}
