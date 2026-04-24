//
//  ScanRecord.swift
//  MobileDevelopmentIOS
//
//  
//

import Foundation
import SwiftData

@Model
class ScanRecord {
    var id: UUID
    var timestamp: Date
    var imageFileName: String // Renamed slightly for clarity
    var aiProbability: Double
    
    init(id: UUID = UUID(), timestamp: Date = .now, imageFileName: String, aiProbability: Double) {
        self.id = id
        self.timestamp = timestamp
        self.imageFileName = imageFileName
        self.aiProbability = aiProbability
    }
}