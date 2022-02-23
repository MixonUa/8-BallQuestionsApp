
import UIKit

class QuestionsViewController: UIViewController, NetworkDataProviderInjectable {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    @IBOutlet weak var questionInputField: UITextField!
    var userQuestion: String = ""
    
    private var networkManager: NetworkDataProvider!
    func setNetworkDataProvider(_ networkDataProvider: NetworkDataProvider) {
        self.networkManager = networkDataProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionLabel.isHidden = true
        answerLabel.isHidden = true
        
        noInternetConnectionLabel.textColor = .red
        noInternetConnectionLabel.text = "No internet connection"
        noInternetConnectionLabel.isHidden = true
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let question = questionInputField.text, !question.isEmpty else { return }
            userQuestion = question
            let clearQuestion = String(userQuestion.filter {$0 != " "})
            networkManager.performTask(with: clearQuestion) { [weak self] (item, error) in
                guard error == nil else {
                    let answer = Answers(retrievedAnswer: nil, standardAnswer: DataManager.instance.standardAnswer)
                    self?.updateUI(answer: answer)
                    return
                }
                
                guard let item = item else {
                    let answer = Answers(retrievedAnswer: nil, standardAnswer: DataManager.instance.standardAnswer)
                    self?.updateUI(answer: answer)
                    return
                }
                
                let answer = Answers(retrievedAnswer: item.magic.answer, standardAnswer: DataManager.instance.standardAnswer)
                self?.updateUI(answer: answer)
            }
        }
    }
        
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        networkManager.cancelCurrentTask()
    }
    
    private func updateUI(answer: Answers) {
        guard let question = questionInputField.text, !question.isEmpty else { return }
        
        questionLabel.text = questionInputField.text
        if let internetAnswer = answer.retrievedAnswer {
            answerLabel.text = internetAnswer
            noInternetConnectionLabel.isHidden = true
        } else {
            answerLabel.text = answer.standardAnswer
            noInternetConnectionLabel.isHidden = false
        }
        answerLabel.isHidden = false
        questionLabel.isHidden = false
        questionInputField.text = ""
    }
}
