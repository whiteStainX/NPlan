import Foundation
import SwiftData

@Model
class WorkoutSession {
    var dayIndex: Int // 0 = Monday/Day 1
    var name: String // e.g., "Upper Power"
    var isCompleted: Bool
    
    @Relationship(deleteRule: .cascade) var workoutExercises: [WorkoutExercise] = []
    var plan: Plan?
    
    init(dayIndex: Int, name: String, isCompleted: Bool = false) {
        self.dayIndex = dayIndex
        self.name = name
        self.isCompleted = isCompleted
    }
}