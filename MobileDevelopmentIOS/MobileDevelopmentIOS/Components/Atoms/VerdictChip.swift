import SwiftUI

struct VerdictChip: View {
    let verdict: String

    private var isReal: Bool {
        verdict.lowercased() == "real"
    }

    var body: some View {
        Text(verdict)
            .font(.headline.weight(.bold))
            .foregroundStyle(isReal ? Color.ffGreen : Color.ffRed)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
