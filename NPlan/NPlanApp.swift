//
//  NPlanApp.swift
//  NPlan
//
//  Created by HUANG SONG on 5/12/25.
//

import SwiftUI
import SwiftData

@main
struct NPlanApp: App {
    @StateObject private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Plan.self,
            WorkoutSession.self,
            WorkoutExercise.self,
            Exercise.self,
            SecondaryMuscle.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
