//
//  DreamVisualizationView.swift
//  Dream Vewawer
//
//  Created by DreamWeaver on 09.11.2025.
//

import SwiftUI

struct DreamVisualizationView: View {
    let sleepData: SleepData
    @State private var animationProgress: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            // Background gradient based on dream mood
            backgroundGradient
            
            // Animated dream particles
            ForEach(0..<particleCount, id: \.self) { index in
                DreamParticle(
                    color: Color(hex: sleepData.dreamColors[index % sleepData.dreamColors.count]),
                    progress: animationProgress,
                    index: index,
                    movement: sleepData.movementIntensity,
                    hrv: sleepData.heartRateVariability
                )
            }
            
            // Central dream orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: sleepData.dreamColors.map { Color(hex: $0) },
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 150 * scale, height: 150 * scale)
                .blur(radius: 10)
                .rotationEffect(.degrees(rotation))
            
            // Dream mood label
            VStack {
                Spacer()
                Text(sleepData.dreamMood.uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animationProgress = 1.0
                scale = 1.5
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
    
    private var particleCount: Int {
        Int(sleepData.movementIntensity * 20) + 5
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: sleepData.dreamColors[0]).opacity(0.3),
                Color(hex: sleepData.dreamColors[1]).opacity(0.5),
                .black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct DreamParticle: View {
    let color: Color
    let progress: CGFloat
    let index: Int
    let movement: Double
    let hrv: Double
    
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: particleSize, height: particleSize)
            .blur(radius: 3)
            .opacity(opacity)
            .position(position)
            .onAppear {
                setupAnimation()
            }
    }
    
    private var particleSize: CGFloat {
        CGFloat(10 + movement * 20)
    }
    
    private func setupAnimation() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let angle = Double(index) * (360.0 / 20.0)
        let radius = 50.0 + (hrv * 2)
        
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        withAnimation(
            .easeInOut(duration: 2 + Double(index) * 0.1)
            .repeatForever(autoreverses: true)
        ) {
            position = CGPoint(
                x: centerX + CGFloat(cos(angle * .pi / 180) * radius),
                y: centerY + CGFloat(sin(angle * .pi / 180) * radius)
            )
            opacity = 0.6 + movement * 0.4
        }
    }
}

// Extension to convert hex color strings to SwiftUI Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    DreamVisualizationView(sleepData: SleepData(
        avgHeartRate: 68,
        heartRateVariability: 55,
        movementIntensity: 0.4,
        remPercentage: 22
    ))
}
