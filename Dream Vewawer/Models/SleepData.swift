//
//  SleepData.swift
//  Dream Vewawer
//
//  Created by DreamWeaver on 09.11.2025.
//

import Foundation
import SwiftData

@Model
final class SleepData {
    var id: UUID
    var date: Date
    var duration: TimeInterval // in seconds
    var avgHeartRate: Double
    var heartRateVariability: Double // HRV - emotional intensity
    var movementIntensity: Double // 0-1 scale
    var remPercentage: Double // percentage of REM sleep
    var deepSleepPercentage: Double
    var ambientNoiseLevel: Double // 0-1 scale
    
    // Dream characteristics derived from biosignals
    var dreamMood: String // "calm", "intense", "chaotic", "peaceful"
    var dreamColors: [String] // hex color codes
    var dreamTitle: String?
    var dreamNotes: String?
    
    // AI-generated dream interpretation
    var aiNarrative: String? // AI-generated dream story
    var aiThemes: [String]? // AI-identified themes
    var aiSymbolism: [String]? // Symbolic elements
    var aiIntensity: Double? // AI-calculated intensity 0-1
    var aiConsciousness: Double? // AI-calculated lucidity 0-1
    var aiVisualPrompt: String? // Description for visualization
    
    // Time-series biosignal data from Apple Watch
    @Relationship(deleteRule: .cascade, inverse: \BiosignalDataPoint.sleepSession)
    var biosignalTimeline: [BiosignalDataPoint] = []
    
    init(date: Date = Date(),
         duration: TimeInterval = 0,
         avgHeartRate: Double = 65,
         heartRateVariability: Double = 50,
         movementIntensity: Double = 0.3,
         remPercentage: Double = 20,
         deepSleepPercentage: Double = 25,
         ambientNoiseLevel: Double = 0.2) {
        
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.avgHeartRate = avgHeartRate
        self.heartRateVariability = heartRateVariability
        self.movementIntensity = movementIntensity
        self.remPercentage = remPercentage
        self.deepSleepPercentage = deepSleepPercentage
        self.ambientNoiseLevel = ambientNoiseLevel
        
        // Generate dream characteristics based on biosignals
        let calculatedMood = SleepData.calculateDreamMood(
            hrv: heartRateVariability,
            movement: movementIntensity,
            rem: remPercentage
        )
        self.dreamMood = calculatedMood
        self.dreamColors = SleepData.generateDreamColors(
            mood: calculatedMood,
            hrv: heartRateVariability,
            noise: ambientNoiseLevel
        )
    }
    
    // Algorithm to determine dream mood from biosignals
    static func calculateDreamMood(hrv: Double, movement: Double, rem: Double) -> String {
        if hrv < 40 && movement > 0.6 {
            return "chaotic"
        } else if hrv > 60 && movement < 0.3 {
            return "peaceful"
        } else if rem > 25 && movement > 0.5 {
            return "intense"
        } else {
            return "calm"
        }
    }
    
    // Generate color palette based on dream characteristics
    static func generateDreamColors(mood: String, hrv: Double, noise: Double) -> [String] {
        switch mood {
        case "peaceful":
            return ["#4A90E2", "#87CEEB", "#B0E0E6", "#E6F3FF"]
        case "chaotic":
            return ["#FF6B6B", "#FF8C42", "#FFA07A", "#FF4444"]
        case "intense":
            return ["#9B59B6", "#E74C3C", "#FF6F61", "#D946EF"]
        case "calm":
            return ["#2ECC71", "#3498DB", "#6DD5ED", "#95E1D3"]
        default:
            return ["#4A90E2", "#87CEEB", "#B0E0E6", "#E6F3FF"]
        }
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
}
