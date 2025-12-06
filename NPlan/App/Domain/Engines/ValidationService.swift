import Foundation
import SwiftData
//import EngineTypes

struct ValidationReport {
    let isValid: Bool
    let hardConstraintsMet: Bool
    let softConstraintsScore: Int
    let log: String
}

class ValidationService {
    
    static func validate(plan: Plan, blueprint: MesocycleBlueprint) -> ValidationReport {
        var log = "🔍 Validation Report\n---------------------\n"
        var hardConstraintsMet = true
        
        // --- 1. Hard Constraints: Structural Integrity ---
        // Check if all slots are filled for all weeks
        log += "\n[Hard Constraints]\n"
        
        let totalWeeks = blueprint.strategy.cycleDurationWeeks
        let sessionsByWeek = Dictionary(grouping: plan.sessions) { $0.weekIndex }
        
        if sessionsByWeek.count != totalWeeks {
            log += "❌ Week Count Mismatch: Expected \(totalWeeks), found \(sessionsByWeek.count)\n"
            hardConstraintsMet = false
        } else {
            log += "✅ Week Count: \(totalWeeks)\n"
        }
        
        // Check Day/Slot coverage
        for weekIndex in 1...totalWeeks {
            guard let weekSessions = sessionsByWeek[weekIndex] else {
                log += "❌ Missing Week \(weekIndex)\n"
                hardConstraintsMet = false
                continue
            }
            
            // Check if we have enough sessions for the week
            if weekSessions.count != blueprint.splitTemplate.days.count {
                log += "❌ Week \(weekIndex): Session Count Mismatch. Expected \(blueprint.splitTemplate.days.count), found \(weekSessions.count)\n"
                hardConstraintsMet = false
            }
            
            // Check for empty sessions
            for session in weekSessions {
                if session.workoutExercises.isEmpty {
                    log += "❌ Week \(weekIndex), \(session.name): No exercises found.\n"
                    hardConstraintsMet = false
                }
            }
        }
        
        if hardConstraintsMet {
            log += "✅ All Structural Constraints Passed.\n"
        }
        
        // --- 2. Soft Constraints: Volume Analysis ---
        log += "\n[Soft Constraints: Weekly Volume]\n"
        log += "Target: \(blueprint.strategy.volMin)-\(blueprint.strategy.volMax) sets/muscle/week\n"
        
        var softScore = 0
        
        // Calculate average weekly volume per muscle
        // We analyze Week 1 as a representative sample for the mesocycle skeleton
        if let week1Sessions = sessionsByWeek[1] {
            var weeklyVolume: [String: Int] = [:]
            
            for session in week1Sessions {
                for workoutExercise in session.workoutExercises {
                    if let exercise = workoutExercise.exercise {
                        let muscle = exercise.primaryMuscle
                        weeklyVolume[muscle, default: 0] += workoutExercise.sets
                        
                        // Add partial volume for secondary muscles?
                        // For now, keeping it simple with primary only.
                    }
                }
            }
            
            let sortedMuscles = weeklyVolume.keys.sorted()
            for muscle in sortedMuscles {
                let volume = weeklyVolume[muscle]!
                let minVol = blueprint.strategy.volMin
                let maxVol = blueprint.strategy.volMax
                
                if volume >= minVol && volume <= maxVol {
                    log += "✅ \(muscle): \(volume) sets (In Range)\n"
                    softScore += 10
                } else if volume < minVol {
                    log += "⚠️ \(muscle): \(volume) sets (Under Target \(minVol))\n"
                    softScore -= 5
                } else {
                    log += "⚠️ \(muscle): \(volume) sets (Over Target \(maxVol))\n"
                    softScore -= 2 // Going over is usually better than under
                }
            }
        }
        
        return ValidationReport(
            isValid: hardConstraintsMet, // Can define validity looser if needed
            hardConstraintsMet: hardConstraintsMet,
            softConstraintsScore: softScore,
            log: log
        )
    }
}
