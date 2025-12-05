import Foundation
import SwiftData

@Model
class Plan {
    var name: String
    var startDate: Date
    
    @Relationship(deleteRule: .cascade) var sessions: [WorkoutSession] = []
    
    init(name: String, startDate: Date) {
        self.name = name
        self.startDate = startDate
    }
}