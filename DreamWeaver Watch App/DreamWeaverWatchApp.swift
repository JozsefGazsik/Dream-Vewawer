//
//  DreamWeaverWatchApp.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI

@main
struct DreamWeaverWatchApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .onAppear {
                    print("🌙 DreamWeaver Watch App Started!")
                }
        }
    }
}
