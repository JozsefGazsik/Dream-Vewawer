//
//  DreamWeaverIphoneAIApp.swift
//  DreamWeaverIphoneAI Watch App
//
//  Created by Gazsik Jozsef 6035 ED on 09.11.2025.
//

import SwiftUI
import WatchConnectivity

@main
struct DreamWeaverIphoneAI_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    init() {
        print("🌙 DreamWeaverIphoneAI Watch App Started")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .onAppear { print("⌚️ Watch ContentView active") }
        }
    }
}
