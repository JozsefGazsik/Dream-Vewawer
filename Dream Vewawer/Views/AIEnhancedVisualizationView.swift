//
//  AIEnhancedVisualizationView.swift
//  Dream Vewawer
//
//  AI-powered dream visualization with dynamic effects
//

import SwiftUI

struct AIEnhancedVisualizationView: View {
    let sleepData: SleepData
    let interpretation: DreamInterpretation
    
    @State private var particles: [AIParticle] = []
    @State private var time: Double = 0
    @State private var showNarrative = false
    @State private var currentSymbolIndex = 0
    
    private let particleCount = 60
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on mood
            backgroundGradient
                .ignoresSafeArea()
            
            // Particle system driven by AI interpretation
            Canvas { context, size in
                for particle in particles {
                    let path = Path(ellipseIn: CGRect(
                        x: particle.x * size.width - particle.size / 2,
                        y: particle.y * size.height - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    ))
                    
                    context.fill(path, with: .color(particle.color.opacity(particle.opacity)))
                    
                    // Add glow effect for intense dreams
                    if interpretation.intensity > 0.7 {
                        context.fill(path, with: .color(particle.color.opacity(particle.opacity * 0.3)))
                    }
                }
            }
            
            // Central symbolic orb
            symbolicOrb
            
            // Floating themes
            VStack {
                Spacer()
                
                themesDisplay
                    .padding(.bottom, 40)
            }
            
            // Dream narrative overlay
            if showNarrative {
                narrativeOverlay
            }
        }
        .onAppear {
            initializeParticles()
            startAnimation()
            
            // Show narrative after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeIn(duration: 1)) {
                    showNarrative = true
                }
            }
            
            // Cycle through symbols
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                withAnimation {
                    currentSymbolIndex = (currentSymbolIndex + 1) % interpretation.symbolism.count
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        let colors = moodColors(for: interpretation.mood)
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [
                    colors[0].opacity(0.3),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
        )
    }
    
    // MARK: - Central Orb
    
    private var symbolicOrb: some View {
        let colors = moodColors(for: interpretation.mood)
        let size: CGFloat = 150 + CGFloat(interpretation.intensity * 100)
        
        return ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            colors[0].opacity(0.6),
                            colors[1].opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 1.5
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 20)
            
            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            colors[0],
                            colors[1],
                            colors[2]
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    // Symbol
                    Text(symbolEmoji(for: interpretation.symbolism[currentSymbolIndex]))
                        .font(.system(size: size * 0.4))
                        .transition(.scale.combined(with: .opacity))
                )
            
            // Consciousness ring
            if interpretation.consciousness > 0.5 {
                Circle()
                    .stroke(
                        colors[0].opacity(0.8),
                        lineWidth: 3
                    )
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(1 + sin(time * 2) * 0.1)
            }
        }
        .rotation3DEffect(
            .degrees(time * 20 * interpretation.intensity),
            axis: (x: 0.3, y: 1, z: 0)
        )
    }
    
    // MARK: - Themes Display
    
    private var themesDisplay: some View {
        HStack(spacing: 12) {
            ForEach(interpretation.themes.prefix(4), id: \.self) { theme in
                Text(theme)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Narrative Overlay
    
    private var narrativeOverlay: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                HStack {
                    Text(interpretation.mood.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Intensity indicator
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(index < Int(interpretation.intensity * 5) ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                
                Text(interpretation.narrative)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                // Consciousness level
                if interpretation.consciousness > 0.3 {
                    HStack {
                        Image(systemName: "eye")
                            .font(.caption)
                        Text("Lucidity: \(Int(interpretation.consciousness * 100))%")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal)
            .padding(.bottom, 120)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Particle System
    
    private func initializeParticles() {
        particles = (0..<particleCount).map { _ in
            AIParticle(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                size: CGFloat.random(in: 5...20) * CGFloat(interpretation.intensity),
                color: moodColors(for: interpretation.mood).randomElement()!,
                opacity: Double.random(in: 0.3...0.8),
                velocity: (
                    dx: Double.random(in: -0.002...0.002) * interpretation.intensity,
                    dy: Double.random(in: -0.002...0.002) * interpretation.intensity
                ),
                rotationSpeed: Double.random(in: -1...1)
            )
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            time += 1/60
            updateParticles()
        }
    }
    
    private func updateParticles() {
        for i in 0..<particles.count {
            // Update position based on intensity
            particles[i].x += particles[i].velocity.dx
            particles[i].y += particles[i].velocity.dy
            
            // Wrap around edges
            if particles[i].x < 0 { particles[i].x = 1 }
            if particles[i].x > 1 { particles[i].x = 0 }
            if particles[i].y < 0 { particles[i].y = 1 }
            if particles[i].y > 1 { particles[i].y = 0 }
            
            // Pulsing opacity for consciousness
            if interpretation.consciousness > 0.5 {
                particles[i].opacity = 0.5 + sin(time * 2 + Double(i)) * 0.3
            }
            
            // Chaotic movement for turbulent dreams
            if interpretation.mood == "turbulent" {
                particles[i].velocity.dx += Double.random(in: -0.0005...0.0005)
                particles[i].velocity.dy += Double.random(in: -0.0005...0.0005)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func moodColors(for mood: String) -> [Color] {
        switch mood.lowercased() {
        case "ethereal", "cosmic":
            return [
                Color(hex: "1a0033"),
                Color(hex: "2d1b69"),
                Color(hex: "6b46c1"),
                Color(hex: "9333ea")
            ]
        case "turbulent", "chaotic":
            return [
                Color(hex: "dc2626"),
                Color(hex: "ea580c"),
                Color(hex: "f59e0b"),
                Color(hex: "fbbf24")
            ]
        case "intense":
            return [
                Color(hex: "7c3aed"),
                Color(hex: "c026d3"),
                Color(hex: "db2777"),
                Color(hex: "f43f5e")
            ]
        case "peaceful", "calm":
            return [
                Color(hex: "0891b2"),
                Color(hex: "06b6d4"),
                Color(hex: "22d3ee"),
                Color(hex: "67e8f9")
            ]
        default:
            return [
                Color(hex: "059669"),
                Color(hex: "10b981"),
                Color(hex: "34d399"),
                Color(hex: "6ee7b7")
            ]
        }
    }
    
    private func symbolEmoji(for symbol: String) -> String {
        let emojiMap: [String: String] = [
            "stars": "⭐️",
            "ocean": "🌊",
            "void": "🌑",
            "unity": "☯️",
            "fire": "🔥",
            "storm": "⚡️",
            "maze": "🌀",
            "metamorphosis": "🦋",
            "faces": "👁️",
            "doorways": "🚪",
            "journeys": "🗺️",
            "mirrors": "🪞",
            "water": "💧",
            "gardens": "🌸",
            "light": "✨",
            "circles": "⭕️"
        ]
        
        return emojiMap[symbol.lowercased()] ?? "💫"
    }
}

// MARK: - AI Particle Model

struct AIParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var size: CGFloat
    var color: Color
    var opacity: Double
    var velocity: (dx: Double, dy: Double)
    var rotationSpeed: Double
}

// MARK: - Preview

#Preview {
    let sampleSleep = SleepData(
        date: Date(),
        duration: 28800,
        avgHeartRate: 58,
        heartRateVariability: 65,
        movementIntensity: 0.2,
        remPercentage: 22,
        deepSleepPercentage: 28,
        ambientNoiseLevel: 0.32
    )
    
    let sampleInterpretation = DreamInterpretation(
        narrative: "Vast cosmic expanses unfold in slow motion. Stars breathe in rhythm with your heartbeat, galaxies swirl in deep blue silence.",
        mood: "ethereal",
        themes: ["cosmos", "infinity", "serenity", "transcendence"],
        visualPrompt: "Deep blues and purples, slow-moving nebulas",
        intensity: 0.4,
        consciousness: 0.3,
        symbolism: ["stars", "void", "unity"]
    )
    
    AIEnhancedVisualizationView(sleepData: sampleSleep, interpretation: sampleInterpretation)
}
