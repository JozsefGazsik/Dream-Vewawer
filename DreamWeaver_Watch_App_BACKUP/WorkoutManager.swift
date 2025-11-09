//
//  WorkoutManager.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import Foundation
import HealthKit
import Combine
import WatchConnectivity

class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var isTracking = false
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var startDate: Date?
    var timer: Timer?
    var dataTimer: Timer?
    var currentSessionId: UUID?
    
    private var wcSession: WCSession?
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    // Request HealthKit authorization
    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    // Start workout session
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            session?.delegate = self
            builder?.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            startDate = Date()
            session?.startActivity(with: startDate)
            builder?.beginCollection(withStart: startDate!) { success, error in
                if let error = error {
                    print("Failed to begin collection: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                self.isTracking = true
            }
            
            // Start timer for elapsed time
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self, let startDate = self.startDate else { return }
                DispatchQueue.main.async {
                    self.elapsedTime = Date().timeIntervalSince(startDate)
                }
            }
            
            // Send biosignal data to iPhone every 5 minutes
            dataTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                self?.sendBiosignalDataToiPhone()
            }
            
            // Send confirmation to iPhone
            sendMessageToiPhone([
                "command": "sessionStarted",
                "timestamp": Date().timeIntervalSince1970
            ])
            
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
        }
    }
    
    // Stop workout session
    func stopWorkout() {
        session?.end()
        timer?.invalidate()
        timer = nil
        dataTimer?.invalidate()
        dataTimer = nil
        
        // Send final data to iPhone
        sendBiosignalDataToiPhone()
        
        DispatchQueue.main.async {
            self.isTracking = false
        }
        
        // Send confirmation to iPhone
        sendMessageToiPhone([
            "command": "sessionStopped",
            "timestamp": Date().timeIntervalSince1970
        ])
        
        currentSessionId = nil
    }
    
    // MARK: - WatchConnectivity
    
    private func sendMessageToiPhone(_ message: [String: Any]) {
        guard let session = wcSession, session.isReachable else {
            print("❌ iPhone not reachable")
            return
        }
        
        session.sendMessage(message, replyHandler: { reply in
            print("✅ iPhone replied: \(reply)")
        }, errorHandler: { error in
            print("❌ Failed to send to iPhone: \(error.localizedDescription)")
        })
    }
    
    private func sendBiosignalDataToiPhone() {
        guard let sessionId = currentSessionId else {
            print("⚠️ No active session ID")
            return
        }
        
        let data: [String: Any] = [
            "type": "biosignalData",
            "sessionId": sessionId.uuidString,
            "heartRate": heartRate,
            "hrv": hrv,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Try to send immediately
        if let session = wcSession, session.isReachable {
            session.sendMessage(data, replyHandler: { reply in
                print("✅ Biosignal data sent: HR=\(self.heartRate), HRV=\(self.hrv)")
            }, errorHandler: { error in
                print("❌ Failed to send biosignal data: \(error.localizedDescription)")
                // Fallback to context update
                self.sendContextUpdate(data)
            })
        } else {
            // iPhone not reachable, use context update for background transfer
            sendContextUpdate(data)
        }
    }
    
    private func sendContextUpdate(_ data: [String: Any]) {
        guard let session = wcSession else { return }
        
        do {
            try session.updateApplicationContext(data)
            print("✅ Context updated with biosignal data")
        } catch {
            print("❌ Failed to update context: \(error.localizedDescription)")
        }
    }
    
    // Update heart rate and HRV
    func updateHeartRate(_ samples: [HKQuantitySample]) {
        guard let sample = samples.first else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = sample.quantity.doubleValue(for: heartRateUnit)
        
        DispatchQueue.main.async {
            self.heartRate = value
        }
        
        // Calculate HRV (simplified - in production use proper HRV calculation)
        if samples.count > 1 {
            let intervals = samples.map { $0.quantity.doubleValue(for: heartRateUnit) }
            let mean = intervals.reduce(0, +) / Double(intervals.count)
            let variance = intervals.map { pow($0 - mean, 2) }.reduce(0, +) / Double(intervals.count)
            let calculatedHRV = sqrt(variance)
            
            DispatchQueue.main.async {
                self.hrv = calculatedHRV
            }
        }
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                       didChangeTo toState: HKWorkoutSessionState,
                       from fromState: HKWorkoutSessionState,
                       date: Date) {
        DispatchQueue.main.async {
            switch toState {
            case .running:
                self.isTracking = true
            case .ended:
                self.isTracking = false
                self.builder?.endCollection(withEnd: date) { success, error in
                    self.builder?.finishWorkout { workout, error in
                        if let error = error {
                            print("Failed to finish workout: \(error.localizedDescription)")
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                       didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                       didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
                let statistics = workoutBuilder.statistics(for: quantityType)
                updateHeartRate(statistics)
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events
    }
    
    private func updateHeartRate(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        
        if let quantity = statistics.mostRecentQuantity() {
            let value = quantity.doubleValue(for: heartRateUnit)
            DispatchQueue.main.async {
                self.heartRate = value
            }
        }
    }
}

// MARK: - WCSessionDelegate (Watch)
extension WorkoutManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("⌚️ Watch session activated: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("⌚️ Received message from iPhone: \(message)")
        
        if let command = message["command"] as? String {
            switch command {
            case "startSleep":
                if let sessionIdString = message["sessionId"] as? String,
                   let sessionId = UUID(uuidString: sessionIdString) {
                    DispatchQueue.main.async {
                        self.currentSessionId = sessionId
                        self.startWorkout()
                    }
                    replyHandler(["status": "started"])
                }
            case "stopSleep":
                DispatchQueue.main.async {
                    self.stopWorkout()
                }
                replyHandler(["status": "stopped"])
            case "getCurrentMetrics":
                replyHandler([
                    "heartRate": heartRate,
                    "hrv": hrv,
                    "timestamp": Date().timeIntervalSince1970
                ])
            case "ping":
                // Respond to connectivity check from iPhone
                replyHandler([
                    "status": "pong",
                    "appRunning": true,
                    "timestamp": Date().timeIntervalSince1970
                ])
            default:
                replyHandler(["status": "unknown command"])
            }
        } else {
            replyHandler(["status": "no command"])
        }
    }
}
