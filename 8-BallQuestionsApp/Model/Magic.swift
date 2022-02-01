
import Foundation

struct Magic: Decodable {
    let magic: Information
}

struct Information: Decodable {
    let question: String
    let answer: String
    let type: String
}
