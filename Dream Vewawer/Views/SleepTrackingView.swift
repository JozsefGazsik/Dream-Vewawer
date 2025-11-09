//
//  SleepTrackingView.swift
//  Dream Vewawer
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI
import SwiftData

struct SleepTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isTracking = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var currentHeartRate: Double = 65
    @State private var currentMovement: Double = 0.3
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.indigo.opacity(0.3), .purple.opacity(0.5), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Moon icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow.opacity(0.8))
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                
                Text(isTracking ? "Tracking Your Dreams..." : "Ready to Sleep?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                if isTracking {
                    VStack(spacing: 15) {
                        Text(timeString(from: elapsedTime))
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 30) {
                            BiosignalIndicator(
                                icon: "heart.fill",
                                value: String(format: "%.0f", currentHeartRate),
                                unit: "bpm",
                                color: .red
                            )
                            
                            BiosignalIndicator(
                                icon: "figure.walk",
                                value: String(format: "%.0f%%", currentMovement * 100),
                                unit: "",
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Spacer()
                
                // Control button
                Button(action: toggleTracking) {
                    Label(
                        isTracking ? "Stop Tracking" : "Start Dream Mode",
                        systemImage: isTracking ? "stop.circle.fill" : "play.circle.fill"
                    )
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isTracking ? .red.opacity(0.8) : .blue.opacity(0.8))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Sleep Tracking")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    private func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }
    
    private func startTracking() {
        isTracking = true
        startTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            
            // Simulate biosignal changes
            currentHeartRate = 60 + Double.random(in: -5...10)
            currentMovement = Double.random(in: 0.1...0.7)
        }
    }
    
    private func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil
        
        // Create sleep data with simulated biosignals
        let sleepSession = SleepData(
            date: startTime ?? Date(),
            duration: elapsedTime,
            avgHeartRate: 65 + Double.random(in: -5...10),
            heartRateVariability: Double.random(in: 30...70),
            movementIntensity: Double.random(in: 0.2...0.6),
            remPercentage: Double.random(in: 15...30),
            deepSleepPercentage: Double.random(in: 20...35),
            ambientNoiseLevel: Double.random(in: 0.1...0.4)
        )
        
        modelContext.insert(sleepSession)
        
        // Dismiss and go back to main view
        dismiss()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct BiosignalIndicator: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                Text(unit)
                    .font(.system(size: 12))
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    NavigationStack {
        SleepTrackingView()
            .modelContainer(for: SleepData.self, inMemory: true)
    }
}
