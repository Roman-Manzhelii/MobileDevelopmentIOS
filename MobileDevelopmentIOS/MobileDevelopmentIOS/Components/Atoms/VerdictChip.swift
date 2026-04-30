import SwiftUI

struct VerdictChip: View {
    let verdict: String

    private var isReal: Bool {
        verdict.lowercased() == "real"
    }

    var body: some View {
        Text(verdict)
            .font(.caption2.weight(.bold))
            .foregroundStyle(isReal ? Color.ffGreen : Color.ffRed)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                (isReal ? Color.ffGreen : Color.ffRed).opacity(0.15),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(isReal ? Color.ffGreen : Color.ffRed, lineWidth: 1)
            )
    }
}

#Preview {
    HStack(spacing: 10) {
        VerdictChip(verdict: "Real")
        VerdictChip(verdict: "Fake")
    }
    .padding()
    .background(Color.ffBackground)
}
