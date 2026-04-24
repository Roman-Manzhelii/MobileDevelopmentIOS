//
//  ResultsCard.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct ResultsCard: View {
    private let imageCornerRadius: CGFloat = 16
    private let clearButtonSize: CGFloat = 30
    private let clearButtonInset: CGFloat = 10

    private enum DetectionZone {
        case real
        case suspicious
        case fake

        var headline: String {
            switch self {
            case .real:
                return "Real"
            case .suspicious:
                return "Suspicious"
            case .fake:
                return "Fake"
            }
        }

        var color: Color {
            switch self {
            case .real:
                return .ffGreen
            case .suspicious:
                return .ffGold
            case .fake:
                return .ffRed
            }
        }

        var summary: String {
            switch self {
            case .real:
                return "Low fake likelihood"
            case .suspicious:
                return "Result is uncertain"
            case .fake:
                return "High fake likelihood"
            }
        }
    }

    let selectedImage: UIImage?
    let analysisResult: AiclipseCheckResponse?
    let isAnalyzing: Bool
    let errorMessage: String?
    let onPlaceholderTap: () -> Void
    let onClearTap: (() -> Void)?

    var body: some View {
        cardContent
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var cardContent: some View {
        if let selectedImage {
            selectedImageContent(selectedImage)
        } else {
            placeholderContent
        }
    }

    private func selectedImageContent(_ image: UIImage) -> some View {
        VStack(spacing: 0) {
            imageArea(image)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            resultArea
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.38, dampingFraction: 0.88), value: isAnalyzing)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: analysisResult != nil)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: errorMessage != nil)
    }

    private func imageArea(_ image: UIImage) -> some View {
        GeometryReader { geometry in
            let frame = fittedImageFrame(
                containerSize: geometry.size,
                imageSize: image.size
            )

            ZStack(alignment: .topLeading) {
                Color.clear

                if frame.width > 0, frame.height > 0 {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: frame.width, height: frame.height)
                        .clipShape(
                            RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                        )
                        .clipped()
                        .position(x: frame.midX, y: frame.midY)

                    if let onClearTap {
                        Button(action: onClearTap) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.ffTextPrimary)
                                .frame(width: clearButtonSize, height: clearButtonSize)
                                .background(Color.ffBackground.opacity(0.94), in: Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: frame.maxX - clearButtonInset - (clearButtonSize / 2),
                            y: frame.minY + clearButtonInset + (clearButtonSize / 2)
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholderContent: some View {
        Button(action: onPlaceholderTap) {
            VStack(spacing: 16) {
                Spacer(minLength: 0)

                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(Color.ffTextMuted)

                Text("Upload an image")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ffTextPrimary)

                Text("Tap to choose an image, then press Analyze")
                    .font(.subheadline)
                    .foregroundStyle(Color.ffTextMuted)
                    .multilineTextAlignment(.center)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.ffRed)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.ffBorder, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.ffCard))
        )
    }

    private var resultArea: some View {
        ZStack(alignment: .leading) {
            resultContent
        }
        .frame(maxWidth: .infinity, minHeight: 92, maxHeight: 92, alignment: .leading)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var resultContent: some View {
        if let analysisResult {
            VStack(alignment: .leading, spacing: 6) {
                let zone = detectionZone(for: analysisResult)

                Text(zone.headline)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(zone.color)

                Text(zone.summary)
                    .font(.subheadline)
                    .foregroundStyle(Color.ffTextMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else if let errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundStyle(Color.ffRed)
                .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func detectionZone(for result: AiclipseCheckResponse) -> DetectionZone {
        switch result.aiProbability {
        case ..<0.38:
            return .real
        case ..<0.62:
            return .suspicious
        default:
            return .fake
        }
    }

    private func fittedImageFrame(containerSize: CGSize, imageSize: CGSize) -> CGRect {
        guard containerSize.width > 0,
              containerSize.height > 0,
              imageSize.width > 0,
              imageSize.height > 0 else {
            return .zero
        }

        let scale = min(
            containerSize.width / imageSize.width,
            containerSize.height / imageSize.height
        )

        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let originX = (containerSize.width - width) / 2
        let originY = (containerSize.height - height) / 2

        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}

#Preview {
    ResultsCard(
        selectedImage: nil,
        analysisResult: nil,
        isAnalyzing: false,
        errorMessage: nil,
        onPlaceholderTap: {},
        onClearTap: nil
    )
    .padding()
    .background(Color.ffBackground)
}
