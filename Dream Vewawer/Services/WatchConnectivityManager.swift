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
    @Published var isSessionActive = false
    
    private var modelContext: ModelContext?
    private var session: WCSession?
    private var sessionStartTimes: [UUID: Date] = [:]
    private var sessionSources: [UUID: SessionSource] = [:]
    
    private enum SessionSource {
        case phone
        case watch
    }
    
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
    
    func registerLocalSession(sessionId: UUID, startDate: Date) {
        sessionStartTimes[sessionId] = startDate
        sessionSources[sessionId] = .phone
        DispatchQueue.main.async {
            self.activeSleepSessionId = sessionId
            self.isSessionActive = true
        }
        ensureSleepSessionExists(for: sessionId, startDate: startDate)
    }
    
    func completeLocalSession(sessionId: UUID) {
        sessionStartTimes.removeValue(forKey: sessionId)
        sessionSources.removeValue(forKey: sessionId)
        DispatchQueue.main.async {
            if self.activeSleepSessionId == sessionId {
                self.activeSleepSessionId = nil
                self.isSessionActive = false
            }
        }
    }
    
    private func registerWatchSession(sessionId: UUID, startDate: Date) {
        sessionStartTimes[sessionId] = startDate
        if sessionSources[sessionId] == nil {
            sessionSources[sessionId] = .watch
        }
        DispatchQueue.main.async {
            self.activeSleepSessionId = sessionId
            self.isSessionActive = true
        }
        ensureSleepSessionExists(for: sessionId, startDate: startDate)
    }
    
    private func ensureSleepSessionExists(for sessionId: UUID, startDate: Date) {
        DispatchQueue.main.async {
            guard let modelContext = self.modelContext else { return }
            let descriptor = FetchDescriptor<SleepData>(
                predicate: #Predicate { $0.id == sessionId }
            )
            do {
                if try modelContext.fetch(descriptor).first == nil {
                    let placeholder = SleepData(date: startDate)
                    placeholder.id = sessionId
                    modelContext.insert(placeholder)
                    try modelContext.save()
                    print("🆕 Created placeholder sleep session \(sessionId)")
                }
            } catch {
                print("❌ Failed to prepare sleep session: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Send to Watch
    
    func startSleepSession(sessionId: UUID) {
        let startDate = Date()
        registerLocalSession(sessionId: sessionId, startDate: startDate)
        
        guard let session = session, session.isReachable else {
            print("❌ Watch not reachable")
            return
        }
        let message: [String: Any] = [
            "command": "startSleep",
            "sessionId": sessionId.uuidString,
            "timestamp": startDate.timeIntervalSince1970
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
        // Handle session lifecycle
        else if let command = message["command"] as? String, command == "sessionStarted" {
            if let sessionIdString = message["sessionId"] as? String,
               let sessionId = UUID(uuidString: sessionIdString) {
                let timestamp = message["timestamp"] as? Double ?? Date().timeIntervalSince1970
                let startDate = Date(timeIntervalSince1970: timestamp)
                registerWatchSession(sessionId: sessionId, startDate: startDate)
                print("✅ Watch confirmed session started (ID: \(sessionId))")
            } else {
                print("⚠️ Session started message missing sessionId")
            }
            replyHandler(["status": "acknowledged"])
        }
        else if let command = message["command"] as? String, command == "sessionStopped" {
            if let sessionIdString = message["sessionId"] as? String,
               let sessionId = UUID(uuidString: sessionIdString) {
                let timestamp = message["timestamp"] as? Double ?? Date().timeIntervalSince1970
                let stopDate = Date(timeIntervalSince1970: timestamp)
                finalizeSleepSession(sessionId: sessionId, stopDate: stopDate)
                print("✅ Watch confirmed session stopped (ID: \(sessionId))")
            } else {
                print("⚠️ Session stopped message missing sessionId")
            }
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
    
    private func finalizeSleepSession(sessionId: UUID, stopDate: Date) {
        guard sessionSources[sessionId] != .phone else {
            return
        }
        
        DispatchQueue.main.async {
            guard let modelContext = self.modelContext else { return }
            let descriptor = FetchDescriptor<SleepData>(
                predicate: #Predicate { $0.id == sessionId }
            )
            do {
                let existingSession = try modelContext.fetch(descriptor).first
                let startDate = self.sessionStartTimes[sessionId] ?? existingSession?.date ?? stopDate
                let duration = max(stopDate.timeIntervalSince(startDate), existingSession?.duration ?? 0)
                
                if let sleepSession = existingSession {
                    let timeline = sleepSession.biosignalTimeline.sorted { $0.timestamp < $1.timestamp }
                    let avgHeartRate = self.averageValue(for: timeline, keyPath: \BiosignalDataPoint.heartRate)
                    let avgHRV = self.averageValue(for: timeline, keyPath: \BiosignalDataPoint.hrv)
                    let fallbackHeartRate = self.latestHeartRate > 0 ? self.latestHeartRate : sleepSession.avgHeartRate
                    let fallbackHRV = self.latestHRV > 0 ? self.latestHRV : sleepSession.heartRateVariability
                    
                    sleepSession.date = startDate
                    sleepSession.duration = duration
                    sleepSession.avgHeartRate = timeline.isEmpty ? fallbackHeartRate : avgHeartRate
                    sleepSession.heartRateVariability = timeline.isEmpty ? fallbackHRV : avgHRV
                    let movement = self.averageValue(for: timeline, keyPath: \BiosignalDataPoint.movement)
                    if movement > 0 {
                        sleepSession.movementIntensity = movement
                    } else if sleepSession.movementIntensity == 0 {
                        sleepSession.movementIntensity = 0.35
                    }
                    if sleepSession.remPercentage == 0 {
                        sleepSession.remPercentage = Double.random(in: 15...30)
                    }
                    if sleepSession.deepSleepPercentage == 0 {
                        sleepSession.deepSleepPercentage = Double.random(in: 20...35)
                    }
                    if sleepSession.ambientNoiseLevel == 0 {
                        sleepSession.ambientNoiseLevel = Double.random(in: 0.1...0.4)
                    }
                    let mood = SleepData.calculateDreamMood(
                        hrv: sleepSession.heartRateVariability,
                        movement: sleepSession.movementIntensity,
                        rem: sleepSession.remPercentage
                    )
                    sleepSession.dreamMood = mood
                    sleepSession.dreamColors = SleepData.generateDreamColors(
                        mood: mood,
                        hrv: sleepSession.heartRateVariability,
                        noise: sleepSession.ambientNoiseLevel
                    )
                    
                    try modelContext.save()
                    self.runAIInterpretation(for: sleepSession, in: modelContext)
                } else {
                    let placeholder = SleepData(
                        date: startDate,
                        duration: duration,
                        avgHeartRate: self.latestHeartRate > 0 ? self.latestHeartRate : 65,
                        heartRateVariability: self.latestHRV > 0 ? self.latestHRV : 50,
                        movementIntensity: 0.35,
                        remPercentage: Double.random(in: 15...30),
                        deepSleepPercentage: Double.random(in: 20...35),
                        ambientNoiseLevel: Double.random(in: 0.1...0.4)
                    )
                    placeholder.id = sessionId
                    let mood = SleepData.calculateDreamMood(
                        hrv: placeholder.heartRateVariability,
                        movement: placeholder.movementIntensity,
                        rem: placeholder.remPercentage
                    )
                    placeholder.dreamMood = mood
                    placeholder.dreamColors = SleepData.generateDreamColors(
                        mood: mood,
                        hrv: placeholder.heartRateVariability,
                        noise: placeholder.ambientNoiseLevel
                    )
                    modelContext.insert(placeholder)
                    try modelContext.save()
                    self.runAIInterpretation(for: placeholder, in: modelContext)
                }
            } catch {
                print("❌ Failed to finalize sleep session: \(error.localizedDescription)")
            }
            
            self.sessionStartTimes.removeValue(forKey: sessionId)
            self.sessionSources.removeValue(forKey: sessionId)
            if self.activeSleepSessionId == sessionId {
                self.activeSleepSessionId = nil
                self.isSessionActive = false
            }
        }
    }
    
    private func averageValue(for timeline: [BiosignalDataPoint], keyPath: KeyPath<BiosignalDataPoint, Double>) -> Double {
        guard !timeline.isEmpty else { return 0 }
        let total = timeline.reduce(0) { $0 + $1[keyPath: keyPath] }
        return total / Double(timeline.count)
    }
    
    private func runAIInterpretation(for sleepSession: SleepData, in modelContext: ModelContext) {
        let aiService = AIDreamService()
        Task {
            if let interpretation = await aiService.interpretDream(from: sleepSession) {
                await MainActor.run {
                    sleepSession.aiNarrative = interpretation.narrative
                    sleepSession.aiThemes = interpretation.themes
                    sleepSession.aiSymbolism = interpretation.symbolism
                    sleepSession.aiIntensity = interpretation.intensity
                    sleepSession.aiConsciousness = interpretation.consciousness
                    sleepSession.aiVisualPrompt = interpretation.visualPrompt
                    if !interpretation.mood.isEmpty {
                        sleepSession.dreamMood = interpretation.mood
                        sleepSession.dreamColors = SleepData.generateDreamColors(
                            mood: interpretation.mood,
                            hrv: sleepSession.heartRateVariability,
                            noise: sleepSession.ambientNoiseLevel
                        )
                    }
                    do {
                        try modelContext.save()
                    } catch {
                        print("❌ Failed to save AI interpretation: \(error.localizedDescription)")
                    }
                }
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
