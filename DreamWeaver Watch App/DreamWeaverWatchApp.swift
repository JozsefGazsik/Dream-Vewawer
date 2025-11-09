//
//  DreamWeaverWatchApp.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI
import HealthKit
import WatchConnectivity

@main
struct DreamWeaverWatchApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    init() {
        print("🌙 DreamWeaver Watch App Started!")
        print("📱 Initializing WorkoutManager...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .onAppear {
                    print("🌙 ContentView appeared on Watch!")
                    print("⌚️ Watch App is running and visible")
                }
        }
    }
}
