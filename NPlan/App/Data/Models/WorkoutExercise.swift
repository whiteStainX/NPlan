import Foundation
import SwiftData

@Model
class WorkoutExercise {
    // The specific prescription for this session
    var sets: Int
    var reps: String // "5-8"
    var loadInstruction: String // "RPE 8" or "70%"
    
    // Relationship to the static library
    var exercise: Exercise?
    var session: WorkoutSession?
    
    init(sets: Int, reps: String, loadInstruction: String) {
        self.sets = sets
        self.reps = reps
        self.loadInstruction = loadInstruction
    }
}
