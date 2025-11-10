//
//  ContentView.swift
//  DreamWeaverIphoneAI Watch App
//
//  Simplified start/stop interface for the DreamWeaver watch experience.
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
    @State private var heartRateTimer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
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
            
            Button(action: toggleTracking) {
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
            .buttonStyle(.plain)
            
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
        .onAppear(perform: setupWatchApp)
        .onDisappear { heartRateTimer?.invalidate() }
        .onReceive(workoutManager.$isPhoneReachable) { reachable in
            isConnectedToiPhone = reachable
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func setupWatchApp() {
        workoutManager.requestAuthorization()
        isConnectedToiPhone = workoutManager.isPhoneReachable
        heartRateTimer?.invalidate()
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            heartRate = workoutManager.heartRate
        }
    }
    
    private func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }
    
    private func startTracking() {
        workoutManager.startManualSession()
        isTracking = true
    }
    
    private func stopTracking() {
        workoutManager.stopManualSession()
        isTracking = false
        heartRate = 0.0
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        print("❌ Watch error: \(message)")
    }
}

// MARK: - Workout Manager

final class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var isTracking = false
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isAuthorized = false
    @Published var isPhoneReachable = false
    
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var startDate: Date?
    private var timer: Timer?
    private var dataTimer: Timer?
    private var currentSessionId: UUID?
    private var isSimulatedSession = false
    private var wcSession: WCSession?
    
    private var healthDataAvailable: Bool {
#if targetEnvironment(simulator)
        return false
#else
        return HKHealthStore.isHealthDataAvailable()
#endif
    }
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    func requestAuthorization() {
        guard healthDataAvailable else {
            DispatchQueue.main.async { self.isAuthorized = false }
            return
        }
        
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async { self.isAuthorized = success }
        }
    }
    
    func startManualSession() {
        currentSessionId = UUID()
        startWorkout()
    }
    
    func stopManualSession() {
        stopWorkout()
    }
    
    private func startWorkout() {
        if !healthDataAvailable {
            startSimulatedSession()
            return
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            session?.delegate = self
            builder?.delegate = self
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            startDate = Date()
            if let startDate {
                session?.startActivity(with: startDate)
                builder?.beginCollection(withStart: startDate) { success, error in
                    if let error {
                        print("⚠️ beginCollection error: \(error.localizedDescription)")
                    } else if !success {
                        print("⚠️ beginCollection reported failure without error")
                    }
                }
            }
            DispatchQueue.main.async { self.isTracking = true }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self, let start = self.startDate else { return }
                DispatchQueue.main.async { self.elapsedTime = Date().timeIntervalSince(start) }
            }
            
            dataTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                self?.sendBiosignalDataToiPhone()
            }
            
            let sessionId = currentSessionId ?? UUID()
            currentSessionId = sessionId
            sendMessageToiPhone([
                "command": "sessionStarted",
                "sessionId": sessionId.uuidString,
                "timestamp": Date().timeIntervalSince1970
            ])
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
            startSimulatedSession()
        }
    }
    
    private func stopWorkout() {
        session?.end()
        timer?.invalidate()
        timer = nil
        dataTimer?.invalidate()
        dataTimer = nil
        
        if isSimulatedSession {
            stopSimulatedSession()
            return
        }
        
        sendBiosignalDataToiPhone()
        DispatchQueue.main.async { self.isTracking = false }
        
        let sessionId = currentSessionId ?? UUID()
        sendMessageToiPhone([
            "command": "sessionStopped",
            "sessionId": sessionId.uuidString,
            "timestamp": Date().timeIntervalSince1970
        ])
        currentSessionId = nil
    }
    
    private func startSimulatedSession() {
        let sessionId = currentSessionId ?? UUID()
        currentSessionId = sessionId
        isSimulatedSession = true
        startDate = Date()
        DispatchQueue.main.async {
            self.isTracking = true
            self.elapsedTime = 0
        }
        
        timer?.invalidate()
        dataTimer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            DispatchQueue.main.async { self.elapsedTime = Date().timeIntervalSince(start) }
        }
        
        dataTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let simulatedHeartRate = Double.random(in: 55...75)
            let simulatedHRV = Double.random(in: 35...75)
            DispatchQueue.main.async {
                self.heartRate = simulatedHeartRate
                self.hrv = simulatedHRV
            }
            self.sendBiosignalDataToiPhone()
        }
        
        sendMessageToiPhone([
            "command": "sessionStarted",
            "sessionId": sessionId.uuidString,
            "timestamp": Date().timeIntervalSince1970,
            "simulated": true
        ])
    }
    
    private func stopSimulatedSession() {
        let sessionId = currentSessionId
        isSimulatedSession = false
        DispatchQueue.main.async { self.isTracking = false }
        timer?.invalidate()
        dataTimer?.invalidate()
        timer = nil
        dataTimer = nil
        if let sessionId {
            sendMessageToiPhone([
                "command": "sessionStopped",
                "sessionId": sessionId.uuidString,
                "timestamp": Date().timeIntervalSince1970,
                "simulated": true
            ])
        }
        currentSessionId = nil
    }
    
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
        if let session = wcSession, session.isReachable {
            session.sendMessage(data, replyHandler: { _ in
                print("✅ Biosignal data sent: HR=\(self.heartRate), HRV=\(self.hrv)")
            }, errorHandler: { error in
                print("❌ Failed to send biosignal data: \(error.localizedDescription)")
                self.sendContextUpdate(data)
            })
        } else {
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
}

// MARK: - HealthKit Delegates

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            switch toState {
            case .running:
                self.isTracking = true
            case .ended:
                self.isTracking = false
                self.builder?.endCollection(withEnd: date) { _, error in
                    if let error {
                        print("Failed to end collection: \(error.localizedDescription)")
                    }
                    self.builder?.finishWorkout { _, error in
                        if let error {
                            print("Failed to finish workout: \(error.localizedDescription)")
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
                let statistics = workoutBuilder.statistics(for: quantityType)
                updateHeartRate(statistics)
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    
    private func updateHeartRate(_ statistics: HKStatistics?) {
        guard let statistics, let quantity = statistics.mostRecentQuantity() else { return }
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = quantity.doubleValue(for: heartRateUnit)
        DispatchQueue.main.async { self.heartRate = value }
    }
}

// MARK: - Watch Connectivity

extension WorkoutManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("⌚️ Watch session activated: \(activationState.rawValue)")
        DispatchQueue.main.async { self.isPhoneReachable = session.isReachable }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isPhoneReachable = session.isReachable }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("⌚️ Received message from iPhone: \(message)")
        guard let command = message["command"] as? String else {
            replyHandler(["status": "no command"])
            return
        }
        switch command {
        case "startSleep":
            if let sessionIdString = message["sessionId"] as? String, let sessionId = UUID(uuidString: sessionIdString) {
                DispatchQueue.main.async {
                    self.currentSessionId = sessionId
                    self.startWorkout()
                }
                replyHandler(["status": "started"])
            } else {
                replyHandler(["status": "invalid session id"])
            }
        case "stopSleep":
            DispatchQueue.main.async { self.stopWorkout() }
            replyHandler(["status": "stopped"])
        case "getCurrentMetrics":
            replyHandler([
                "heartRate": heartRate,
                "hrv": hrv,
                "timestamp": Date().timeIntervalSince1970
            ])
        case "ping":
            replyHandler([
                "status": "pong",
                "appRunning": true,
                "timestamp": Date().timeIntervalSince1970
            ])
        default:
            replyHandler(["status": "unknown command"])
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
