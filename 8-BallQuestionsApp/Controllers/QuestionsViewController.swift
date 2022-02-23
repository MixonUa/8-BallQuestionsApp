
import UIKit

class QuestionsViewController: UIViewController {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    @IBOutlet weak var questionInputField: UITextField!
    var userQuestion: String = ""
    
    let networkManager = NetworkService()
    
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
            networkManager.getAnswer(question: clearQuestion)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
                self.updateUI(answer: self.networkManager.answer)
            }
        }
    }
        
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        networkManager.stopTask()
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
