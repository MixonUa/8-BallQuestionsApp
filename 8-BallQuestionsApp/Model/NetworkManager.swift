
import Foundation

enum NetworkingError: Error {
    case malformedUrl
}

protocol NetworkDataProvider {
    func performTask(with question: String, completion: @escaping (Magic?, Error?) -> Void)
    func cancelCurrentTask()
}

protocol NetworkDataProviderInjectable {
func setNetworkDataProvider(_ networkDataProvider: NetworkDataProvider)
}

class NetworkManager: NetworkDataProvider {
    let networkDataProvider: NetworkDataProvider
    
    private let session = URLSession.shared
    private var currentTask: URLSessionTask?
    
    init(networkDataProvider: NetworkDataProvider) {
        self.networkDataProvider = networkDataProvider
    }
    
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
