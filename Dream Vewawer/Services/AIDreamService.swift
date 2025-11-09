//
//  AIDreamService.swift
//  Dream Vewawer
//
//  AI-powered dream interpretation and visualization generation
//

import Foundation
import Combine

struct DreamInterpretation: Codable {
    let narrative: String           // AI-generated dream story
    let mood: String               // AI-determined emotional tone
    let themes: [String]           // Identified dream themes
    let visualPrompt: String       // Description for visualization
    let intensity: Double          // Dream intensity 0-1
    let consciousness: Double      // Level of awareness 0-1
    let symbolism: [String]        // Symbolic elements
}

enum AIProvider {
    case openAI
    case anthropic
    case local
}

class AIDreamService: ObservableObject {
    @Published var isProcessing = false
    @Published var lastInterpretation: DreamInterpretation?
    @Published var error: String?
    
    private let provider: AIProvider
    private let apiKey: String?
    
    init(provider: AIProvider = .openAI, apiKey: String? = nil) {
        self.provider = provider
        self.apiKey = apiKey ?? AIConfig.apiKey
    }
    
    // Generate dream interpretation from sleep biosignals
    func interpretDream(from sleepData: SleepData) async -> DreamInterpretation? {
        await MainActor.run { isProcessing = true }
        defer { Task { await MainActor.run { isProcessing = false } } }
        
        let prompt = buildPrompt(from: sleepData)
        
        do {
            let interpretation: DreamInterpretation
            
            switch provider {
            case .openAI:
                interpretation = try await callOpenAI(prompt: prompt)
            case .anthropic:
                interpretation = try await callAnthropic(prompt: prompt)
            case .local:
                interpretation = generateLocalInterpretation(from: sleepData)
            }
            
            await MainActor.run {
                self.lastInterpretation = interpretation
                self.error = nil
            }
            
            return interpretation
            
        } catch {
            await MainActor.run {
                self.error = "AI interpretation failed: \(error.localizedDescription)"
            }
            // Fallback to local interpretation
            return generateLocalInterpretation(from: sleepData)
        }
    }
    
    // Build AI prompt from biosignal data
    private func buildPrompt(from sleepData: SleepData) -> String {
        """
        Analyze this sleep session and generate a poetic dream interpretation:
        
        Sleep Duration: \(Int(sleepData.duration / 60)) minutes
        Heart Rate: \(sleepData.avgHeartRate) bpm (variability: \(sleepData.heartRateVariability))
        Movement: \(String(format: "%.1f%%", sleepData.movementIntensity * 100))
        REM Sleep: \(String(format: "%.1f%%", sleepData.remPercentage))
        Deep Sleep: \(String(format: "%.1f%%", sleepData.deepSleepPercentage))
        Ambient Noise: \(sleepData.ambientNoiseLevel) dB
        Current Mood: \(sleepData.dreamMood)
        
        Generate a JSON response with:
        - narrative: A 2-3 sentence poetic dream story reflecting the biosignals
        - mood: emotional tone (peaceful/chaotic/intense/calm/ethereal/turbulent)
        - themes: array of 3-5 dream themes
        - visualPrompt: vivid description for visualization (colors, shapes, movement)
        - intensity: 0-1 scale of dream intensity
        - consciousness: 0-1 scale of lucidity/awareness
        - symbolism: array of 2-4 symbolic elements present
        
        Base interpretation on:
        - High HRV + low movement = peaceful, flowing dreams
        - Low HRV + high movement = restless, chaotic dreams
        - High REM% = vivid, emotional, story-rich dreams
        - High deep sleep% = abstract, cosmic, profound dreams
        - High noise = fragmented, interrupted dream flow
        """
    }
    
    // Call OpenAI API
    private func callOpenAI(prompt: String) async throws -> DreamInterpretation {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a dream interpreter that analyzes sleep biosignals and generates poetic, scientifically-informed dream narratives. Always respond with valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.9
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("Invalid response")
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = openAIResponse.choices.first?.message.content else {
            throw AIError.invalidResponse
        }
        
        let interpretation = try JSONDecoder().decode(DreamInterpretation.self, from: content.data(using: .utf8)!)
        return interpretation
    }
    
    // Call Anthropic Claude API
    private func callAnthropic(prompt: String) async throws -> DreamInterpretation {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": prompt + "\n\nRespond with only valid JSON, no other text."]
            ],
            "temperature": 0.9
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("Invalid response")
        }
        
        let anthropicResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let content = anthropicResponse.content.first?.text else {
            throw AIError.invalidResponse
        }
        
        let interpretation = try JSONDecoder().decode(DreamInterpretation.self, from: content.data(using: .utf8)!)
        return interpretation
    }
    
    // Local fallback interpretation (no API needed)
    private func generateLocalInterpretation(from sleepData: SleepData) -> DreamInterpretation {
        let hrv = sleepData.heartRateVariability
        let movement = sleepData.movementIntensity
        let rem = sleepData.remPercentage
        let deep = sleepData.deepSleepPercentage
        
        // Determine mood and intensity
        let intensity: Double
        let consciousness: Double
        let mood: String
        let narrative: String
        let visualPrompt: String
        let themes: [String]
        let symbolism: [String]
        
        if hrv > 60 && movement < 0.3 && deep > 25 {
            // Deep, peaceful, cosmic dreams
            mood = "ethereal"
            intensity = 0.3
            consciousness = 0.2
            narrative = "Vast cosmic expanses unfold in slow motion. Stars breathe in rhythm with your heartbeat, galaxies swirl in deep blue silence. You float through infinite space, weightless and serene."
            visualPrompt = "Deep blues and purples, slow-moving nebulas, floating particles, gentle rotation, cosmic dust trails, soft glowing orbs"
            themes = ["cosmos", "infinity", "serenity", "transcendence"]
            symbolism = ["stars", "ocean depths", "void", "unity"]
            
        } else if hrv < 40 && movement > 0.6 {
            // Chaotic, restless dreams
            mood = "turbulent"
            intensity = 0.9
            consciousness = 0.7
            narrative = "Rapid scenes flash and morph. Colors clash and swirl violently. You run through shifting landscapes where walls become water and floors dissolve beneath urgent footsteps."
            visualPrompt = "Sharp reds and oranges, rapid particle bursts, jagged movements, explosive patterns, flickering lights, chaotic trajectories"
            themes = ["urgency", "transformation", "chaos", "pursuit"]
            symbolism = ["fire", "storm", "maze", "metamorphosis"]
            
        } else if rem > 25 && movement > 0.4 {
            // Vivid, story-driven dreams
            mood = "intense"
            intensity = 0.8
            consciousness = 0.6
            narrative = "Vivid stories unfold with cinematic clarity. Familiar faces appear in impossible places. Emotions surge as dream logic weaves intricate narratives through surreal landscapes."
            visualPrompt = "Rich purples and magentas, flowing ribbons of light, dynamic shapes, pulsing orbs, layered depth, emotional color shifts"
            themes = ["narrative", "emotion", "memory", "connection"]
            symbolism = ["faces", "doorways", "journeys", "mirrors"]
            
        } else {
            // Calm, gentle dreams
            mood = "peaceful"
            intensity = 0.5
            consciousness = 0.4
            narrative = "Gentle waves of sensation wash over peaceful scenery. Soft lights dance in harmonious patterns. Time flows like honey, each moment blending seamlessly into the next."
            visualPrompt = "Soft greens and teals, gentle waves, smooth circular motions, gradient transitions, glowing trails, harmonious flow"
            themes = ["harmony", "flow", "nature", "balance"]
            symbolism = ["water", "gardens", "light", "circles"]
        }
        
        return DreamInterpretation(
            narrative: narrative,
            mood: mood,
            themes: themes,
            visualPrompt: visualPrompt,
            intensity: intensity,
            consciousness: consciousness,
            symbolism: symbolism
        )
    }
}

// MARK: - API Response Models

private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

private struct AnthropicResponse: Codable {
    let content: [Content]
    
    struct Content: Codable {
        let text: String
    }
}

// MARK: - Errors

enum AIError: LocalizedError {
    case missingAPIKey
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key not configured. Using local dream interpretation."
        case .apiError(let message):
            return "AI service error: \(message)"
        case .invalidResponse:
            return "Invalid response from AI service"
        }
    }
}

// MARK: - Configuration

struct AIConfig {
    // Add your API key here or set via environment
    // For OpenAI: Get key from https://platform.openai.com/api-keys
    // For Anthropic: Get key from https://console.anthropic.com/
    static let apiKey: String? = ProcessInfo.processInfo.environment["AI_API_KEY"]
    
    // Choose your provider
    static let defaultProvider: AIProvider = .local // Change to .openAI or .anthropic when you add a key
}
