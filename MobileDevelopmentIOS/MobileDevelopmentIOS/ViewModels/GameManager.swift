import Foundation

@Observable 
class GameManager {
    private let localContentDirectory = "Data/Local"

    var cards: [GameCardData] = []
    
    init() {
        loadCards()
    }
    
    func loadCards() {
        let url = Bundle.main.url(
            forResource: "GameContent",
            withExtension: "json",
            subdirectory: localContentDirectory
        ) ?? Bundle.main.url(forResource: "GameContent", withExtension: "json")

        guard let url else {
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
