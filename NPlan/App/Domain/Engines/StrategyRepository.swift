import Foundation

class StrategyRepository {
    static func getStrategy(for age: String) -> StrategyConfig {
        switch age {
        case "Novice":
            return StrategyConfig(
                progressionModel: "Linear",
                volMin: 10,
                volMax: 12,
                repRangeCompound: (5, 5),
                repRangeIsolation: (10, 12),
                cycleDurationWeeks: 4 // Standard block, though linear is continuous
            )
        case "Intermediate":
            return StrategyConfig(
                progressionModel: "Wave",
                volMin: 13,
                volMax: 15,
                repRangeCompound: (6, 8),
                repRangeIsolation: (10, 15),
                cycleDurationWeeks: 4 // 3 weeks load + 1 deload
            )
        case "Advanced":
            return StrategyConfig(
                progressionModel: "Block",
                volMin: 16,
                volMax: 20,
                repRangeCompound: (3, 6),
                repRangeIsolation: (8, 12),
                cycleDurationWeeks: 6 // 4 Accumulation + 2 Intensification
            )
        default:
            // Fallback to Intermediate
            return StrategyConfig(
                progressionModel: "Wave",
                volMin: 13,
                volMax: 15,
                repRangeCompound: (6, 8),
                repRangeIsolation: (10, 15),
                cycleDurationWeeks: 4
            )
        }
    }
}
