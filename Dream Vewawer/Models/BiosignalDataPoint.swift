//
//  BiosignalDataPoint.swift
//  Dream Vewawer
//
//  Time-series biosignal data collected during sleep
//

import Foundation
import SwiftData

@Model
final class BiosignalDataPoint {
    var id: UUID
    var timestamp: Date
    var heartRate: Double
    var hrv: Double
    var movement: Double
    
    // Relationship
    var sleepSession: SleepData?
    
    init(timestamp: Date = Date(),
         heartRate: Double = 0,
         hrv: Double = 0,
         movement: Double = 0) {
        self.id = UUID()
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.hrv = hrv
        self.movement = movement
    }
}
