//
//  ContentView.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI
import HealthKit
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var isTracking = false
    @State private var heartRate: Double = 0.0
    @State private var isConnectedToiPhone = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // App title & icon
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("DreamWeaver")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Connection status
            HStack {
                Circle()
                    .fill(isConnectedToiPhone ? .green : .red)
                    .frame(width: 8, height: 8)
                
                Text(isConnectedToiPhone ? "iPhone Connected" : "iPhone Disconnected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Heart rate display
            if heartRate > 0 {
                VStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                    
                    Text("\(Int(heartRate)) BPM")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            
            // Main button
            Button(action: {
                if isTracking {
                    stopTracking()
                } else {
                    startTracking()
                }
            }) {
                Text(isTracking ? "Stop Sleep" : "Start Sleep")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isTracking ? Color.red : Color.blue)
                    .cornerRadius(22)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isTracking {
                Text("Tracking...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            setupWatchApp()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Functions
    
    private func setupWatchApp() {
        print("🌙 DreamWeaver Watch App - Indulás")
        workoutManager.requestAuthorization()
        checkiPhoneConnection()
        
        // Heart rate frissítés figyelése
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            updateHeartRate()
        }
    }
    
    private func startTracking() {
        print("▶️ Sleep tracking indítása...")
        
        workoutManager.startWorkout()
        isTracking = true
        
        // Értesítsd az iPhone-t
        sendMessageToiPhone(["action": "start_sleep"])
    }
    
    private func stopTracking() {
        print("⏹️ Sleep tracking leállítása...")
        
        workoutManager.stopWorkout()
        isTracking = false
        heartRate = 0.0
        
        // Értesítsd az iPhone-t
        sendMessageToiPhone(["action": "stop_sleep"])
    }
    
    private func updateHeartRate() {
        // WorkoutManager-ből kérdezd le a legfrissebb pulzust
        heartRate = workoutManager.heartRate
    }
    
    private func checkiPhoneConnection() {
        if WCSession.default.isReachable {
            isConnectedToiPhone = true
        } else {
            isConnectedToiPhone = false
        }
    }
    
    private func sendMessageToiPhone(_ message: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("📱 iPhone nem elérhető")
            return
        }
        
        WCSession.default.sendMessage(message) { response in
            print("📱 iPhone válasz: \(response)")
        } errorHandler: { error in
            print("📱 iPhone üzenet hiba: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        print("❌ Hiba: \(message)")
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
