import Foundation

/// Automatic categorization with zero AI — just a lookup against the
/// official HSK vocabulary standard, the same way a paper flashcard box
/// might be labeled "HSK 1." Currently ships with the full HSK 1 list
/// (150 words). Add HSK 2–6 the same way later: another Set, another
/// case in `level(for:)`, checked in order.
///
/// Source: the standard HSK 1 (HSK 2.0) vocabulary list, commonly
/// referenced in Chinese-learning resources (e.g. AllSet Learning's
/// Vocabulary Wiki, CC BY-NC). If you publish this app, credit that
/// alongside your CC-CEDICT attribution in Settings.
enum HSKWordList {
    static func level(for hanzi: String) -> Int? {
        if level1.contains(hanzi) { return 1 }
        return nil
    }

    /// Sets hskLevel on a word if it matches a bundled list and doesn't
    /// already have one set (so it never clobbers a manual override).
    static func apply(to word: ChineseWord) -> ChineseWord {
        guard word.hskLevel == nil else { return word }
        var updated = word
        updated.hskLevel = level(for: word.hanzi)
        return updated
    }

    /// Goes through every saved word and backfills hskLevel for any that
    /// don't have one yet — covers words you saved before this feature
    /// existed, or before you added HSK2+ lists later.
    static func backfillSavedWords() {
        let words = WordStore.loadAll()
        var changed = false
        var updated = words
        for i in updated.indices where updated[i].hskLevel == nil {
            if let level = level(for: updated[i].hanzi) {
                updated[i].hskLevel = level
                changed = true
            }
        }
        if changed { WordStore.save(updated) }
    }

    static let level1: Set<String> = [
        "大", "多", "高兴", "好", "冷", "漂亮", "热", "少", "小",
        "不", "没有", "很", "太", "都",
        "会", "能", "想",
        "和",
        "这", "那", "喂", "多少", "几", "哪", "哪儿", "什么", "谁", "怎么", "怎么样",
        "本", "个", "块", "岁", "些", "一点儿",
        "爸爸", "北京", "杯子", "菜", "茶", "出租车", "点", "电脑", "电视", "电影",
        "东西", "儿子", "饭店", "飞机", "分钟", "狗", "汉语", "后面", "家", "今天",
        "老师", "里面", "妈妈", "猫", "米饭", "明天", "名字", "年", "女儿", "朋友",
        "苹果", "钱", "前面", "人", "上", "商店", "上午", "时候", "书", "水",
        "水果", "天气", "同学", "下", "先生", "现在", "小姐", "下午", "星期",
        "学生", "学校", "衣服", "医生", "医院", "椅子", "月", "中国", "中午",
        "桌子", "字", "昨天",
        "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "号",
        "的", "了", "吗", "呢", "你", "他", "她", "我", "我们",
        "不客气", "打电话", "没关系",
        "在", "爱", "吃", "读", "对不起", "工作", "喝", "回", "叫", "开",
        "看", "看见", "来", "买", "请", "去", "认识", "是", "睡觉", "说",
        "听", "下雨", "写", "谢谢", "喜欢", "学习", "有", "再见", "住", "做", "坐"
    ]
}
