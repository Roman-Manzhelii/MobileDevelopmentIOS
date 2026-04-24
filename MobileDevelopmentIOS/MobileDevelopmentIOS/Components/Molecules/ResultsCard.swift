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

        var title: String {
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
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.ffBorder, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.ffCard))
            )
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
        VStack(alignment: .leading, spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            resultContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing) {
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
                .padding(4)
            }
        }
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

                Text("Tap to choose Photo Library or Camera")
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
    }

    @ViewBuilder
    private var resultContent: some View {
        if isAnalyzing {
            HStack(spacing: 10) {
                ProgressView()
                    .tint(Color.ffGold)
                Text("Checking image...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ffTextPrimary)
            }
        } else if let analysisResult {
            VStack(alignment: .leading, spacing: 6) {
                Text(detectionZone(for: analysisResult).title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(detectionZone(for: analysisResult).color)

                Text(simpleSummary(for: analysisResult))
                    .font(.subheadline)
                    .foregroundStyle(Color.ffTextMuted)
            }
        } else if let errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundStyle(Color.ffRed)
        }
    }

    private func simpleSummary(for result: AiclipseCheckResponse) -> String {
        "\(analysisPercent(for: result))% probability of fakeness"
    }

    private func analysisPercent(for result: AiclipseCheckResponse) -> Int {
        Int((result.aiProbability * 100).rounded())
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
