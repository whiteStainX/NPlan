import Foundation
import SwiftData

class PlanGenerationService {
    
    // --- Dependencies ---
    // In a real DI setup, these would be injected.
    // For now, we use the static Repositories directly.
    
    @MainActor
    func generatePlan(for user: UserProfile, context: ModelContext) async -> Plan? {
        print("⚙️ Engine: Starting generation for \(user.trainingAge) / \(user.goal) / \(user.daysAvailable) days")
        
        // --- STAGE 1: HARD PRUNING ---
        // 1. Select Strategy (Periodization Rules)
        let strategy = StrategyRepository.getStrategy(for: user.trainingAge)
        print("   ✅ Strategy Selected: \(strategy.progressionModel) Model")
        
        // 2. Select Split Template (Skeleton)
        guard let template = TemplateRepository.getSplitTemplate(daysAvailable: user.daysAvailable, goal: user.goal) else {
            print("   ❌ Error: No valid split found for Days: \(user.daysAvailable), Goal: \(user.goal)")
            return nil
        }
        print("   ✅ Template Selected: \(template.name)")
        
        // --- STAGE 2: SKELETON GENERATION ---
        // Create the Plan object
        let plan = Plan(name: "\(template.name) (\(strategy.progressionModel))", startDate: Date())
        print("   ✅ Plan object created: \(plan.name), starting \(plan.startDate)")
        
        // --- STAGE 3: GREEDY FILLING ---
        for (dayIndex, dayTemplate) in template.days.enumerated() {
            let session = WorkoutSession(dayIndex: dayIndex, name: dayTemplate.name)

            // debug item
            print("   ✅ Session object created: \(session.name)")
            
            var selectedExerciseIDsForSession: Set<String> = []
            
            for slot in dayTemplate.slots {
                if let selectedExercise = try? self._findBestMatch(
                    slot: slot,
                    context: context,
                    excludeIDs: selectedExerciseIDsForSession
                ) {
                    // Apply Base Reps/Load from Strategy (simplified for now)
                    let repsRange = (slot.requiredType == .compound) ? strategy.repRangeCompound : strategy.repRangeIsolation
                    let loadInstruction = "RPE 7 (\(repsRange.0)-\(repsRange.1) Reps)" // Example
                    
                    let workoutExercise = WorkoutExercise(
                        sets: slot.defaultSets,
                        reps: "\(repsRange.0)-\(repsRange.1)",
                        loadInstruction: loadInstruction
                    )
                    workoutExercise.exercise = selectedExercise
                    session.workoutExercises.append(workoutExercise)
                    selectedExerciseIDsForSession.insert(selectedExercise.id)
                    
                    print("      - Added to \(dayTemplate.name): \(selectedExercise.name)")
                } else {
                    print("      - Could not find exercise for slot: \(slot.requiredType.rawValue) \(slot.requiredPattern ?? "") \(slot.targetMuscle ?? "")")
                }
            }
            plan.sessions.append(session)
        }
        
        return plan
    }
    
    // MARK: - Helper Methods
    
    // Equivalent to _find_best_match in pseudo-code
    @MainActor
    private func _findBestMatch(slot: DailySlot, context: ModelContext, excludeIDs: Set<String>) throws -> Exercise? {
        var candidates: [Exercise] = []
        
        // Extract values to local variables to help SwiftData predicate compiler
        // Convert Enum to String for robust Predicate comparison
        let requiredType = slot.requiredType.rawValue
        
        // Attempt 1: Exact match on type, pattern, and primary muscle
        if let pattern = slot.requiredPattern, let targetMuscle = slot.targetMuscle {
            let predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                exercise.pattern == pattern &&
                exercise.primaryMuscle == targetMuscle &&
                !excludeIDs.contains(exercise.id)
            }
            var descriptor = FetchDescriptor<Exercise>(predicate: predicate)
            descriptor.fetchLimit = 1
            candidates = try context.fetch(descriptor)
            if let exercise = candidates.first { return exercise }
        }

        // Attempt 2: Match on type and pattern
        if let pattern = slot.requiredPattern {
            let predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                exercise.pattern == pattern &&
                !excludeIDs.contains(exercise.id)
            }
            var descriptor = FetchDescriptor<Exercise>(predicate: predicate)
            descriptor.fetchLimit = 1
            candidates = try context.fetch(descriptor)
            if let exercise = candidates.first { return exercise }
        }

        // Attempt 3: Match on type and primary muscle
        if let targetMuscle = slot.targetMuscle {
            let predicate = #Predicate<Exercise> { exercise in
                exercise.type == requiredType &&
                exercise.primaryMuscle == targetMuscle &&
                !excludeIDs.contains(exercise.id)
            }
            var descriptor = FetchDescriptor<Exercise>(predicate: predicate)
            descriptor.fetchLimit = 1
            candidates = try context.fetch(descriptor)
            if let exercise = candidates.first { return exercise }
        }
        
        // Attempt 4: Match only by type (fallback)
        let fallbackPredicate = #Predicate<Exercise> { exercise in
            exercise.type == requiredType &&
            !excludeIDs.contains(exercise.id)
        }
        var fallbackDescriptor = FetchDescriptor<Exercise>(predicate: fallbackPredicate)
        fallbackDescriptor.fetchLimit = 1
        candidates = try context.fetch(fallbackDescriptor)
        return candidates.first
    }
}
