import SwiftUI

/// A simple, user-assigned category — no AI, no auto-detection, just a
/// preset list you pick from when saving or reviewing a word. Exists mainly
/// so My Words stays browsable instead of turning into one long list once
/// you've saved a lot of vocabulary.
enum WordCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case uncategorized
    case greetings
    case people
    case family
    case food
    case travel
    case numbers
    case time
    case emotions
    case body
    case animals
    case colors
    case school
    case work
    case nature
    case objects

    var id: String { rawValue }

    var label: String {
        switch self {
        case .uncategorized: return "Uncategorized"
        case .greetings: return "Greetings"
        case .people: return "People"
        case .family: return "Family"
        case .food: return "Food & Drink"
        case .travel: return "Travel"
        case .numbers: return "Numbers"
        case .time: return "Time"
        case .emotions: return "Emotions"
        case .body: return "Body & Health"
        case .animals: return "Animals"
        case .colors: return "Colors"
        case .school: return "School"
        case .work: return "Work"
        case .nature: return "Nature"
        case .objects: return "Objects"
        }
    }

    var icon: String {
        switch self {
        case .uncategorized: return "questionmark.circle.fill"
        case .greetings: return "hand.wave.fill"
        case .people: return "person.2.fill"
        case .family: return "house.fill"
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .numbers: return "number"
        case .time: return "clock.fill"
        case .emotions: return "face.smiling.fill"
        case .body: return "heart.text.square.fill"
        case .animals: return "pawprint.fill"
        case .colors: return "paintpalette.fill"
        case .school: return "graduationcap.fill"
        case .work: return "briefcase.fill"
        case .nature: return "leaf.fill"
        case .objects: return "shippingbox.fill"
        }
    }

    var color: Color {
        switch self {
        case .uncategorized: return Theme.textSecondary
        case .greetings, .numbers, .school: return Theme.turquoise
        case .people, .emotions, .colors: return Theme.magenta
        case .family, .time, .work: return Theme.amber
        case .food, .body, .nature: return Theme.lime
        case .travel, .animals, .objects: return Theme.purple
        }
    }
}
