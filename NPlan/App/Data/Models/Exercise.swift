import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var id: String
    var name: String
    var shortName: String?
    var type: String // Reverted to String for Predicate stability
    var pattern: String? // Push_Horizontal, etc.
    var equipment: String?
    var primaryMuscle: String
    var defaultTempo: String?
    var tier: String? // Tier1, Tier2, Tier3
    var isCompetitionLift: Bool
    var isUserCreated: Bool
    
    // Relationship to Secondary Muscles
    @Relationship(deleteRule: .cascade) var secondaryMuscles: [SecondaryMuscle] = []
    
    init(
        id: String,
        name: String,
        shortName: String? = nil,
        type: String, // Reverted to String
        pattern: String? = nil,
        equipment: String? = nil,
        primaryMuscle: String,
        defaultTempo: String? = nil,
        tier: String? = nil,
        isCompetitionLift: Bool = false,
        isUserCreated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.type = type
        self.pattern = pattern
        self.equipment = equipment
        self.primaryMuscle = primaryMuscle
        self.defaultTempo = defaultTempo
        self.tier = tier
        self.isCompetitionLift = isCompetitionLift
        self.isUserCreated = isUserCreated
    }
}

@Model
class SecondaryMuscle {
    var muscle: String
    var factor: Double
    
    init(muscle: String, factor: Double) {
        self.muscle = muscle
        self.factor = factor
    }
}