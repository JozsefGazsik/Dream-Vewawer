// Copied advanced WorkoutManager implementation for DreamWeaverIphoneAI Watch App
import Foundation
import HealthKit
import Combine
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    @Published var isTracking = false
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isAuthorized = false
    @Published var isPhoneReachable = false
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var startDate: Date?
    var timer: Timer?
    var dataTimer: Timer?
    var currentSessionId: UUID?
    private var isSimulatedSession = false
    #if canImport(WatchConnectivity)
    private var wcSession: WCSession?
    #endif
    private var healthDataAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return HKHealthStore.isHealthDataAvailable()
        #endif
    }
    override init() {
        super.init()
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        #endif
    }
    func requestAuthorization() {
        // Check if HealthKit is available first
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit not available on this device")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
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
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HealthKit authorization error: \(error.localizedDescription)")
                    self.isAuthorized = false
                } else {
                    print("✅ HealthKit authorization: \(success ? "granted" : "denied")")
                    self.isAuthorized = success
                }
            }
        }
    }
    func startWorkout() {
        if currentSessionId == nil { currentSessionId = UUID() }
        if !healthDataAvailable { startSimulatedSession(); return }
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
            session?.startActivity(with: startDate)
            builder?.beginCollection(withStart: startDate!) { success, error in if let error = error { print("Failed to begin collection: \(error.localizedDescription)") } }
            DispatchQueue.main.async { self.isTracking = true }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self, let startDate = self.startDate else { return }
                DispatchQueue.main.async { self.elapsedTime = Date().timeIntervalSince(startDate) }
            }
            dataTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in self?.sendBiosignalDataToiPhone() }
            sendMessageToiPhone(["command": "sessionStarted", "sessionId": currentSessionId?.uuidString ?? UUID().uuidString, "timestamp": Date().timeIntervalSince1970])
        } catch { print("Failed to start workout: \(error.localizedDescription)"); startSimulatedSession() }
    }
    func stopWorkout() {
        session?.end(); timer?.invalidate(); timer = nil; dataTimer?.invalidate(); dataTimer = nil
        if isSimulatedSession { stopSimulatedSession(); return }
        sendBiosignalDataToiPhone(); DispatchQueue.main.async { self.isTracking = false }
        let sessionId = currentSessionId ?? UUID()
        sendMessageToiPhone(["command": "sessionStopped", "sessionId": sessionId.uuidString, "timestamp": Date().timeIntervalSince1970])
        currentSessionId = nil
    }
    func startManualSession() { currentSessionId = UUID(); startWorkout() }
    func stopManualSession() { stopWorkout() }
    private func startSimulatedSession() {
        let sessionId = currentSessionId ?? UUID(); currentSessionId = sessionId; isSimulatedSession = true; startDate = Date()
        DispatchQueue.main.async { self.isTracking = true; self.elapsedTime = 0 }
        timer?.invalidate(); dataTimer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in guard let self = self, let start = self.startDate else { return }; DispatchQueue.main.async { self.elapsedTime = Date().timeIntervalSince(start) } }
        dataTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in guard let self = self else { return }; let simulatedHeartRate = Double.random(in: 55...75); let simulatedHRV = Double.random(in: 35...75); DispatchQueue.main.async { self.heartRate = simulatedHeartRate; self.hrv = simulatedHRV }; self.sendBiosignalDataToiPhone() }
        sendMessageToiPhone(["command": "sessionStarted", "sessionId": sessionId.uuidString, "timestamp": Date().timeIntervalSince1970, "simulated": true])
    }
    private func stopSimulatedSession() {
        let sessionId = currentSessionId; isSimulatedSession = false; DispatchQueue.main.async { self.isTracking = false }
        timer?.invalidate(); dataTimer?.invalidate(); timer = nil; dataTimer = nil
        if let sessionId { sendMessageToiPhone(["command": "sessionStopped", "sessionId": sessionId.uuidString, "timestamp": Date().timeIntervalSince1970, "simulated": true]) }
        currentSessionId = nil
    }
    private func sendMessageToiPhone(_ message: [String: Any]) {
        #if canImport(WatchConnectivity)
        guard let session = wcSession, session.isReachable else { print("❌ iPhone not reachable"); return }
        session.sendMessage(message, replyHandler: { reply in print("✅ iPhone replied: \(reply)") }, errorHandler: { error in print("❌ Failed to send to iPhone: \(error.localizedDescription)") })
        #endif
    }
    private func sendBiosignalDataToiPhone() {
        guard let sessionId = currentSessionId else { print("⚠️ No active session ID"); return }
        let data: [String: Any] = ["type": "biosignalData", "sessionId": sessionId.uuidString, "heartRate": heartRate, "hrv": hrv, "timestamp": Date().timeIntervalSince1970]
        #if canImport(WatchConnectivity)
        if let session = wcSession, session.isReachable { session.sendMessage(data, replyHandler: { reply in print("✅ Biosignal data sent: HR=\(self.heartRate), HRV=\(self.hrv)") }, errorHandler: { error in print("❌ Failed to send biosignal data: \(error.localizedDescription)\nFalling back to context update"); self.sendContextUpdate(data) }) } else { sendContextUpdate(data) }
        #endif
    }
    private func sendContextUpdate(_ data: [String: Any]) {
        #if canImport(WatchConnectivity)
        guard let session = wcSession else { return }
        do { try session.updateApplicationContext(data); print("✅ Context updated with biosignal data") } catch { print("❌ Failed to update context: \(error.localizedDescription)") }
        #endif
    }
    func updateHeartRate(_ samples: [HKQuantitySample]) { guard let sample = samples.first else { return }; let unit = HKUnit.count().unitDivided(by: .minute()); let value = sample.quantity.doubleValue(for: unit); DispatchQueue.main.async { self.heartRate = value } }
}
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async { switch toState { case .running: self.isTracking = true; case .ended: self.isTracking = false; self.builder?.endCollection(withEnd: date) { success, error in self.builder?.finishWorkout { _, error in if let error = error { print("Failed to finish workout: \(error.localizedDescription)") } } }; default: break } }
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) { print("Workout session failed: \(error.localizedDescription)") }
}
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes { guard let quantityType = type as? HKQuantityType else { continue }; if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) { let statistics = workoutBuilder.statistics(for: quantityType); updateHeartRate(statistics) } }
    }
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    private func updateHeartRate(_ statistics: HKStatistics?) { guard let statistics = statistics else { return }; let unit = HKUnit.count().unitDivided(by: .minute()); if let quantity = statistics.mostRecentQuantity() { let value = quantity.doubleValue(for: unit); DispatchQueue.main.async { self.heartRate = value } } }
}
// MARK: - WatchConnectivity Session Delegate
#if canImport(WatchConnectivity)
extension WorkoutManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { print("⌚️ Watch session activated: \(activationState.rawValue)"); DispatchQueue.main.async { self.isPhoneReachable = session.isReachable } }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("⌚️ Received message from iPhone: \(message)"); if let command = message["command"] as? String { switch command { case "startSleep": if let sessionIdString = message["sessionId"] as? String, let sessionId = UUID(uuidString: sessionIdString) { DispatchQueue.main.async { self.currentSessionId = sessionId; self.startWorkout() }; replyHandler(["status": "started"]) } case "stopSleep": DispatchQueue.main.async { self.stopWorkout() }; replyHandler(["status": "stopped"]) case "getCurrentMetrics": replyHandler(["heartRate": heartRate, "hrv": hrv, "timestamp": Date().timeIntervalSince1970]) case "ping": replyHandler(["status": "pong", "appRunning": true, "timestamp": Date().timeIntervalSince1970]) default: replyHandler(["status": "unknown command"]) } } else { replyHandler(["status": "no command"]) }
    }
    func sessionReachabilityDidChange(_ session: WCSession) { DispatchQueue.main.async { self.isPhoneReachable = session.isReachable } }
}
#endif
