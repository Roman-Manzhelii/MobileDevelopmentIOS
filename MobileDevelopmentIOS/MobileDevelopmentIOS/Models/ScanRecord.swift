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
    var imageFileName: String 
    var imageData: Data?
    var aiProbability: Double
    var verdictLabel: String

    
    init(id: UUID = UUID(), timestamp: Date = .now, imageFileName: String, imageData: Data? = nil, aiProbability: Double, verdictLabel: String) {
        self.id = id
        self.timestamp = timestamp
        self.imageFileName = imageFileName
        self.imageData = imageData
        self.aiProbability = aiProbability
        self.verdictLabel = verdictLabel        
    }
}