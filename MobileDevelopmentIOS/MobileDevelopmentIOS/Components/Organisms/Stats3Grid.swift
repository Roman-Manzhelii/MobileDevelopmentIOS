//
//  Stats3Grid.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct Stats3Grid: View {
    let items: [StatItem]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                StatBox(value: item.value, label: item.label)
            }
        }
    }
}

struct StatItem: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

#Preview {
    Stats3Grid(items: [
        StatItem(value: "12", label: "Scans this week"),
        StatItem(value: "74%", label: "Game accuracy"),
        StatItem(value: "3🔥", label: "Day streak")
    ])
    .padding()
}
