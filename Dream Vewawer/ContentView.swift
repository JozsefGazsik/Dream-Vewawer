//
//  ContentView.swift
//  Dream Vewawer
//
//  Created by Gazsik Jozsef 6035 ED on 09.11.2025.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepData.date, order: .reverse) private var sleepSessions: [SleepData]

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        headerView
                        
                        // Main Action Card
                        startDreamModeCard
                        
                        // Last Dream Preview
                        if let lastDream = sleepSessions.first {
                            lastDreamCard(lastDream)
                        }
                        
                        // Recent Dreams List
                        if sleepSessions.count > 1 {
                            recentDreamsSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("DreamWeaver")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [.indigo.opacity(0.2), .purple.opacity(0.3), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .yellow.opacity(0.3), radius: 10)
            
            Text("See What Your Mind Creates")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    private var startDreamModeCard: some View {
        NavigationLink(destination: SleepTrackingView()) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Start Dream Mode", systemImage: "bed.double.fill")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    
                    Text("Track your sleep and visualize your dreams")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 30))
            }
            .foregroundStyle(.white)
            .padding(25)
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    private func lastDreamCard(_ dream: SleepData) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Last Dream")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text(dream.date, style: .relative)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            NavigationLink(destination: DreamDetailView(sleepData: dream)) {
                ZStack {
                    // Mini visualization preview
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: dream.dreamColors.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                    
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(dream.dreamMood.capitalized)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                
                                HStack(spacing: 15) {
                                    Label(dream.durationFormatted, systemImage: "clock.fill")
                                    Label("\(Int(dream.remPercentage))% REM", systemImage: "brain.head.profile")
                                }
                                .font(.system(size: 14))
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var recentDreamsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Dream History")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal)
            
            ForEach(sleepSessions.dropFirst()) { dream in
                NavigationLink(destination: DreamDetailView(sleepData: dream)) {
                    dreamHistoryRow(dream)
                }
            }
        }
    }
    
    private func dreamHistoryRow(_ dream: SleepData) -> some View {
        HStack(spacing: 15) {
            // Color indicator
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: dream.dreamColors.map { Color(hex: $0) },
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(dream.dreamMood.capitalized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                HStack(spacing: 10) {
                    Label(dream.durationFormatted, systemImage: "clock")
                    Text("•")
                    Text(dream.date.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SleepData.self, inMemory: true)
}
