//
//  Color.swift
//  
//
//  Created by Student on 13/04/2026.
//

import SwiftUI

extension Color {
    // Backgrounds
    static let ffBackground     = Color(hex: "#1C1C1E")
    static let ffCard           = Color(hex: "#2C2C2E")
    static let ffElevated       = Color(hex: "#3A3A3C")

    // Accents
    static let ffGold            = Color(hex: "#C9A84C")
    static let ffGreen           = Color(hex: "#1D9E75")
    static let ffRed             = Color(hex: "#E24B4A")
    static let ffPurple          = Color(hex: "#A855F7")

    // Text
    static let ffTextPrimary     = Color.white
    static let ffTextMuted       = Color(hex: "#666666")
    static let ffTextAnnotation  = Color(hex: "#555555")
    static let ffBorder          = Color(hex: "#3A3A3C")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

