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