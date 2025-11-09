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
    @State private var syncOpacity: Double = 1.0
    
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
                        .onAppear {
                            startSyncAnimation()
                        }
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
            Text("Tracking Sleep")
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
            
            // HRV
            if workoutManager.hrv > 0 {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(.pink)
                    Text("\(Int(workoutManager.hrv)) ms")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            
            // Duration
            Text(timeString(from: workoutManager.elapsedTime))
                .font(.system(size: 20, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
            
            // Sync status with animation
            HStack(spacing: 4) {
                Circle()
                    .fill(.green)
                    .frame(width: 6, height: 6)
                    .opacity(syncOpacity)
                Text("iPhone Synced")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
            
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

extension ContentView {
    func startSyncAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            syncOpacity = 0.3
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
