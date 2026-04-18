//
//  OutlineButton.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct OutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ffTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.ffCard))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OutlineButton(title: "Clear All") {}
        .padding()
        .background(Color.ffBackground)
}
