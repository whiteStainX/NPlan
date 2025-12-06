import Foundation
import SwiftData

enum EquipmentType: String, Codable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case cable = "Cable"
    case machine = "Machine"
    case bodyweight = "Bodyweight"
}

enum ExerciseTier: String, Codable {
    case tier1 = "Tier 1" // Primary Compound Lifts
    case tier2 = "Tier 2" // Assistance Lifts, Secondary Compounds
    case tier3 = "Tier 3" // Isolation, Accessory
}

enum PeriodizationPhase: String, Codable {
    case accumulation = "Accumulation"
    case intensification = "Intensification"
    case realization = "Realization"
    case deload = "Deload"
    case general = "General" // For strategies without explicit phases (e.g., Linear)
}

struct StrategyConfig {
    let progressionModel: String // Linear, Wave, Block
    let volMin: Int
    let volMax: Int
    let repRangeCompound: (Int, Int)
    let repRangeIsolation: (Int, Int)
    let cycleDurationWeeks: Int
    let phaseSchedule: [PeriodizationPhase] // NEW: Defines phases per week
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

// NEW: Consolidated input model for the plan generation engine
struct MesocycleBlueprint {
    let userProfile: UserProfile
    let strategy: StrategyConfig
    let splitTemplate: SplitTemplate
}

