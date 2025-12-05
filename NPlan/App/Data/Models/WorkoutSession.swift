import Foundation
import SwiftData

@Model
class WorkoutSession {
    var date: Date
    var isCompleted: Bool
    // Relation to Plan and Exercises to be added
    
    init(date: Date, isCompleted: Bool = false) {
        self.date = date
        self.isCompleted = isCompleted
    }
}
