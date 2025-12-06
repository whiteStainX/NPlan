import Foundation

class TemplateRepository {
    
    static func getSplitTemplate(daysAvailable: Int, goal: String) -> SplitTemplate? {
        let key = "\(daysAvailable)_\(goal)"
        
        switch key {
        case "4_Strength":
            return fourDayStrengthSplit
        case "4_Hypertrophy":
            return fourDayUpperLower // Defaulting to Upper/Lower for 4 day generic
        case "3_Strength":
            return threeDayFullBody // Simplified placeholder
        default:
            // Fallback to 4 Day Strength for testing if not found
            if daysAvailable == 4 { return fourDayStrengthSplit }
            return nil
        }
    }
    
    // --- Defined Templates ---
    
    // 4-Day Strength: Squat, Bench, Deadlift, Bench (Frequency focused)
    private static var fourDayStrengthSplit: SplitTemplate {
        SplitTemplate(
            name: "4-Day Powerlifting Split",
            description: "Focuses on the Big 3 with high frequency benching.",
            days: [
                // Day 1: Squat Focus + Legs
                SplitDay(name: "Squat Focus", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Squat", targetMuscle: nil, defaultSets: 4), // Comp Squat
                    DailySlot(requiredType: .compound, requiredPattern: "Lunge", targetMuscle: nil, defaultSets: 3), // Accessory Legs
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Quads", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Abs", defaultSets: 3)
                ]),
                // Day 2: Bench Focus + Push
                SplitDay(name: "Bench Focus", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Horizontal", targetMuscle: nil, defaultSets: 4), // Comp Bench
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Vertical", targetMuscle: nil, defaultSets: 3), // OHP
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Triceps", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Chest", defaultSets: 3)
                ]),
                // Day 3: Deadlift Focus + Pull
                SplitDay(name: "Deadlift Focus", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Hinge", targetMuscle: nil, defaultSets: 4), // Deadlift
                    DailySlot(requiredType: .compound, requiredPattern: "Pull_Horizontal", targetMuscle: nil, defaultSets: 3), // Row
                    DailySlot(requiredType: .compound, requiredPattern: "Pull_Vertical", targetMuscle: nil, defaultSets: 3), // Pullup
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Biceps", defaultSets: 3)
                ]),
                // Day 4: Bench Variation + Accessories
                SplitDay(name: "Bench Volume / Access", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Horizontal", targetMuscle: nil, defaultSets: 3), // Variation (e.g., Larsen)
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Delts_Side", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Delts_Rear", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Triceps", defaultSets: 3)
                ])
            ]
        )
    }
    
    // 4-Day Hypertrophy: Upper / Lower
    private static var fourDayUpperLower: SplitTemplate {
        SplitTemplate(
            name: "Upper / Lower Split",
            description: "Classic bodybuilding split balancing volume and recovery.",
            days: [
                // Day 1: Upper
                SplitDay(name: "Upper A", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Horizontal", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Pull_Vertical", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Vertical", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Pull_Horizontal", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Triceps", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Biceps", defaultSets: 3)
                ]),
                // Day 2: Lower
                SplitDay(name: "Lower A", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Squat", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Hinge", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Quads", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Hamstrings", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Calves", defaultSets: 4)
                ]),
                // Day 3: Upper B
                 SplitDay(name: "Upper B", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Vertical", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Pull_Horizontal", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Push_Horizontal", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .compound, requiredPattern: "Pull_Vertical", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Delts_Side", defaultSets: 3)
                ]),
                // Day 4: Lower B
                SplitDay(name: "Lower B", slots: [
                    DailySlot(requiredType: .compound, requiredPattern: "Hinge", targetMuscle: nil, defaultSets: 3), // Deadlift/RDL
                    DailySlot(requiredType: .compound, requiredPattern: "Lunge", targetMuscle: nil, defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Glutes", defaultSets: 3),
                    DailySlot(requiredType: .isolation, requiredPattern: nil, targetMuscle: "Abs", defaultSets: 3)
                ])
            ]
        )
    }
    
    // Placeholder for 3 Day
    private static var threeDayFullBody: SplitTemplate {
        SplitTemplate(name: "3-Day Full Body", description: "Full body frequency.", days: [])
    }
}
