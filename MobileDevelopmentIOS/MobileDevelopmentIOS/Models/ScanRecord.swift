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
    var userProfileID: UUID?
    var imageFileName: String 
    var imageData: Data?
    var aiProbability: Double
    var verdictLabel: String

    var displayVerdictLabel: String {
        let normalizedLabel = verdictLabel.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch normalizedLabel {
        case "real":
            return "Real"
        case "suspicious":
            return "Suspicious"
        case "fake", "ai":
            return "Fake"
        default:
            return verdictLabel
        }
    }

    
    init(id: UUID = UUID(), timestamp: Date = .now, userProfileID: UUID? = nil, imageFileName: String, imageData: Data? = nil, aiProbability: Double, verdictLabel: String) {
        self.id = id
        self.timestamp = timestamp
        self.userProfileID = userProfileID
        self.imageFileName = imageFileName
        self.imageData = imageData
        self.aiProbability = aiProbability
        self.verdictLabel = verdictLabel        
    }
}
