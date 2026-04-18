//
//  AccuracyRing.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct AccuracyRing: View {
    var progress: Double
    var subtitle: String = "Lifetime Accuracy Ring"
    var footnote: String? = "Progress ring — lifetime swipe accuracy"

    private var clamped: Double {
        min(1, max(0, progress))
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.ffBorder.opacity(0.45), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: clamped)
                    .stroke(
                        Color.ffGold,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int((clamped * 100).rounded()))%")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ffTextPrimary)
            }
            .frame(width: 120, height: 120)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.ffTextMuted)

            if let footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(Color.ffTextMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AccuracyRing(progress: 0.72)
        .padding()
        .background(Color.ffBackground)
}
