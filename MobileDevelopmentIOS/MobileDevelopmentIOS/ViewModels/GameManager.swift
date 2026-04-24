import Foundation

@Observable 
class GameManager {
    var cards: [GameCardData] = []
    
    init() {
        loadCards()
    }
    
    func loadCards() {
        guard let url = Bundle.main.url(forResource: "GameContent", withExtension: "json") else {
            print("Could not find GameContent.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.cards = try decoder.decode([GameCardData].self, from: data)
        } catch {
            print("Failed to decode JSON \(error)")
        }
    }
}