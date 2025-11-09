//
//  WatchConnectivityManager.swift
//  Dream Vewawer
//
//  Bidirectional communication between iPhone and Apple Watch
//

import Foundation
import WatchConnectivity
import SwiftData
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isWatchConnected = false
    @Published var isWatchAppInstalled = false
    @Published var latestHeartRate: Double = 0
    @Published var latestHRV: Double = 0
    @Published var activeSleepSessionId: UUID?
    
    private var modelContext: ModelContext?
    private var session: WCSession?
    
    override private init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Send to Watch
    
    func startSleepSession(sessionId: UUID) {
        guard let session = session, session.isReachable else {
            print("❌ Watch not reachable")
            return
        }
        
        activeSleepSessionId = sessionId
        
        let message: [String: Any] = [
            "command": "startSleep",
            "sessionId": sessionId.uuidString,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            print("✅ Watch started sleep tracking: \(reply)")
        }, errorHandler: { error in
            print("❌ Failed to start watch tracking: \(error.localizedDescription)")
        })
    }
    
    func stopSleepSession() {
        guard let session = session, session.isReachable else {
            print("❌ Watch not reachable")
            return
        }
        
        let message: [String: Any] = [
            "command": "stopSleep",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            print("✅ Watch stopped sleep tracking: \(reply)")
        }, errorHandler: { error in
            print("❌ Failed to stop watch tracking: \(error.localizedDescription)")
        })
        
        activeSleepSessionId = nil
    }
    
    func requestCurrentMetrics() {
        guard let session = session, session.isReachable else { return }
        
        let message: [String: Any] = ["command": "getCurrentMetrics"]
        
        session.sendMessage(message, replyHandler: { reply in
            if let hr = reply["heartRate"] as? Double {
                DispatchQueue.main.async {
                    self.latestHeartRate = hr
                }
            }
            if let hrv = reply["hrv"] as? Double {
                DispatchQueue.main.async {
                    self.latestHRV = hrv
                }
            }
        }, errorHandler: nil)
    }
    
    // MARK: - Transfer Context (for background updates)
    
    func updateContext(with data: [String: Any]) {
        guard let session = session else { return }
        
        do {
            try session.updateApplicationContext(data)
            print("✅ Updated watch context")
        } catch {
            print("❌ Failed to update context: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Connectivity Check
    
    private func pingWatchApp() {
        guard let session = session, session.isReachable else { return }
        
        let pingMessage: [String: Any] = ["command": "ping", "timestamp": Date().timeIntervalSince1970]
        
        session.sendMessage(pingMessage, replyHandler: { reply in
            DispatchQueue.main.async {
                self.isWatchAppInstalled = true
                print("✅ Watch app responded to ping - confirmed installed and running")
            }
        }, errorHandler: { error in
            print("⚠️ Watch app ping failed: \(error.localizedDescription)")
        })
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchConnected = activationState == .activated
            
            // Workaround for .appex not being detected as installed
            // If session is reachable, assume Watch app is available
            if session.isReachable {
                self.isWatchAppInstalled = true
                print("📱 Watch is reachable - assuming app is installed")
            } else {
                self.isWatchAppInstalled = session.isWatchAppInstalled
            }
            
            print("📱 Watch Connection State: \(activationState.rawValue)")
            print("📱 Watch App Installed (reported): \(session.isWatchAppInstalled)")
            print("📱 Watch App Installed (effective): \(self.isWatchAppInstalled)")
            print("📱 Watch Reachable: \(session.isReachable)")
            
            // Try to ping the Watch app to verify it's actually running
            if session.isReachable {
                self.pingWatchApp()
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ Watch session deactivated")
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = session.isReachable
            
            // Update app installed status based on reachability
            if session.isReachable {
                self.isWatchAppInstalled = true
                print("📱 Watch became reachable - app is available")
                self.pingWatchApp()
            }
            
            print("📱 Watch reachability changed: \(session.isReachable)")
        }
    }
    
    // MARK: - Receive from Watch
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        print("📨 Received message from Watch: \(message)")
        
        // Handle heart rate data
        if let messageType = message["type"] as? String, messageType == "biosignalData" {
            handleBiosignalData(message)
            replyHandler(["status": "received"])
        }
        // Handle session start confirmation
        else if let command = message["command"] as? String, command == "sessionStarted" {
            print("✅ Watch confirmed session started")
            replyHandler(["status": "acknowledged"])
        }
        // Handle session stop confirmation
        else if let command = message["command"] as? String, command == "sessionStopped" {
            print("✅ Watch confirmed session stopped")
            replyHandler(["status": "acknowledged"])
        }
        else {
            replyHandler(["status": "unknown"])
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📨 Received context from Watch: \(applicationContext)")
        handleBiosignalData(applicationContext)
    }
    
    // MARK: - Data Handling
    
    private func handleBiosignalData(_ data: [String: Any]) {
        guard let modelContext = modelContext else {
            print("❌ No model context available")
            return
        }
        
        guard let sessionIdString = data["sessionId"] as? String,
              let sessionId = UUID(uuidString: sessionIdString) else {
            print("❌ Invalid session ID")
            return
        }
        
        let heartRate = data["heartRate"] as? Double ?? 0
        let hrv = data["hrv"] as? Double ?? 0
        let timestamp = data["timestamp"] as? Double ?? Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timestamp)
        
        DispatchQueue.main.async {
            self.latestHeartRate = heartRate
            self.latestHRV = hrv
            
            // Find the active sleep session and add biosignal data point
            let descriptor = FetchDescriptor<SleepData>(
                predicate: #Predicate { $0.id == sessionId }
            )
            
            do {
                if let sleepSession = try modelContext.fetch(descriptor).first {
                    let dataPoint = BiosignalDataPoint(
                        timestamp: date,
                        heartRate: heartRate,
                        hrv: hrv
                    )
                    sleepSession.biosignalTimeline.append(dataPoint)
                    
                    try modelContext.save()
                    print("✅ Saved biosignal data: HR=\(heartRate), HRV=\(hrv)")
                } else {
                    print("⚠️ Sleep session not found: \(sessionId)")
                }
            } catch {
                print("❌ Failed to save biosignal data: \(error)")
            }
        }
    }
}

#if os(iOS)
extension WatchConnectivityManager {
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
}
#endif
