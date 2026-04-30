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
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ffElevated)

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(Color.ffTextMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 10) {
                Text(timestamp)
                    .font(.caption)
                    .foregroundStyle(Color.ffTextMuted)
                    .lineLimit(1)

                Spacer(minLength: 8)

                VerdictChip(verdict: verdict)
            }
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
    }
    .padding()
    .background(Color.ffBackground)
}
