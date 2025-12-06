import Foundation
//import EngineTypes

class ProgressionEngine {
    static func getSets(week: Int, strategy: StrategyConfig, slotType: SlotType) -> Int {
        switch strategy.progressionModel {
        case "Linear":
            return 3 // Constant sets for linear
        case "Wave":
            switch week {
            case 1, 2, 3: return 3 // 3 working sets
            case 4: return 2 // Deload sets
            default: return 3
            }
        default:
            return 3 // Default for other models or as fallback
        }
    }

    static func getReps(week: Int, strategy: StrategyConfig, slotType: SlotType) -> String {
        let baseRepRange = (slotType == .compound) ? strategy.repRangeCompound : strategy.repRangeIsolation

        switch strategy.progressionModel {
        case "Linear":
            // Stable reps for linear progression
            return "\(baseRepRange.0)-\(baseRepRange.1)"
        case "Wave":
            switch week {
            case 1: // Week 1: Higher reps
                return "\(baseRepRange.0 + 2)-\(baseRepRange.1 + 2)"
            case 2: // Week 2: Mid reps
                return "\(baseRepRange.0)-\(baseRepRange.1)"
            case 3: // Week 3: Lower reps
                return "\(max(baseRepRange.0 - 2, 1))-\(max(baseRepRange.1 - 2, 1))"
            case 4: // Week 4: Deload - even lower reps or just a range
                return "5-8" // Example deload rep range
            default:
                return "\(baseRepRange.0)-\(baseRepRange.1)"
            }
        default:
            return "\(baseRepRange.0)-\(baseRepRange.1)" // Default for other models or as fallback
        }
    }

    static func getLoadInstruction(week: Int, strategy: StrategyConfig) -> String {
        switch strategy.progressionModel {
        case "Linear":
            // Progressing RPE for linear
            switch week {
            case 1: return "RPE 7"
            case 2: return "RPE 8"
            case 3: return "RPE 9"
            case 4: return "RPE 7" // Reset or slight deload
            default: return "RPE 7"
            }
        case "Wave":
            // RPE usually increases as reps decrease
            switch week {
            case 1: return "RPE 6-7"
            case 2: return "RPE 7-8"
            case 3: return "RPE 8-9"
            case 4: return "RPE 5-6 (Deload)"
            default: return "RPE 7"
            }
        default:
            return "RPE 7" // Default for other models or as fallback
        }
    }
}
