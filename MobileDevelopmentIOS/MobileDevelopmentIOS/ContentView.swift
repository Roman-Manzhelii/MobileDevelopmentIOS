import SwiftUI
import UIKit
import Shuffle

struct ContentView: View {
    @State private var lastAction = "Ще не було свайпу"

    private let cards: [DemoCard] = [
        .init(title: "Swift", subtitle: "swipe left", color: .systemBlue),
        .init(title: "UIKit", subtitle: "swipe right", color: .systemPurple),
        .init(title: "Shuffle", subtitle: "swipe down", color: .systemOrange)
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Shuffle")
                .font(.title.bold())

            Text(lastAction)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ShuffleStackView(
                cards: cards,
                onSwipe: { index, direction in
                    let dirText: String
                    switch direction {
                    case .left:
                        dirText = "left"
                    case .right:
                        dirText = "right"
                    default:
                        dirText = "other direction"
                    }

                    lastAction = "Card \(index + 1): swipe \(dirText)"
                },
                onFinished: {
                    lastAction = "All done"
                }
            )
            .frame(height: 520)
            .padding(.horizontal)
        }
        .padding()
    }
}

private struct DemoCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: UIColor
}

private struct ShuffleStackView: UIViewRepresentable {
    let cards: [DemoCard]
    let onSwipe: (Int, SwipeDirection) -> Void
    let onFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> SwipeCardStack {
        let stack = SwipeCardStack()
        stack.backgroundColor = .clear
        stack.dataSource = context.coordinator
        stack.delegate = context.coordinator
        stack.reloadData()
        return stack
    }

    func updateUIView(_ uiView: SwipeCardStack, context: Context) {
        context.coordinator.parent = self
    }

    final class Coordinator: NSObject, SwipeCardStackDataSource, SwipeCardStackDelegate {
        var parent: ShuffleStackView

        init(parent: ShuffleStackView) {
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

        private func makeCard(from model: DemoCard) -> SwipeCard {
            let card = SwipeCard()
            card.swipeDirections = [.left, .right]
            card.content = makeCardContent(from: model)

            let leftOverlay = makeOverlay(text: "NOPE", color: .systemRed, alignment: .left)
            let rightOverlay = makeOverlay(text: "LIKE", color: .systemGreen, alignment: .right)
            card.setOverlays([
                .left: leftOverlay,
                .right: rightOverlay
            ])

            return card
        }

        private func makeCardContent(from model: DemoCard) -> UIView {
            let root = UIView()
            root.backgroundColor = model.color.withAlphaComponent(0.14)
            root.layer.cornerRadius = 24
            root.layer.masksToBounds = true

            let icon = UIImageView(image: UIImage(systemName: "sparkles"))
            icon.tintColor = model.color
            icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42, weight: .medium)

            let titleLabel = UILabel()
            titleLabel.text = model.title
            titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0

            let subtitleLabel = UILabel()
            subtitleLabel.text = model.subtitle
            subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.textAlignment = .center
            subtitleLabel.numberOfLines = 0

            let stack = UIStackView(arrangedSubviews: [icon, titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 16
            stack.translatesAutoresizingMaskIntoConstraints = false

            root.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
                stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
                stack.centerYAnchor.constraint(equalTo: root.centerYAnchor)
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
            badge.layer.borderWidth = 3
            badge.layer.borderColor = color.cgColor
            badge.layer.cornerRadius = 12
            badge.backgroundColor = color.withAlphaComponent(0.12)
            badge.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = text
            label.textColor = color
            label.font = .systemFont(ofSize: 26, weight: .heavy)
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