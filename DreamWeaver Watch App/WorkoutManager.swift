//
//  WorkoutManager.swift
//  DreamWeaver Watch App
//
//  Created by DreamWeaver on 09.11.2025.
//

import Foundation
import HealthKit
import Combine

class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var isTracking = false
    @Published var heartRate: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var startDate: Date?
    var timer: Timer?
    
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
            
            // TODO: Send message to iPhone app via WatchConnectivity
            // WatchConnectivityManager.shared.sendMessage([...])
            
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
        }
    }
    
    // Stop workout session
    func stopWorkout() {
        session?.end()
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async {
            self.isTracking = false
        }
        
        // TODO: Send data to iPhone
        // WatchConnectivityManager.shared.sendMessage([...])
    }
    
    // Update heart rate
    func updateHeartRate(_ samples: [HKQuantitySample]) {
        guard let sample = samples.first else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = sample.quantity.doubleValue(for: heartRateUnit)
        
        DispatchQueue.main.async {
            self.heartRate = value
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
