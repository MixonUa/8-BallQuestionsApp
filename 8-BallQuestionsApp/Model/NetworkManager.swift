
import Foundation

enum NetworkingError: Error {
    case malformedUrl
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let session = URLSession.shared
    private var currentTask: URLSessionTask?
    
    private init() {}
    
    func performTask(with question: String, completion: @escaping (Magic?, Error?) -> Void) {
        let urlString = "https://8ball.delegator.com/magic/JSON/" + question
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkingError.malformedUrl)
            return
        }
        currentTask = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            do {
                let answer = try JSONDecoder().decode(Magic.self, from: data)
                DispatchQueue.main.async { completion(answer, nil) }
            } catch(let decodingError) {
                DispatchQueue.main.async { completion(nil, decodingError) }
            }
        }
        currentTask?.resume()
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
}
