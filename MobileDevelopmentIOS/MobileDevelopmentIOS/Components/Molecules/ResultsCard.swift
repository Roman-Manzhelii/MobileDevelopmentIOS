//
//  ResultsCard.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct ResultsCard: View {
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
            ZStack(alignment: .topTrailing) {
                imageArea(image)

                if let onClearTap {
                    Button(action: onClearTap) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.ffTextPrimary)
                            .frame(width: 30, height: 30)
                            .background(Color.ffBackground.opacity(0.94), in: Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.ffBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .padding(.trailing, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Rectangle()
                .fill(Color.ffBorder.opacity(0.7))
                .frame(height: 1)

            resultArea
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.38, dampingFraction: 0.88), value: isAnalyzing)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: analysisResult != nil)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: errorMessage != nil)
    }

    private func imageArea(_ image: UIImage) -> some View {
        ZStack {
            Color.clear

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
