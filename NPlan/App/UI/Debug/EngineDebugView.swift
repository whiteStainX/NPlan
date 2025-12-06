import SwiftUI
import SwiftData

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
            // 1. Create Mock User
            let user = UserProfile(trainingAge: "Intermediate", goal: "Strength", daysAvailable: 4)
            
            // 2. Run Engine (Mock Call for now)
            let service = PlanGenerationService()
            let plan = await service.generatePlan(for: user, context: modelContext)
            
            // 3. Output Result
            if let plan = plan {
                modelContext.insert(plan)
                
                var logMessage = """
                ✅ Plan Generated Successfully!
                --------------------------------
                Plan: \(plan.name)

                Sessions:
                """
                for session in plan.sessions.sorted(by: { $0.dayIndex < $1.dayIndex }) {
                    logMessage += "\n  \(session.name) (Day \(session.dayIndex + 1)):"
                    if session.workoutExercises.isEmpty {
                        logMessage += "\n    (No exercises found for this session)"
                    } else {
                        for workoutExercise in session.workoutExercises {
                            logMessage += "\n    - \(workoutExercise.exercise?.name ?? "Unknown Exercise") (\(workoutExercise.sets) sets of \(workoutExercise.reps)) - \(workoutExercise.loadInstruction)"
                        }
                    }
                }
                debugLog = logMessage
            } else {
                debugLog = "❌ Generation Failed."
            }
            
            isGenerating = false
        }
    }
}
