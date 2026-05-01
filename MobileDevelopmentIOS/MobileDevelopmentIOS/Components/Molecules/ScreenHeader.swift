//
//  ScreenHeader.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 01/05/2026.
//

import SwiftUI

struct ScreenHeader<Trailing: View>: View {
    let title: String
    let subtitle: String
    let trailing: Trailing

    init(
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ffTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.ffTextMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 12)

            trailing
        }
        .padding(.top, 8)
        .frame(height: 64, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, subtitle: String) {
        self.init(title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        ScreenHeader(
            title: "Welcome back",
            subtitle: "Quick actions and recent scan activity"
        )

        ScreenHeader(title: "Spot the Fake", subtitle: "Swipe through images and test your eye") {
            Text("0/5")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ffGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.ffCard))
                .overlay(Capsule().stroke(Color.ffBorder, lineWidth: 1))
        }
    }
    .padding()
    .background(Color.ffBackground)
}
