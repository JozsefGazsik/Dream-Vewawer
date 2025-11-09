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
    @State private var isProcessingAI = false
    @State private var currentSessionId: UUID?
    
    @StateObject private var aiService = AIDreamService()
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
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
                
                // Sync Status Component
                SyncStatusView(
                    connectivityManager: connectivityManager,
                    isTracking: isTracking
                )
                
                if isTracking {
                    VStack(spacing: 15) {
                        Text(timeString(from: elapsedTime))
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 30) {
                            BiosignalIndicator(
                                icon: "heart.fill",
                                value: String(format: "%.0f", connectivityManager.isWatchConnected ? connectivityManager.latestHeartRate : currentHeartRate),
                                unit: "bpm",
                                color: .red
                            )
                            
                            BiosignalIndicator(
                                icon: "waveform.path.ecg",
                                value: String(format: "%.0f", connectivityManager.latestHRV),
                                unit: "ms",
                                color: .pink
                            )
                            
                            BiosignalIndicator(
                                icon: "figure.walk",
                                value: String(format: "%.0f%%", currentMovement * 100),
                                unit: "",
                                color: .green
                            )
                        }
                        
                        if connectivityManager.isWatchConnected {
                            Text("📡 Receiving live data from Watch")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                // AI processing indicator
                if isProcessingAI {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("AI analyzing your dream...")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
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
        currentSessionId = UUID()
        
        // Set model context for connectivity manager
        connectivityManager.setModelContext(modelContext)
        
        // Start tracking on Watch if connected
        if let sessionId = currentSessionId {
            connectivityManager.startSleepSession(sessionId: sessionId)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            
            // Simulate biosignal changes (will be replaced by real Watch data)
            if !connectivityManager.isWatchConnected {
                currentHeartRate = 60 + Double.random(in: -5...10)
            }
            currentMovement = Double.random(in: 0.1...0.7)
            
            // Request current metrics from Watch periodically
            if Int(elapsedTime) % 5 == 0 {
                connectivityManager.requestCurrentMetrics()
            }
        }
    }
    
    private func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil
        
        // Stop tracking on Watch
        connectivityManager.stopSleepSession()
        
        // Create sleep data with biosignals
        let sleepSession = SleepData(
            date: startTime ?? Date(),
            duration: elapsedTime,
            avgHeartRate: connectivityManager.isWatchConnected ? connectivityManager.latestHeartRate : (65 + Double.random(in: -5...10)),
            heartRateVariability: connectivityManager.isWatchConnected ? connectivityManager.latestHRV : Double.random(in: 30...70),
            movementIntensity: Double.random(in: 0.2...0.6),
            remPercentage: Double.random(in: 15...30),
            deepSleepPercentage: Double.random(in: 20...35),
            ambientNoiseLevel: Double.random(in: 0.1...0.4)
        )
        
        // Set the session ID so Watch data can be correlated
        if let sessionId = currentSessionId {
            sleepSession.id = sessionId
        }
        
        modelContext.insert(sleepSession)
        
        // Generate AI interpretation asynchronously
        isProcessingAI = true
        Task {
            if let interpretation = await aiService.interpretDream(from: sleepSession) {
                // Store AI interpretation in sleep data
                sleepSession.aiNarrative = interpretation.narrative
                sleepSession.aiThemes = interpretation.themes
                sleepSession.aiSymbolism = interpretation.symbolism
                sleepSession.aiIntensity = interpretation.intensity
                sleepSession.aiConsciousness = interpretation.consciousness
                sleepSession.aiVisualPrompt = interpretation.visualPrompt
                
                // Update mood if AI provides different interpretation
                if !interpretation.mood.isEmpty {
                    sleepSession.dreamMood = interpretation.mood
                }
            }
            
            isProcessingAI = false
            currentSessionId = nil
            
            // Dismiss and go back to main view
            dismiss()
        }
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
