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
            // If migration fails (e.g., new mandatory fields added), wipe the old store and retry
            let fileManager = FileManager.default
            if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = appSupport.appendingPathComponent("default.store")
                let walURL = URL(fileURLWithPath: storeURL.path + "-wal")
                let shmURL = URL(fileURLWithPath: storeURL.path + "-shm")
                
                try? fileManager.removeItem(at: storeURL)
                try? fileManager.removeItem(at: walURL)
                try? fileManager.removeItem(at: shmURL)
                
                do {
                    return try ModelContainer(for: schema, configurations: [modelConfiguration])
                } catch {
                    fatalError("Could not create ModelContainer after wiping store: \(error)")
                }
            } else {
                fatalError("Could not locate application support directory to recover store: \(error)")
            }
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
