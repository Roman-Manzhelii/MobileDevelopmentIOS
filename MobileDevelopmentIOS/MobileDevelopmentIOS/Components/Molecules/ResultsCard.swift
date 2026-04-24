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
        Group {
            if let selectedImage {
                VStack(alignment: .leading, spacing: 12) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .frame(maxWidth: .infinity)

                    if isAnalyzing {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(Color.ffGold)
                            Text("Analyzing image with Aiclipse...")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ffTextPrimary)
                        }
                    } else if let analysisResult {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(detectionZone(for: analysisResult).title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(detectionZone(for: analysisResult).color)

                                    Text("Model \(analysisResult.modelVersion.uppercased())")
                                        .font(.caption2)
                                        .foregroundStyle(Color.ffTextMuted)
                                }

                                Spacer(minLength: 8)

                                Text("\(analysisPercent(for: analysisResult))%")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(Color.ffTextPrimary)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    zoneLabel(.real)
                                    Spacer()
                                    zoneLabel(.suspicious)
                                    Spacer()
                                    zoneLabel(.fake)
                                }

                                AiclipseProbabilityBar(progress: analysisResult.aiProbability)
                                    .frame(height: 26)

                                HStack {
                                    Text("AIclipse's Estimate")
                                    Spacer()
                                    Text("Probability of Fakeness")
                                }
                                .font(.caption2)
                                .foregroundStyle(Color.ffTextMuted)
                            }

                            Text(analysisSummary(for: analysisResult))
                                .font(.caption)
                                .foregroundStyle(Color.ffTextMuted)

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundStyle(Color.ffRed)
                            }
                        }
                    } else if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.ffRed)
                    } else {
                        Text("Ready to analyze the current image.")
                            .font(.caption)
                            .foregroundStyle(Color.ffTextMuted)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if let onClearTap {
                        Button(action: onClearTap) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.ffTextPrimary)
                                .frame(width: 28, height: 28)
                                .background(Color.ffBackground.opacity(0.92), in: Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                }
            } else {
                Button(action: onPlaceholderTap) {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.ffTextMuted)

                        Text("[ Upload an image to begin ]")
                            .font(.subheadline)
                            .foregroundStyle(Color.ffTextPrimary)

                        Text("Tap to choose Photo Library or Camera")
                            .font(.caption2)
                            .foregroundStyle(Color.ffTextMuted)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(Color.ffRed)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 220)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.ffBorder, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.ffCard))
        )
    }

    private func analysisPercent(for result: AiclipseCheckResponse) -> Int {
        Int((result.aiProbability * 100).rounded())
    }

    private func analysisSummary(for result: AiclipseCheckResponse) -> String {
        let confidencePercent = Int((result.confidence * 100).rounded())
        return "Verdict: \(detectionZone(for: result).title). Model confidence: \(confidencePercent)%."
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

    private func zoneLabel(_ zone: DetectionZone) -> some View {
        Text(zone.title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(zone.color)
    }
}

private struct AiclipseProbabilityBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let clampedProgress = min(max(progress, 0), 1)
            let fillWidth = totalWidth * clampedProgress

            ZStack(alignment: .leading) {
                segmentedTrack(totalWidth: totalWidth, opacity: 0.22)

                segmentedTrack(totalWidth: totalWidth, opacity: 1)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: fillWidth)
                    }

                marker(at: 0.38, totalWidth: totalWidth)
                marker(at: 0.62, totalWidth: totalWidth)

                percentBubble(totalWidth: totalWidth, progress: clampedProgress)
            }
        }
    }

    private func segmentedTrack(totalWidth: CGFloat, opacity: Double) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.ffGreen.opacity(opacity))
                .frame(width: totalWidth * 0.38)

            Rectangle()
                .fill(Color.ffGold.opacity(opacity))
                .frame(width: totalWidth * 0.24)

            Rectangle()
                .fill(Color.ffRed.opacity(opacity))
                .frame(width: totalWidth * 0.38)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.ffBorder, lineWidth: 1)
        )
    }

    private func marker(at position: CGFloat, totalWidth: CGFloat) -> some View {
        Rectangle()
            .fill(Color.ffBackground.opacity(0.75))
            .frame(width: 1, height: 26)
            .offset(x: max(totalWidth * position - 0.5, 0))
    }

    private func percentBubble(totalWidth: CGFloat, progress: Double) -> some View {
        let bubbleWidth: CGFloat = 46
        let rawOffset = totalWidth * progress - bubbleWidth / 2
        let clampedOffset = min(max(rawOffset, 0), max(totalWidth - bubbleWidth, 0))

        return Text("\(Int((progress * 100).rounded()))%")
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.ffTextPrimary)
            .frame(width: bubbleWidth, height: 22)
            .background(Color.ffCard, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.ffBorder, lineWidth: 1)
            )
            .offset(x: clampedOffset, y: 2)
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
