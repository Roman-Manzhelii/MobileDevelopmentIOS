//
//  ResultsCard.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct ResultsCard: View {
    let selectedImage: UIImage?

    var body: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.ffTextMuted)

                    Text("[ Upload an image to begin ]")
                        .font(.subheadline)
                        .foregroundStyle(Color.ffTextPrimary)

                    Text("● No image selected yet")
                        .font(.caption2)
                        .foregroundStyle(Color.ffTextMuted)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 220)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.ffBorder, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.ffCard))
        )
    }
}

#Preview {
    ResultsCard(selectedImage: nil)
        .padding()
        .background(Color.ffBackground)
}
