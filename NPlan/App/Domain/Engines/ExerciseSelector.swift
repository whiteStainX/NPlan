import Foundation
import SwiftData
//import EngineTypes

class ExerciseSelector {
    @MainActor
    static func selectExercise(
        for slot: DailySlot,
        context: ModelContext,
        excludeIDs: Set<String>
    ) throws -> Exercise? {
        var allCandidates: [Exercise] = []
        
        // --- Step 1: Filter (Hard Constraints) ---
        // Basic filtering for type, pattern, muscle, and NOT already excluded
        let requiredType = slot.requiredType.rawValue
        
        var predicate: Predicate<Exercise>
        if let pattern = slot.requiredPattern, let targetMuscle = slot.targetMuscle {
            predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                exercise.pattern == pattern &&
                exercise.primaryMuscle == targetMuscle &&
                !excludeIDs.contains(exercise.id)
            }
        } else if let pattern = slot.requiredPattern {
            predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                exercise.pattern == pattern &&
                !excludeIDs.contains(exercise.id)
            }
        } else if let targetMuscle = slot.targetMuscle {
            predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                exercise.primaryMuscle == targetMuscle &&
                !excludeIDs.contains(exercise.id)
            }
        } else {
            predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                !excludeIDs.contains(exercise.id)
            }
        }
        
        let descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        allCandidates = try context.fetch(descriptor)
        
        // --- Step 2: Score (Soft Constraints) ---
        // For simplicity, initially only score by Tier.
        // Higher tier (Tier1 < Tier2 < Tier3) means higher score for now.
        // Needs inversion for preference: Tier1 is "best", so higher score.
        let scoredCandidates = allCandidates.map { exercise in
            var score = 0
            switch exercise.tier {
            case .tier1: score += 3
            case .tier2: score += 2
            case .tier3: score += 1
            }
            
            // TODO: Add scoring for equipment match, user preferences, freshness, etc.
            
            return (exercise: exercise, score: score)
        }
        
        // --- Step 3: Pick ---
        // Select the exercise with the highest score
        return scoredCandidates.max(by: { $0.score < $1.score })?.exercise
    }
}
