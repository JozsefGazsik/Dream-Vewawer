//
//  DreamDetailView.swift
//  Dream Vewawer
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI
import SwiftData

struct DreamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let sleepData: SleepData
    
    @State private var showingVisualization = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Dream Visualization Preview
                    visualizationCard
                    
                    // Dream Info Card
                    dreamInfoCard
                    
                    // Biosignals Card
                    biosignalsCard
                    
                    // Notes Section
                    notesSection
                }
                .padding()
            }
        }
        .navigationTitle("Dream Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingVisualization) {
            // Use AI-enhanced visualization if available, otherwise use standard
            if let narrative = sleepData.aiNarrative,
               let themes = sleepData.aiThemes,
               let symbolism = sleepData.aiSymbolism,
               let intensity = sleepData.aiIntensity,
               let consciousness = sleepData.aiConsciousness,
               let visualPrompt = sleepData.aiVisualPrompt {
                
                let interpretation = DreamInterpretation(
                    narrative: narrative,
                    mood: sleepData.dreamMood,
                    themes: themes,
                    visualPrompt: visualPrompt,
                    intensity: intensity,
                    consciousness: consciousness,
                    symbolism: symbolism
                )
                
                AIEnhancedVisualizationView(sleepData: sleepData, interpretation: interpretation)
            } else {
                DreamVisualizationView(sleepData: sleepData)
            }
        }
    }
    
    private var visualizationCard: some View {
        VStack(spacing: 15) {
            ZStack {
                // Preview of visualization
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: sleepData.dreamColors.map { Color(hex: $0) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 250)
                
                Button(action: { showingVisualization = true }) {
                    VStack(spacing: 10) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                        Text("Play Dream Visualization")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            
            Text(sleepData.dreamMood.capitalized + " Dream")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    private var dreamInfoCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sleep Summary")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(spacing: 30) {
                infoItem(icon: "clock.fill", title: "Duration", value: sleepData.durationFormatted, color: .blue)
                infoItem(icon: "calendar", title: "Date", value: sleepData.date.formatted(date: .abbreviated, time: .omitted), color: .green)
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            HStack(spacing: 30) {
                infoItem(icon: "brain.head.profile", title: "REM Sleep", value: String(format: "%.0f%%", sleepData.remPercentage), color: .purple)
                infoItem(icon: "bed.double.fill", title: "Deep Sleep", value: String(format: "%.0f%%", sleepData.deepSleepPercentage), color: .indigo)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var biosignalsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Biosignals")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 15) {
                biosignalRow(
                    icon: "heart.fill",
                    title: "Avg Heart Rate",
                    value: String(format: "%.0f bpm", sleepData.avgHeartRate),
                    color: .red
                )
                
                biosignalRow(
                    icon: "waveform.path.ecg",
                    title: "Heart Rate Variability",
                    value: String(format: "%.0f ms", sleepData.heartRateVariability),
                    color: .pink
                )
                
                biosignalRow(
                    icon: "figure.walk",
                    title: "Movement Intensity",
                    value: String(format: "%.0f%%", sleepData.movementIntensity * 100),
                    color: .green
                )
                
                biosignalRow(
                    icon: "speaker.wave.2.fill",
                    title: "Ambient Noise",
                    value: String(format: "%.0f%%", sleepData.ambientNoiseLevel * 100),
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // AI Interpretation Section (if available)
            if let narrative = sleepData.aiNarrative {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                        Text("AI Dream Interpretation")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Text(narrative)
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    // Themes
                    if let themes = sleepData.aiThemes, !themes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(themes, id: \.self) { theme in
                                    Text(theme)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.3))
                                        .clipShape(Capsule())
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    
                    // Intensity & Consciousness metrics
                    if let intensity = sleepData.aiIntensity, let consciousness = sleepData.aiConsciousness {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Intensity")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                ProgressView(value: intensity)
                                    .tint(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Lucidity")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                ProgressView(value: consciousness)
                                    .tint(.purple)
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            Text("Dream Notes")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            if let notes = sleepData.dreamNotes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Text("No notes added yet")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.5))
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
    
    private func infoItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func biosignalRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

#Preview {
    NavigationStack {
        DreamDetailView(sleepData: SleepData(
            date: Date(),
            duration: 28800,
            avgHeartRate: 68,
            heartRateVariability: 55,
            movementIntensity: 0.4,
            remPercentage: 22,
            deepSleepPercentage: 28,
            ambientNoiseLevel: 0.25
        ))
        .modelContainer(for: SleepData.self, inMemory: true)
    }
}
