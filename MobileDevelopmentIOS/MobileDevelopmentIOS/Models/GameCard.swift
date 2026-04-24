import Foundation

struct GameCard: Codable, Identifiable {
    let id: String
    let imageName: String
    let isReal: Bool
    let explanation: String
}