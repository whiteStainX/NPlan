//
//  ContentView.swift
//  NPlan
//
//  Created by HUANG SONG on 5/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        // PHASE 1: ENGINE DEV MODE
        EngineDebugView()
        
        /*
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }

                    PlanView()
                        .tabItem {
                            Label("Plan", systemImage: "map")
                        }

                    AnalyticsView()
                        .tabItem {
                            Label("Analytics", systemImage: "chart.bar")
                        }

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            }
        }
        */
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}