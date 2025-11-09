//
//  DreamVeawerWatch.swift
//  DreamVeawerWatch
//
//  Created by Gazsik Jozsef 6035 ED on 09.11.2025.
//

import AppIntents

struct DreamVeawerWatch: AppIntent {
    static var title: LocalizedStringResource { "DreamVeawerWatch" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
