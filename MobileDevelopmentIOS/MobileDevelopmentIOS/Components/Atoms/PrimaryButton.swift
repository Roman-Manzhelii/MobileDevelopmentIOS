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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(isEnabled ? Color.ffGold : Color.ffElevated)
                .foregroundStyle(isEnabled ? Color.ffTextPrimary : Color.ffTextMuted)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton(title: "Analyze", isEnabled: true) {}
        PrimaryButton(title: "Analyze", isEnabled: false) {}
    }
    .padding()
    .background(Color.ffBackground)
}
