import Foundation
import SwiftData

@Model
class Exercise {
    var name: String
    var type: String // Compound, Isolation
    var pattern: String? // Push, Pull, Legs etc.
    var primaryMuscle: String
    
    init(name: String, type: String, primaryMuscle: String, pattern: String? = nil) {
        self.name = name
        self.type = type
        self.primaryMuscle = primaryMuscle
        self.pattern = pattern
    }
}
