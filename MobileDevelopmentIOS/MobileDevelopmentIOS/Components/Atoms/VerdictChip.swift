import SwiftUI

struct VerdictChip: View {
    let verdict: String

    private enum VerdictStyle {
        case real
        case suspicious
        case fake

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

    private var normalizedVerdict: String {
        verdict.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var displayText: String {
        switch normalizedVerdict {
        case "real":
            return "Real"
        case "suspicious":
            return "Suspicious"
        case "fake", "ai":
            return "Fake"
        default:
            return verdict
        }
    }

    private var style: VerdictStyle {
        switch normalizedVerdict {
        case "real":
            return .real
        case "suspicious":
            return .suspicious
        default:
            return .fake
        }
    }

    var body: some View {
        Text(displayText)
            .font(.headline.weight(.bold))
            .foregroundStyle(style.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                style.color.opacity(0.15),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(style.color, lineWidth: 1)
            )
    }
}

#Preview {
    HStack(spacing: 10) {
        VerdictChip(verdict: "Real")
        VerdictChip(verdict: "Suspicious")
        VerdictChip(verdict: "Fake")
    }
    .padding()
    .background(Color.ffBackground)
}
