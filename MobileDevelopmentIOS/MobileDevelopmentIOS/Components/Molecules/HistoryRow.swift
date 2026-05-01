//
//  HistoryRow.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct HistoryRow: View {
    let timestamp: String
    let verdict: String
    var imageData: Data? = nil

    var body: some View {
        HStack() {
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.ffCard)

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(Color.ffTextMuted)
                }
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer(minLength: 10)
            
            VStack(spacing: 10) {
                VerdictChip(verdict: verdict)
                
                Text(timestamp)
                    .font(.caption)
                    .foregroundStyle(Color.ffTextMuted)
                    .lineLimit(1)
            }
            .frame(width: 150)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ffCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                )
        )
    }

}

#Preview {
    VStack(spacing: 10) {
        HistoryRow(timestamp: "Today, 2:14 PM", verdict: "Fake")
        HistoryRow(timestamp: "Mar 20, 2026 · 2:14 PM", verdict: "Real")
        HistoryRow(timestamp: "Today, 2:14 PM", verdict: "Suspisious")
    }
    .padding()
    .background(Color.ffBackground)
}
