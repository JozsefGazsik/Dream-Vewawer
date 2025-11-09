//
//  Item.swift
//  Dream Vewawer
//
//  Created by Gazsik Jozsef 6035 ED on 09.11.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
