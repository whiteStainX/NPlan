import Foundation
import SwiftData

@Model
class Plan {
    var name: String
    var startDate: Date
    // Relation to WorkoutSession to be added
    
    init(name: String, startDate: Date) {
        self.name = name
        self.startDate = startDate
    }
}
