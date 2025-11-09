//
//  Dream_VewawerApp.swift
//  Dream Vewawer
//
//  Created by Gazsik Jozsef 6035 ED on 09.11.2025.
//

import SwiftUI
import SwiftData

@main
struct Dream_VewawerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SleepData.self,
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
        }
        .modelContainer(sharedModelContainer)
    }
}
