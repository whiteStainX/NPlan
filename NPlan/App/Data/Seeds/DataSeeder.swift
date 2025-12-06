import Foundation
import SwiftData


struct ExerciseJSON: Decodable {
    let id: String
    let name: String
    let shortName: String?
    let pattern: String?
    let type: SlotType // Changed to SlotType
    let equipment: String?
    let primaryMuscle: String
    let secondaryMuscles: [SecondaryMuscleJSON]
    let defaultTempo: String?
    let tier: String?
    let isCompetitionLift: Bool
    let isUserCreated: Bool
}

struct SecondaryMuscleJSON: Decodable {
    let muscle: String
    let factor: Double
}

class DataSeeder {
    @MainActor
    static func seedExercises(context: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<Exercise>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            print("📚 Library already populated (\(count) exercises).")
            return
        }
        
        print("🌱 Seeding Exercise Library from JSON...")
        
        let jsonString = """
        [
            {
                "id": "squat_back_barbell",
                "name": "Barbell Back Squat",
                "shortName": "Squat",
                "pattern": "Squat",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 1.0
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "3-0-1-0",
                "tier": "Tier1",
                "isCompetitionLift": true,
                "isUserCreated": false
            },
            {
                "id": "bench_press_barbell",
                "name": "Barbell Bench Press",
                "shortName": "Bench",
                "pattern": "Push_Horizontal",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Chest",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 1.0
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.75
                    }
                ],
                "defaultTempo": "3-1-x-0",
                "tier": "Tier1",
                "isCompetitionLift": true,
                "isUserCreated": false
            },
            {
                "id": "deadlift_conventional",
                "name": "Conventional Deadlift",
                "shortName": "Deadlift",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 1.0
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 1.0
                    },
                    {
                        "muscle": "Quads",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "2-0-1-0",
                "tier": "Tier1",
                "isCompetitionLift": true,
                "isUserCreated": false
            },
            {
                "id": "overhead_press_barbell",
                "name": "Barbell Overhead Press",
                "shortName": "OHP",
                "pattern": "Push_Vertical",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Delts_Front",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Side",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.7
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "squat_front_barbell",
                "name": "Barbell Front Squat",
                "pattern": "Squat",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 1.0
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "3-1-1-0",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "walking_lunge_dumbbell",
                "name": "Walking Lunge",
                "pattern": "Lunge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.7
                    },
                    {
                        "muscle": "Hamstrings",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "romanian_deadlift_barbell",
                "name": "Barbell Romanian Deadlift",
                "shortName": "RDL",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "3-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "hip_thrust_barbell",
                "name": "Barbell Hip Thrust",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Glutes",
                "secondaryMuscles": [
                    {
                        "muscle": "Hamstrings",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.3
                    }
                ],
                "defaultTempo": "2-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "barbell_row",
                "name": "Barbell Row",
                "pattern": "Pull_Horizontal",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Back_Lats",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Biceps",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.3
                    }
                ],
                "defaultTempo": "2-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "chest_supported_row",
                "name": "Chest Supported Row",
                "pattern": "Pull_Horizontal",
                "type": "Machine",
                "equipment": "Machine",
                "primaryMuscle": "Back_Lats",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.7
                    },
                    {
                        "muscle": "Delts_Rear",
                        "factor": 0.4
                    },
                    {
                        "muscle": "Biceps",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "2-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "pull_up_bodyweight",
                "name": "Pull-Up",
                "pattern": "Pull_Vertical",
                "type": "Compound",
                "equipment": "Bodyweight",
                "primaryMuscle": "Back_Lats",
                "secondaryMuscles": [
                    {
                        "muscle": "Biceps",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Delts_Rear",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "2-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "lat_pulldown_machine",
                "name": "Lat Pulldown",
                "pattern": "Pull_Vertical",
                "type": "Machine",
                "equipment": "Machine",
                "primaryMuscle": "Back_Lats",
                "secondaryMuscles": [
                    {
                        "muscle": "Biceps",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.4
                    },
                    {
                        "muscle": "Delts_Rear",
                        "factor": 0.3
                    }
                ],
                "defaultTempo": "2-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "bench_press_dumbbell",
                "name": "Dumbbell Bench Press",
                "pattern": "Push_Horizontal",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Chest",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.7
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.6
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "bench_press_incline_barbell",
                "name": "Barbell Incline Bench Press",
                "pattern": "Push_Horizontal",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Chest",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.6
                    }
                ],
                "defaultTempo": "2-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "overhead_press_dumbbell",
                "name": "Seated Dumbbell Shoulder Press",
                "shortName": "DB OHP",
                "pattern": "Push_Vertical",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Delts_Front",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Side",
                        "factor": 0.7
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.6
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "leg_extension_machine",
                "name": "Leg Extension",
                "pattern": "Isolation",
                "type": "Machine",
                "equipment": "Machine",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "standing_calf_raise",
                "name": "Standing Calf Raise",
                "pattern": "Isolation",
                "type": "Machine",
                "equipment": "Machine",
                "primaryMuscle": "Calves",
                "secondaryMuscles": [],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "leg_curl_machine",
                "name": "Leg Curl",
                "pattern": "Isolation",
                "type": "Machine",
                "equipment": "Machine",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Calves",
                        "factor": 0.2
                    }
                ],
                "defaultTempo": "2-1-2-0",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "lateral_raise_dumbbell",
                "name": "Dumbbell Lateral Raise",
                "pattern": "Isolation",
                "type": "Isolation",
                "equipment": "Dumbbell",
                "primaryMuscle": "Delts_Side",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Rear",
                        "factor": 0.2
                    }
                ],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "face_pull_cable",
                "name": "Cable Face Pull",
                "pattern": "Pull_Horizontal",
                "type": "Isolation",
                "equipment": "Cable",
                "primaryMuscle": "Delts_Rear",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.4
                    },
                    {
                        "muscle": "Biceps",
                        "factor": 0.2
                    }
                ],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "tricep_pushdown_cable",
                "name": "Cable Tricep Pushdown",
                "pattern": "Isolation",
                "type": "Isolation",
                "equipment": "Cable",
                "primaryMuscle": "Triceps",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.2
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "bench_press_fly_dumbbell",
                "name": "Dumbbell Chest Flye",
                "pattern": "Isolation",
                "type": "Isolation",
                "equipment": "Dumbbell",
                "primaryMuscle": "Chest",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.3
                    }
                ],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "bicep_curl_dumbbell",
                "name": "Dumbbell Bicep Curl",
                "pattern": "Isolation",
                "type": "Isolation",
                "equipment": "Dumbbell",
                "primaryMuscle": "Biceps",
                "secondaryMuscles": [],
                "defaultTempo": "2-0-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "cable_crunch",
                "name": "Cable Crunch",
                "pattern": "Isolation",
                "type": "Isolation",
                "equipment": "Cable",
                "primaryMuscle": "Abs",
                "secondaryMuscles": [],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "renegade_lunge_dumbbell",
                "name": "Renegade Lunge",
                "pattern": "Lunge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Hamstrings",
                        "factor": 0.4
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "side_press_dumbbell",
                "name": "Side Press (Bent Press)",
                "shortName": "Side Press",
                "pattern": "Push_Vertical",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Delts_Side",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Lats",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "3-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "floor_press_barbell",
                "name": "Floor Press",
                "pattern": "Push_Horizontal",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Chest",
                "secondaryMuscles": [
                    {
                        "muscle": "Triceps",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "2-1-1-0",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "one_arm_barbell_row",
                "name": "One-Arm Barbell Row",
                "pattern": "Pull_Horizontal",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Back_Lats",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Biceps",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "zercher_squat_barbell",
                "name": "Zercher Squat",
                "pattern": "Squat",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 1.0
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "3-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "single_leg_rdl_dumbbell",
                "name": "Single-Leg Romanian Deadlift",
                "shortName": "Single-Leg RDL",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "3-1-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "suitcase_deadlift_barbell",
                "name": "Suitcase Deadlift",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.7
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.6
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "bulgarian_split_squat_dumbbell",
                "name": "Bulgarian Split Squat",
                "pattern": "Lunge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Quads",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    }
                ],
                "defaultTempo": "3-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "kettlebell_swing_hardstyle",
                "name": "Kettlebell Swing (Hardstyle)",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "1-0-x-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "turkish_get_up_dumbbell",
                "name": "Turkish Get-Up",
                "shortName": "TGU",
                "pattern": "Isolation",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Abs",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Glutes",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "3-0-3-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "kettlebell_clean_press",
                "name": "Kettlebell Clean & Press",
                "pattern": "Push_Vertical",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Delts_Front",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Lats",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Glutes",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.4
                    }
                ],
                "defaultTempo": "1-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "jefferson_deadlift_barbell",
                "name": "Jefferson Deadlift",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.8
                    },
                    {
                        "muscle": "Quads",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "good_morning_barbell",
                "name": "Good Morning",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Barbell",
                "primaryMuscle": "Hamstrings",
                "secondaryMuscles": [
                    {
                        "muscle": "Glutes",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.6
                    }
                ],
                "defaultTempo": "3-1-1-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "farmer_carry_dumbbell",
                "name": "Farmer Carry",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Back_Traps",
                "secondaryMuscles": [
                    {
                        "muscle": "Abs",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.4
                    },
                    {
                        "muscle": "Glutes",
                        "factor": 0.3
                    }
                ],
                "defaultTempo": "1-0-1-0",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "suitcase_carry_dumbbell",
                "name": "Suitcase Carry",
                "pattern": "Hinge",
                "type": "Compound",
                "equipment": "Dumbbell",
                "primaryMuscle": "Abs",
                "secondaryMuscles": [
                    {
                        "muscle": "Back_Traps",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Back_Lower",
                        "factor": 0.5
                    },
                    {
                        "muscle": "Glutes",
                        "factor": 0.3
                    }
                ],
                "defaultTempo": "1-0-1-0",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "parallel_bar_dip",
                "name": "Parallel Bar Dip",
                "pattern": "Push_Vertical",
                "type": "Compound",
                "equipment": "Bodyweight",
                "primaryMuscle": "Chest",
                "secondaryMuscles": [
                    {
                        "muscle": "Delts_Front",
                        "factor": 0.6
                    },
                    {
                        "muscle": "Triceps",
                        "factor": 0.8
                    }
                ],
                "defaultTempo": "2-0-1-1",
                "tier": "Tier2",
                "isCompetitionLift": false,
                "isUserCreated": false
            },
            {
                "id": "hanging_leg_raise",
                "name": "Hanging Leg Raise",
                "pattern": "Isolation",
                "type": "Isolation",
                "equipment": "Bodyweight",
                "primaryMuscle": "Abs",
                "secondaryMuscles": [],
                "defaultTempo": "2-1-2-1",
                "tier": "Tier3",
                "isCompetitionLift": false,
                "isUserCreated": false
            }
        ]
        """
        
        do {
            guard let data = jsonString.data(using: .utf8) else {
                print("❌ Failed to convert JSON string to Data.")
                return
            }
            
            let decoder = JSONDecoder()
            let exerciseDTOs = try decoder.decode([ExerciseJSON].self, from: data)
            
            for dto in exerciseDTOs {
                let exercise = Exercise(
                    id: dto.id,
                    name: dto.name,
                    shortName: dto.shortName,
                    type: dto.type,
                    pattern: dto.pattern,
                    equipment: dto.equipment,
                    primaryMuscle: dto.primaryMuscle,
                    defaultTempo: dto.defaultTempo,
                    tier: dto.tier,
                    isCompetitionLift: dto.isCompetitionLift,
                    isUserCreated: dto.isUserCreated
                )
                
                // Add secondary muscles
                for sm in dto.secondaryMuscles {
                    let secondary = SecondaryMuscle(muscle: sm.muscle, factor: sm.factor)
                    exercise.secondaryMuscles.append(secondary)
                }
                
                context.insert(exercise)
            }
            
            try context.save()
            print("✅ Seeding Complete: \(exerciseDTOs.count) exercises added.")
            
        } catch {
            print("❌ Seeding Failed: \(error)")
        }
    }
}
