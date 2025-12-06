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
        return Self.makeModelContainer(schema: schema, configuration: modelConfiguration)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }

    private static func makeModelContainer(schema: Schema, configuration: ModelConfiguration) -> ModelContainer {
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If migration fails (e.g., new mandatory fields added), wipe the old store and retry
            purgeStoreFiles()
            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Could not create ModelContainer after wiping store: \(error)")
            }
        }
    }

    private static func purgeStoreFiles() {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Could not locate application support directory to recover store")
        }

        let storeURL = appSupport.appendingPathComponent("default.store")
        let walURL = URL(fileURLWithPath: storeURL.path + "-wal")
        let shmURL = URL(fileURLWithPath: storeURL.path + "-shm")

        try? fileManager.removeItem(at: storeURL)
        try? fileManager.removeItem(at: walURL)
        try? fileManager.removeItem(at: shmURL)
    }
}
