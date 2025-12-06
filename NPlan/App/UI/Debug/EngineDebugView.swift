import SwiftUI
import SwiftData
//import EngineTypes // For MesocycleBlueprint, StrategyConfig etc.

struct EngineDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [Plan]
    @Query private var exercises: [Exercise]
    
    @State private var debugLog: String = "Ready to generate..."
    @State private var isGenerating: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🏗️ Engine Test Bench")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Mock Profile:")
                        .font(.headline)
                    Text("• Goal: Strength")
                    Text("• Age: Intermediate")
                    Text("• Days: 4 / Week")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Library Status:")
                        .font(.headline)
                    Text("• \(exercises.count) Exercises Loaded")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: generatePlan) {
                if isGenerating {
                    ProgressView()
                } else {
                    Text("🚀 Generate Plan")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isGenerating)
            
            ScrollView {
                Text(debugLog)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.black.opacity(0.05))
            .cornerRadius(10)
            
            Button("Clear Plans") {
                try? modelContext.delete(model: Plan.self)
                debugLog = "Plans cleared."
            }
            .foregroundColor(.red)
        }
        .padding()
        .onAppear {
            DataSeeder.seedExercises(context: modelContext)
        }
    }
    
    func generatePlan() {
        isGenerating = true
        debugLog = "Initializing Engine..."
        
        Task {
            // 1. Create Mock User Profile (same as before)
            let user = UserProfile(trainingAge: "Intermediate", goal: "Strength", daysAvailable: 4)
            
            // 2. Resolve Strategy and Split Template using Repositories
            let strategy = StrategyRepository.getStrategy(for: user.trainingAge)
            guard let template = TemplateRepository.getSplitTemplate(daysAvailable: user.daysAvailable, goal: user.goal) else {
                debugLog = "❌ Error: No valid split template found for mock user profile."
                isGenerating = false
                return
            }
            
            // 3. Create MesocycleBlueprint
            let blueprint = MesocycleBlueprint(userProfile: user, strategy: strategy, splitTemplate: template)
            
            // 4. Run Engine (now with Blueprint)
            let service = PlanGenerationService()
            let plan = await service.generatePlan(blueprint: blueprint, context: modelContext)
            
            // 5. Output Result in a structured way
            if let plan = plan {
                modelContext.insert(plan)
                
                var logMessage = """
                ✅ Plan Generated Successfully!
                --------------------------------
                Plan: \(plan.name)
                Start Date: \(plan.startDate.formatted(date: .abbreviated, time: .omitted))
                
                """
                
                // Group sessions by week for better visualization
                let sessionsByWeek = Dictionary(grouping: plan.sessions) { $0.weekIndex }
                
                for weekIndex in sessionsByWeek.keys.sorted() {
                    logMessage += "\n=== Week \(weekIndex) ===\n"
                    let sessionsForWeek = sessionsByWeek[weekIndex]?.sorted(by: { $0.dayIndex < $1.dayIndex }) ?? []
                    
                    for session in sessionsForWeek {
                        logMessage += "  Day \(session.dayIndex + 1): \(session.name)\n"
                        if session.workoutExercises.isEmpty {
                            logMessage += "    (No exercises found for this session)\n"
                        } else {
                            for workoutExercise in session.workoutExercises {
                                logMessage += String(format: "    - %@ (%d sets of %@) - %@ (Tier: %@, Equip: %@)\n",
                                                     workoutExercise.exercise?.name ?? "Unknown Exercise",
                                                     workoutExercise.sets,
                                                     workoutExercise.reps,
                                                     workoutExercise.loadInstruction,
                                                     workoutExercise.exercise?.tier.rawValue ?? "N/A",
                                                     workoutExercise.exercise?.equipment.map { $0.rawValue }.joined(separator: ", ") ?? "N/A")
                            }
                        }
                    }
                }
                
                // --- Validation Report ---
                let validationReport = ValidationService.validate(plan: plan, blueprint: blueprint)
                logMessage += "\n\n" + validationReport.log
                
                debugLog = logMessage
            } else {
                debugLog = "❌ Generation Failed."
            }
            
            isGenerating = false
        }
    }
}

