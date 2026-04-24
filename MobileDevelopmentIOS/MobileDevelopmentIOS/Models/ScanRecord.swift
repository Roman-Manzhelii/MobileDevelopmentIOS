//
//  ScanRecord.swift
//  MobileDevelopmentIOS
//
//  Canonical detector history model.
//

import Foundation

struct ScanRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let imagePath: String
    let aiProbability: Double
}
