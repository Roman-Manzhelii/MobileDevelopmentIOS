//
//  QuickActionCard.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct QuickActionCard: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.ffTextPrimary)
                    .frame(width: 54, height: 54)
                    .background(Color.ffElevated, in: RoundedRectangle(cornerRadius: 14))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ffTextPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ffCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.ffBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 12) {
        QuickActionCard(systemImage: "camera.viewfinder", title: "Detector") {}
        QuickActionCard(systemImage: "gamecontroller.fill", title: "Play Game") {}
    }
    .padding()
    .background(Color.ffBackground)
}
