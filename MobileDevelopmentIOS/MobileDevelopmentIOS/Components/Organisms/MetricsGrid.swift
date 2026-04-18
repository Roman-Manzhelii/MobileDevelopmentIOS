//
//  MetricsGrid.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct MetricItem: Identifiable {
    let id: String
    let value: String
    let label: String

    init(value: String, label: String) {
        self.id = label
        self.value = value
        self.label = label
    }
}

struct MetricsGrid: View {
    let items: [MetricItem]

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items) { item in
                StatBox(value: item.value, label: item.label)
            }
        }
    }
}

#Preview {
    MetricsGrid(items: [
        MetricItem(value: "47", label: "Images Analyzed"),
        MetricItem(value: "132", label: "Cards Swiped"),
        MetricItem(value: "5🔥", label: "Day Streak"),
        MetricItem(value: "72%", label: "Accuracy"),
        MetricItem(value: "95", label: "Correct Swipes"),
        MetricItem(value: "37", label: "Wrong Swipes")
    ])
    .padding()
    .background(Color.ffBackground)
}
