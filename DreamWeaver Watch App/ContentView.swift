//
//  ContentView.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingPermission = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.indigo.opacity(0.3), .purple.opacity(0.5), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Moon icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow)
                
                if workoutManager.isTracking {
                    trackingView
                } else {
                    startView
                }
            }
            .padding()
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
    
    private var startView: some View {
        VStack(spacing: 15) {
            Text("DreamWeaver")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Track your sleep")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            
            Button(action: {
                workoutManager.startWorkout()
            }) {
                Label("Start", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    private var trackingView: some View {
        VStack(spacing: 15) {
            Text("Tracking...")
                .font(.headline)
                .foregroundStyle(.white)
            
            // Heart rate
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text("\(Int(workoutManager.heartRate)) BPM")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            // Duration
            Text(timeString(from: workoutManager.elapsedTime))
                .font(.system(size: 20, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
            
            Button(action: {
                workoutManager.stopWorkout()
            }) {
                Label("Stop", systemImage: "stop.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.red)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
