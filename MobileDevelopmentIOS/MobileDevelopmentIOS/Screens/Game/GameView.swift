//
//  GameView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//
import SwiftUI
import SwiftData
import UIKit
import Shuffle

struct GameView: View {
    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Environment(\.modelContext) private var context
    private let feedbackDisplayDuration: TimeInterval = 1.5

    @AppStorage("haptics_enabled") private var hapticsEnabled = true

    @State private var gameManager = GameManager()
    @State private var roundCards: [GameCardData] = []
    @State private var answeredCount = 0
    @State private var roundFinished = false
    @State private var lastResult: GuessFeedback?
    @State private var deckID = UUID()
    @State private var feedbackDismissID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            Rectangle()
                .fill(Color.ffBorder)
                .frame(height: 1)

            instructionRow

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
        .onAppear {
            if roundCards.isEmpty {
                startRound()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("Spot the Fake")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.ffTextPrimary)

            Spacer(minLength: 0)

            Text(progressLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ffGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.ffCard)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.ffBorder, lineWidth: 1)
                )
        }
        .padding(.top, 8)
    }

    private var instructionRow: some View {
        HStack(spacing: 10) {
            InstructionPill(
                title: "Fake",
                subtitle: "Swipe left",
                systemImage: "arrow.left",
                tint: .ffRed
            )

            InstructionPill(
                title: "Real",
                subtitle: "Swipe right",
                systemImage: "arrow.right",
                tint: .ffGreen
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack(alignment: .bottom) {
            if roundCards.isEmpty {
                emptyState
            } else if roundFinished {
                completedState
            } else {
                activeRoundState
            }

            if let lastResult {
                FeedbackToast(result: lastResult)
                    .id(lastResult.id)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.96, anchor: .bottom))
                        )
                    )
                    .allowsHitTesting(false)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.9), value: lastResult?.id)
    }

    private var activeRoundState: some View {
        GameSwipeStackView(
            cards: roundCards,
            deckID: deckID,
            onSwipe: handleSwipe,
            onFinished: finishRound
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var completedState: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("That was the full deck.")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.ffTextPrimary)

                Text("For this prototype round we keep it simple: four cards, instant feedback, then a reshuffle.")
                    .font(.subheadline)
                    .foregroundStyle(Color.ffTextMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.ffCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.ffBorder, lineWidth: 1)
            )

            PrimaryButton(title: "Play Again") {
                startRound()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No game cards found")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ffTextPrimary)

            Text("Check that GameContent.json and the bundled images are present in the app target.")
                .font(.subheadline)
                .foregroundStyle(Color.ffTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ffCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.ffBorder, lineWidth: 1)
        )
    }

    private var progressLabel: String {
        guard !roundCards.isEmpty else { return "0/0" }
        return "\(min(answeredCount, roundCards.count))/\(roundCards.count)"
    }

    private func getUnseenCards() -> [GameCardData] {
        let userProfile = activeUserManager.selectedProfile(using: context)
        guard let userProfile else { return gameManager.cards }
        let unseenCards = gameManager.cards.filter { !userProfile.seenGameCardIDs.contains($0.id) }
        return unseenCards.isEmpty ? gameManager.cards : unseenCards
    }

    private func startRound() {
        let sourceCards = getUnseenCards()

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            roundCards = sourceCards.shuffled()
            answeredCount = 0
            roundFinished = false
            lastResult = nil
            deckID = UUID()
            feedbackDismissID = UUID()
        }
    }

    private func handleSwipe(at index: Int, direction: SwipeDirection) {
        guard roundCards.indices.contains(index) else { return }
        guard direction == .left || direction == .right else { return }

        let card = roundCards[index]
        let guessedReal = direction == .right
        let isCorrect = guessedReal == card.isReal
        let dismissID = UUID()
        let feedback = GuessFeedback(
            card: card,
            guessedReal: guessedReal,
            isCorrect: isCorrect
        )

        if lastResult != nil {
            var transaction = Transaction()
            transaction.animation = nil
            withTransaction(transaction) {
                lastResult = nil
            }
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
            answeredCount = min(index + 1, roundCards.count)
            lastResult = feedback
            feedbackDismissID = dismissID
        }

        triggerHapticIfNeeded(isCorrect: isCorrect)
        scheduleFeedbackDismissal(for: dismissID)
    }

    private func finishRound() {
        let currentDeckID = deckID

        answeredCount = roundCards.count

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            guard currentDeckID == deckID else { return }

            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                roundFinished = true
            }
        }
    }

    private func scheduleFeedbackDismissal(for dismissID: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDisplayDuration) {
            guard feedbackDismissID == dismissID else { return }

            withAnimation(.easeOut(duration: 0.34)) {
                lastResult = nil
            }
        }
    }

    private func triggerHapticIfNeeded(isCorrect: Bool) {
        guard !isCorrect, hapticsEnabled else { return }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

private struct InstructionPill: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.ffTextPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.ffTextMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.ffCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.ffBorder, lineWidth: 1)
        )
    }
}

private struct FeedbackToast: View {
    let result: GuessFeedback

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(result.highlightColor)

            Text(result.toastText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ffTextPrimary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ffBackground.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(result.highlightColor.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 8)
    }
}

private struct GuessFeedback: Identifiable {
    let id = UUID()
    let card: GameCardData
    let guessedReal: Bool
    let isCorrect: Bool

    var guessedLabel: String {
        guessedReal ? "Real" : "Fake"
    }

    var actualLabel: String {
        card.isReal ? "Real" : "Fake"
    }

    var title: String {
        isCorrect ? "Correct guess" : "Not this one"
    }

    var toastText: String {
        isCorrect ? "Correct" : "Wrong - It was \(actualLabel)"
    }

    var summary: String {
        "You swiped \(guessedLabel). The correct answer was \(actualLabel)."
    }

    var highlightColor: Color {
        isCorrect ? .ffGreen : .ffRed
    }

    var actualColor: Color {
        card.isReal ? .ffGreen : .ffRed
    }
}

private struct GameSwipeStackView: UIViewRepresentable {
    let cards: [GameCardData]
    let deckID: UUID
    let onSwipe: (Int, SwipeDirection) -> Void
    let onFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> SwipeCardStack {
        let stack = SwipeCardStack()
        stack.backgroundColor = .clear
        stack.cardStackInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        stack.dataSource = context.coordinator
        stack.delegate = context.coordinator

        context.coordinator.lastRenderedCardIDs = cards.map(\.id)
        context.coordinator.lastDeckID = deckID

        stack.reloadData()
        return stack
    }

    func updateUIView(_ uiView: SwipeCardStack, context: Context) {
        context.coordinator.parent = self

        let cardIDs = cards.map(\.id)
        let needsReload = context.coordinator.lastDeckID != deckID || context.coordinator.lastRenderedCardIDs != cardIDs

        guard needsReload else { return }

        context.coordinator.lastDeckID = deckID
        context.coordinator.lastRenderedCardIDs = cardIDs
        uiView.reloadData()
    }

    final class Coordinator: NSObject, SwipeCardStackDataSource, SwipeCardStackDelegate {
        var parent: GameSwipeStackView
        var lastRenderedCardIDs: [String] = []
        var lastDeckID: UUID?

        init(parent: GameSwipeStackView) {
            self.parent = parent
        }

        func numberOfCards(in cardStack: SwipeCardStack) -> Int {
            parent.cards.count
        }

        func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
            makeCard(from: parent.cards[index])
        }

        func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
            parent.onSwipe(index, direction)
        }

        func didSwipeAllCards(_ cardStack: SwipeCardStack) {
            parent.onFinished()
        }

        private func makeCard(from model: GameCardData) -> SwipeCard {
            let card = SwipeCard()
            card.swipeDirections = [.left, .right]
            card.content = makeCardContent(from: model)

            card.setOverlays([
                .left: makeOverlay(text: "FAKE", color: UIColor(Color.ffRed), alignment: .left),
                .right: makeOverlay(text: "REAL", color: UIColor(Color.ffGreen), alignment: .right)
            ])

            return card
        }

        private func makeCardContent(from model: GameCardData) -> UIView {
            let root = UIView()
            root.backgroundColor = UIColor(Color.ffCard)
            root.layer.cornerRadius = 28
            root.layer.borderWidth = 1
            root.layer.borderColor = UIColor(Color.ffBorder).cgColor
            root.layer.masksToBounds = true

            let image = UIImage(named: model.imageName) ?? UIImage(systemName: "photo")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = UIColor(Color.ffTextMuted)
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false

            root.addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: root.topAnchor, constant: 14),
                imageView.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -14),
                imageView.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 14),
                imageView.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -14)
            ])

            return root
        }

        private enum OverlayAlignment {
            case left
            case right
        }

        private func makeOverlay(text: String, color: UIColor, alignment: OverlayAlignment) -> UIView {
            let overlay = UIView()
            overlay.backgroundColor = .clear

            let badge = UIView()
            badge.layer.cornerRadius = 16
            badge.layer.borderWidth = 3
            badge.layer.borderColor = color.cgColor
            badge.backgroundColor = color.withAlphaComponent(0.14)
            badge.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = text
            label.textColor = color
            label.font = .systemFont(ofSize: 28, weight: .black)
            label.translatesAutoresizingMaskIntoConstraints = false

            badge.addSubview(label)
            overlay.addSubview(badge)

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: badge.topAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -10),
                label.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -16),
                badge.topAnchor.constraint(equalTo: overlay.topAnchor, constant: 28)
            ])

            switch alignment {
            case .left:
                NSLayoutConstraint.activate([
                    badge.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 20),
                    badge.trailingAnchor.constraint(lessThanOrEqualTo: overlay.trailingAnchor, constant: -20)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    badge.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -20),
                    badge.leadingAnchor.constraint(greaterThanOrEqualTo: overlay.leadingAnchor, constant: 20)
                ])
            }

            return overlay
        }
    }
}
