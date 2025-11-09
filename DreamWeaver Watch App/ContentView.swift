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
        VStack(spacing: 8) {
            // Nagy, feltűnő cím
            Text("🌙 DREAM")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            
            Text("TRACKER")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Rectangle()
                .fill(Color.yellow)
                .frame(height: 2)
                .padding(.horizontal, 20)
            
            // Státusz
            Group {
                if isConnectedToiPhone {
                    Text("📱 CONNECTED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("📱 OFFLINE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            // Pulzus
            Group {
                if heartRate > 0 {
                    VStack(spacing: 2) {
                        Text("💓")
                            .font(.title2)
                        Text("\(Int(heartRate))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("BPM")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(spacing: 2) {
                        Text("💓")
                            .font(.title2)
                        Text("---")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        Text("BPM")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Nagy, egyszerű gomb
            Button(action: {
                print("🔘 WATCH BUTTON PRESSED! Current state: \(isTracking)")
                if isTracking {
                    stopTracking()
                } else {
                    startTracking()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: isTracking ? "stop.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(isTracking ? "STOP" : "START")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isTracking ? Color.red : Color.green)
                .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isTracking {
                Text("⏱️ TRACKING...")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            print("🔄 Watch ContentView appeared!")
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
