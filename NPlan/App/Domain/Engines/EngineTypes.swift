import Foundation

struct StrategyConfig {
    let progressionModel: String // Linear, Wave, Block
    let volMin: Int
    let volMax: Int
    let repRangeCompound: (Int, Int)
    let repRangeIsolation: (Int, Int)
    let cycleDurationWeeks: Int
}

enum SlotType: String, Codable {
    case compound = "Compound"
    case isolation = "Isolation"
    case machine = "Machine" // Sometimes treated same as Isolation
}

struct DailySlot {
    let requiredType: SlotType
    let requiredPattern: String? // e.g., "Push_Horizontal", "Squat"
    let targetMuscle: String? // e.g., "Triceps"
    let defaultSets: Int
}

struct SplitTemplate {
    let name: String
    let description: String
    let days: [SplitDay]
}

struct SplitDay {
    let name: String // e.g., "Upper Power"
    let slots: [DailySlot]
}
