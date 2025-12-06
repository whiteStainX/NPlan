import Foundation
import SwiftData
//import EngineTypes // For MesocycleBlueprint, StrategyConfig, SplitTemplate, DailySlot etc.
// import ExerciseSelector // Not needed directly, ExerciseSelector is a static class

class PlanGenerationService {
    
    // --- Dependencies ---
    // In a real DI setup, these would be injected.
    // For now, we use the static Repositories and ExerciseSelector directly.
    
    @MainActor
    func generatePlan(blueprint: MesocycleBlueprint, context: ModelContext) async -> Plan? {
        let user = blueprint.userProfile
        let strategy = blueprint.strategy
        let template = blueprint.splitTemplate
        
        print("⚙️ Engine: Starting generation for \(user.trainingAge) / \(user.goal) / \(user.daysAvailable) days")
        
        // --- STAGE 1: HARD PRUNING (Blueprint already contains resolved strategy and template) ---
        print("   ✅ Strategy Selected: \(strategy.progressionModel) Model")
        print("   ✅ Template Selected: \(template.name)")
        
        // --- STAGE 2: SKELETON GENERATION (Determine exercises for each slot once for the mesocycle) ---
        // This ensures exercises for a given day/slot are consistent across weeks.
        var mesocycleExerciseSkeleton: [Int: [Int: Exercise]] = [:] // [DayIndex: [SlotIndex: Exercise]]
        
        for (dayIndex, dayTemplate) in template.days.enumerated() {
            var dayExercises: [Int: Exercise] = [:]
            var selectedExerciseIDsForDay: Set<String> = [] // Exclude within the same day
            
            for (slotIndex, slot) in dayTemplate.slots.enumerated() {
                if let selectedExercise = try? ExerciseSelector.selectExercise(
                    for: slot,
                    context: context,
                    excludeIDs: selectedExerciseIDsForDay
                ) {
                    dayExercises[slotIndex] = selectedExercise
                    selectedExerciseIDsForDay.insert(selectedExercise.id)
                    print("      - Skeleton for Day \(dayIndex), Slot \(slotIndex): \(selectedExercise.name)")
                } else {
                    print("      - Could not find exercise for Day \(dayIndex), Slot \(slotIndex): \(slot.requiredType.rawValue) \(slot.requiredPattern ?? "") \(slot.targetMuscle ?? "")")
                }
            }
            mesocycleExerciseSkeleton[dayIndex] = dayExercises
        }
        
        // --- STAGE 3: PLAN INSTANTIATION (Greedy Filling for multiple weeks) ---
        // Create the Plan object
        let plan = Plan(name: "\(template.name) (\(strategy.progressionModel)) - \(strategy.cycleDurationWeeks) Weeks", startDate: Date())
        print("   ✅ Plan object created: \(plan.name), starting \(plan.startDate)")
        
        for weekIndex in 1...blueprint.strategy.cycleDurationWeeks { // Loop for each week
            for (dayIndex, dayTemplate) in template.days.enumerated() {
                // Ensure we have exercises for this day in the skeleton
                guard let skeletonDayExercises = mesocycleExerciseSkeleton[dayIndex] else { continue }
                
                let session = WorkoutSession(weekIndex: weekIndex, dayIndex: dayIndex, name: dayTemplate.name)
                print("   ✅ Session object created: Week \(weekIndex), Day \(dayIndex): \(session.name)")
                
                for (slotIndex, slot) in dayTemplate.slots.enumerated() {
                    if let selectedExercise = skeletonDayExercises[slotIndex] {
                        // Use ProgressionEngine to get sets, reps, load for the specific week
                        let sets = ProgressionEngine.getSets(week: weekIndex, strategy: strategy, slotType: slot.requiredType)
                        let reps = ProgressionEngine.getReps(week: weekIndex, strategy: strategy, slotType: slot.requiredType)
                        let loadInstruction = ProgressionEngine.getLoadInstruction(week: weekIndex, strategy: strategy)
                        
                        let workoutExercise = WorkoutExercise(
                            sets: sets,
                            reps: reps,
                            loadInstruction: loadInstruction
                        )
                        workoutExercise.exercise = selectedExercise
                        session.workoutExercises.append(workoutExercise)
                        
                        print("      - Added to W\(weekIndex)D\(dayIndex)S\(slotIndex): \(selectedExercise.name) (\(sets) sets of \(reps)) - \(loadInstruction)")
                    }
                }
                plan.sessions.append(session)
            }
        }
        
        return plan
    }
}
