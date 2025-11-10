//
//  DreamWeaverIphoneAIApp.swift
//  DreamWeaverIphoneAI Watch App
//
//  Created by Gazsik Jozsef 6035 ED on 09.11.2025.
//

import SwiftUI

@main
struct DreamWeaverIphoneAI_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
        }
    }
}
