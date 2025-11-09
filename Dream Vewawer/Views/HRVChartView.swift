//
//  HRVChartView.swift
//  Dream Vewawer
//
//  HRV (Heart Rate Variability) timeline chart
//

import SwiftUI
import Charts

struct HRVChartView: View {
    let biosignalData: [BiosignalDataPoint]
    let sessionStart: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HRV Timeline")
                .font(.headline)
                .foregroundStyle(.white)
            
            if biosignalData.isEmpty {
                emptyStateView
            } else {
                chartView
                statisticsView
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            
            Text("No HRV Data")
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            Text("Connect Apple Watch during sleep tracking to collect HRV data")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
    
    private var chartView: some View {
        Chart {
            ForEach(biosignalData, id: \.id) { dataPoint in
                let elapsed = dataPoint.timestamp.timeIntervalSince(sessionStart)
                
                LineMark(
                    x: .value("Time", elapsed / 60), // minutes
                    y: .value("HRV", dataPoint.hrv)
                )
                .foregroundStyle(.pink.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                AreaMark(
                    x: .value("Time", elapsed / 60),
                    y: .value("HRV", dataPoint.hrv)
                )
                .foregroundStyle(.pink.opacity(0.2).gradient)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.gray.opacity(0.3))
                AxisValueLabel {
                    if let minutes = value.as(Double.self) {
                        Text("\(Int(minutes))m")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.gray.opacity(0.3))
                AxisValueLabel {
                    if let hrv = value.as(Double.self) {
                        Text("\(Int(hrv))")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .frame(height: 150)
    }
    
    private var statisticsView: some View {
        HStack(spacing: 20) {
            StatisticView(
                icon: "chart.line.uptrend.xyaxis",
                label: "Avg",
                value: String(format: "%.0f ms", avgHRV)
            )
            
            StatisticView(
                icon: "arrow.down",
                label: "Min",
                value: String(format: "%.0f ms", minHRV)
            )
            
            StatisticView(
                icon: "arrow.up",
                label: "Max",
                value: String(format: "%.0f ms", maxHRV)
            )
        }
        .padding(.top, 8)
    }
    
    private var avgHRV: Double {
        guard !biosignalData.isEmpty else { return 0 }
        let sum = biosignalData.reduce(0) { $0 + $1.hrv }
        return sum / Double(biosignalData.count)
    }
    
    private var minHRV: Double {
        biosignalData.map(\.hrv).min() ?? 0
    }
    
    private var maxHRV: Double {
        biosignalData.map(\.hrv).max() ?? 0
    }
}

// Reusable statistic view component
private struct StatisticView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.pink)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
            
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData = (0..<20).map { i in
        BiosignalDataPoint(
            timestamp: Date().addingTimeInterval(TimeInterval(i * 300)),
            heartRate: Double.random(in: 60...75),
            hrv: Double.random(in: 40...70),
            movementLevel: Double.random(in: 0...0.5)
        )
    }
    
    return ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            HRVChartView(
                biosignalData: sampleData,
                sessionStart: Date().addingTimeInterval(-6000)
            )
            
            HRVChartView(
                biosignalData: [],
                sessionStart: Date()
            )
        }
        .padding()
    }
}
