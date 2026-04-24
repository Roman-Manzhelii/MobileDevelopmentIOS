//
//  ResultsCard.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct ResultsCard: View {
    let selectedImage: UIImage?
    let sourceFileName: String?
    let analysisResult: AiclipseCheckResponse?
    let isAnalyzing: Bool
    let errorMessage: String?

    var body: some View {
        Group {
            if let selectedImage {
                VStack(alignment: .leading, spacing: 12) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .frame(maxWidth: .infinity)

                    if let sourceFileName {
                        Text("Source: \(sourceFileName)")
                            .font(.caption2)
                            .foregroundStyle(Color.ffTextMuted)
                    }

                    if isAnalyzing {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(Color.ffGold)
                            Text("Analyzing image with Aiclipse...")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ffTextPrimary)
                        }
                    } else if let analysisResult {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                resultChip("\(analysisPercent(for: analysisResult))% AI")
                                resultChip(analysisResult.displayLabel)
                                resultChip(analysisResult.modelVersion.uppercased())
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
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.ffTextMuted)

                    Text("[ Upload an image to begin ]")
                        .font(.subheadline)
                        .foregroundStyle(Color.ffTextPrimary)

                    Text("- No image selected yet")
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
        return "Verdict: \(result.verdict). Confidence in verdict: \(confidencePercent)%."
    }

    private func resultChip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.ffTextPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.ffElevated, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.ffBorder, lineWidth: 1))
    }
}

#Preview {
    ResultsCard(
        selectedImage: nil,
        sourceFileName: nil,
        analysisResult: nil,
        isAnalyzing: false,
        errorMessage: nil
    )
    .padding()
    .background(Color.ffBackground)
}
