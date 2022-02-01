
import Foundation

final class DataManager {
    static let instance = DataManager()
    
    private init(){ }
    
    private(set) var standardAnswer = "Standard answer"
    
    func changeStandardAnswer(_ printedAnswer: String) {
        standardAnswer = printedAnswer
    }
}
