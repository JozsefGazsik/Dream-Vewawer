//
//  DreamWeaverWatchApp.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI

import SwiftUI
import WidgetKit
import HealthKit
import WatchConnectivity

// MARK: - Widget Configuration
struct DreamTrackerWidget: Widget {
    let kind: String = "DreamTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DreamTrackerProvider()) { entry in
            DreamTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Dream Tracker")
        .description("Track your dreams with DreamWeaver")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}

// MARK: - Timeline Provider
struct DreamTrackerProvider: TimelineProvider {
    func placeholder(in context: Context) -> DreamEntry {
        DreamEntry(date: Date(), isTracking: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (DreamEntry) -> ()) {
        let entry = DreamEntry(date: Date(), isTracking: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DreamEntry>) -> ()) {
        let entries: [DreamEntry] = [
            DreamEntry(date: Date(), isTracking: false)
        ]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct DreamEntry: TimelineEntry {
    let date: Date
    let isTracking: Bool
}

// MARK: - Widget View
struct DreamTrackerWidgetView: View {
    var entry: DreamTrackerProvider.Entry

    var body: some View {
        VStack {
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.yellow)
            Text("🌙 DREAM")
                .font(.caption2)
                .foregroundColor(.white)
            if entry.isTracking {
                Text("TRACKING")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else {
                Text("TAP TO START")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(4)
    }
}

@main
struct DreamWeaverWatchApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    init() {
        print("🌙 DreamWeaver Watch Widget App Started!")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .onAppear {
                    print("🌙 ContentView appeared!")
                }
        }
    }
}
