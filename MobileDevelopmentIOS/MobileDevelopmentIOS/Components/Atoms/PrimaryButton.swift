//
//  PrimaryButton.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(Color.ffTextPrimary)
                        .scaleEffect(0.9)
                }

                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isEnabled ? Color.ffGold : Color.ffElevated)
            .foregroundStyle(isEnabled ? Color.ffTextPrimary : Color.ffTextMuted)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton(title: "Analyze", isEnabled: true) {}
        PrimaryButton(title: "Analyze", isEnabled: false) {}
        PrimaryButton(title: "Analyzing...", isEnabled: true, isLoading: true) {}
    }
    .padding()
    .background(Color.ffBackground)
}
