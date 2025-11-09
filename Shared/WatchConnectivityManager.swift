//
//  WatchConnectivityManager.swift
//  DreamWeaver
//
//  Created by DreamWeaver on 09.11.2025.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var receivedMessage: [String: Any] = [:]
    @Published var isReachable = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendMessage(_ message: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        WCSession.default.sendMessage(message) { response in
            print("Message sent successfully: \(response)")
        } errorHandler: { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    func sendData(_ data: [String: Any]) {
        do {
            let userData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            try WCSession.default.updateApplicationContext(["sleepData": userData])
            print("Context updated successfully")
        } catch {
            print("Error updating context: \(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession,
                activationDidCompleteWith activationState: WCSessionActivationState,
                error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        
        if let error = error {
            print("WCSession activation error: \(error.localizedDescription)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated")
        WCSession.default.activate()
    }
    #endif
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.receivedMessage = message
            
            // Handle incoming messages
            if let action = message["action"] as? String {
                switch action {
                case "startTracking":
                    print("Received start tracking from Watch")
                case "stopTracking":
                    if let heartRate = message["heartRate"] as? Double,
                       let duration = message["duration"] as? TimeInterval {
                        print("Received sleep data - HR: \(heartRate), Duration: \(duration)")
                        // Create SleepData object and save
                    }
                default:
                    break
                }
            }
        }
    }
    
    func session(_ session: WCSession,
                didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.receivedMessage = applicationContext
        }
    }
}
