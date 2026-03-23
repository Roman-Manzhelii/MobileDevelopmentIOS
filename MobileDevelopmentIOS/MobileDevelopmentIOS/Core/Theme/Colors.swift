//
//  Colors.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

extension Color {
    static let ffBackground = Color(hex : "#1C1C1E")
}

extension Color {
    init(hex: String){
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF)/255
        let g = Double((int>>8) & 0xFF)/255
        let b = Double((int & 0xFF))/255
        self.init(red: r, green: g, blue : b)
    }
}
