import Foundation
import SwiftData

@Model
class UserProfile {
    var trainingAge: String // Novice, Intermediate, Advanced
    var goal: String // Strength, Hypertrophy
    var daysAvailable: Int
    
    init(trainingAge: String, goal: String, daysAvailable: Int) {
        self.trainingAge = trainingAge
        self.goal = goal
        self.daysAvailable = daysAvailable
    }
}
