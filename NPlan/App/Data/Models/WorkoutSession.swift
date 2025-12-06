import Foundation
import SwiftData

@Model
class WorkoutSession {
    var weekIndex: Int // 1-based week number
    var dayIndex: Int // 0 = Monday/Day 1
    var name: String // e.g., "Upper Power"
    var isCompleted: Bool
    
    @Relationship(deleteRule: .cascade) var workoutExercises: [WorkoutExercise] = []
    var plan: Plan?
    
    init(weekIndex: Int, dayIndex: Int, name: String, isCompleted: Bool = false) {
        self.weekIndex = weekIndex
        self.dayIndex = dayIndex
        self.name = name
        self.isCompleted = isCompleted
    }
}