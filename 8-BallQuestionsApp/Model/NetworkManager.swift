
import Foundation

enum NetworkingError: Error {
    case malformedUrl
}

protocol NetworkDataProvider {
    func performTask(with question: String, completion: @escaping (Magic?, Error?) -> Void)
    func cancelCurrentTask()
}

class NetworkManager: NetworkDataProvider {
    private let session = URLSession.shared
    private var currentTask: URLSessionTask?
    
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

class NetworkService {
    let networkDataProvider: NetworkDataProvider
    var answer: Answers = Answers(retrievedAnswer: nil, standardAnswer: DataManager.instance.standardAnswer)
    
    init(networkDataProvider: NetworkDataProvider = NetworkManager()) {
        self.networkDataProvider = networkDataProvider
    }
    
    func updateAnswer(retrievedAnswer: String) {
        self.answer.retrievedAnswer = retrievedAnswer
    }
    
    func getAnswer(question: String) {
        networkDataProvider.performTask(with: question) { [weak self] (item, error) in
            guard error == nil else {
                self?.answer = Answers(retrievedAnswer: nil, standardAnswer: DataManager.instance.standardAnswer)
                return
            }
            guard let item = item else {
                self?.answer = Answers(retrievedAnswer: nil, standardAnswer: DataManager.instance.standardAnswer)
                return
            }
            self?.answer = Answers(retrievedAnswer: item.magic.answer, standardAnswer: DataManager.instance.standardAnswer)
        }
    }
    
    func stopTask() {
        networkDataProvider.cancelCurrentTask()
    }
}
