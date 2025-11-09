//
//  HeartRateChartView.swift
//  Dream Vewawer
//
//  Real-time heart rate visualization from Apple Watch data
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    let biosignalData: [BiosignalDataPoint]
    let startTime: Date
    
    @State private var selectedDataPoint: BiosignalDataPoint?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text("Heart Rate Timeline")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if !biosignalData.isEmpty {
                    Text("\(biosignalData.count) samples")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            if biosignalData.isEmpty {
                emptyStateView
            } else {
                chartView
                legendView
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "applewatch.watchface")
                .font(.system(size: 50))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text("No Watch Data Yet")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))
            
            Text("Start sleep tracking on your Apple Watch to see real-time heart rate data")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private var chartView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Selected point info
            if let selected = selectedDataPoint {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Heart Rate")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Text("\(Int(selected.heartRate)) bpm")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Text(timeElapsed(from: selected.timestamp))
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Chart
            Chart(biosignalData) { dataPoint in
                LineMark(
                    x: .value("Time", dataPoint.timestamp),
                    y: .value("Heart Rate", dataPoint.heartRate)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.red, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                AreaMark(
                    x: .value("Time", dataPoint.timestamp),
                    y: .value("Heart Rate", dataPoint.heartRate)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.red.opacity(0.3), .pink.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                if let selected = selectedDataPoint, selected.id == dataPoint.id {
                    PointMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("Heart Rate", dataPoint.heartRate)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(150)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.2))
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(timeElapsed(from: date))
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(.white.opacity(0.2))
                    AxisValueLabel {
                        if let hr = value.as(Double.self) {
                            Text("\(Int(hr))")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }
            .chartYScale(domain: minHeartRate...maxHeartRate)
            .frame(height: 220)
        }
    }
    
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .background(.white.opacity(0.3))
            
            HStack(spacing: 20) {
                statItem(
                    title: "Average",
                    value: "\(Int(averageHeartRate)) bpm",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                statItem(
                    title: "Min",
                    value: "\(Int(minHeartRate)) bpm",
                    icon: "arrow.down.circle.fill",
                    color: .green
                )
                
                statItem(
                    title: "Max",
                    value: "\(Int(maxHeartRate)) bpm",
                    icon: "arrow.up.circle.fill",
                    color: .orange
                )
            }
        }
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
        }
    }
    
    private func timeElapsed(from date: Date) -> String {
        let elapsed = date.timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, remainingMinutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    private var averageHeartRate: Double {
        guard !biosignalData.isEmpty else { return 0 }
        let sum = biosignalData.reduce(0) { $0 + $1.heartRate }
        return sum / Double(biosignalData.count)
    }
    
    private var minHeartRate: Double {
        biosignalData.map(\.heartRate).min() ?? 40
    }
    
    private var maxHeartRate: Double {
        biosignalData.map(\.heartRate).max() ?? 120
    }
}

// MARK: - HRV Chart View

struct HRVChartView: View {
    let biosignalData: [BiosignalDataPoint]
    let startTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(.pink)
                Text("Heart Rate Variability")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            if biosignalData.isEmpty {
                Text("No HRV data available")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(biosignalData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("HRV", dataPoint.hrv)
                    )
                    .foregroundStyle(.pink)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .minute, count: 5)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(.white.opacity(0.2))
                        AxisValueLabel {
                            if let hrv = value.as(Double.self) {
                                Text("\(Int(hrv))")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                }
                .frame(height: 150)
                
                HStack {
                    Text("Avg: \(Int(averageHRV)) ms")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Range: \(Int(minHRV))-\(Int(maxHRV)) ms")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var averageHRV: Double {
        guard !biosignalData.isEmpty else { return 0 }
        return biosignalData.reduce(0) { $0 + $1.hrv } / Double(biosignalData.count)
    }
    
    private var minHRV: Double {
        biosignalData.map(\.hrv).min() ?? 0
    }
    
    private var maxHRV: Double {
        biosignalData.map(\.hrv).max() ?? 100
    }
}

#Preview {
    let sampleData = (0..<20).map { i in
        BiosignalDataPoint(
            timestamp: Date().addingTimeInterval(TimeInterval(i * 300)),
            heartRate: Double.random(in: 55...75),
            hrv: Double.random(in: 40...70)
        )
    }
    
    ZStack {
        Color.black.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 20) {
                HeartRateChartView(biosignalData: sampleData, startTime: Date())
                HRVChartView(biosignalData: sampleData, startTime: Date())
            }
            .padding()
        }
    }
}
