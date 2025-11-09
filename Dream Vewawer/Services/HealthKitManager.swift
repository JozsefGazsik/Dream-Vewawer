//
//  HealthKitManager.swift
//  Dream Vewawer
//
//  Created by DreamWeaver on 09.11.2025.
//

import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    
    // Data types we want to read
    let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    ]
    
    // Request HealthKit authorization
    func requestAuthorization() {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetch heart rate data for a specific date range
    func fetchHeartRateData(startDate: Date, endDate: Date, completion: @escaping ([Double]) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }
            
            let heartRates = samples.map { sample in
                sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
            
            DispatchQueue.main.async {
                completion(heartRates)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Fetch heart rate variability data
    func fetchHRVData(startDate: Date, endDate: Date, completion: @escaping ([Double]) -> Void) {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }
            
            let hrvValues = samples.map { sample in
                sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            }
            
            DispatchQueue.main.async {
                completion(hrvValues)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Fetch sleep analysis data
    func fetchSleepData(startDate: Date, endDate: Date, completion: @escaping ([(Date, Date, HKCategoryValueSleepAnalysis)]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                completion([])
                return
            }
            
            let sleepData = samples.map { sample -> (Date, Date, HKCategoryValueSleepAnalysis) in
                let sleepType = HKCategoryValueSleepAnalysis(rawValue: sample.value) ?? .asleepUnspecified
                return (sample.startDate, sample.endDate, sleepType)
            }
            
            DispatchQueue.main.async {
                completion(sleepData)
            }
        }
        
        healthStore.execute(query)
    }
}

// Extension to calculate average from array
extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
