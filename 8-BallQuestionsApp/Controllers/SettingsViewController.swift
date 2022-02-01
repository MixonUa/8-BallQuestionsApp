
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var standardAnswerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 6
        standardAnswerLabel.text = DataManager.instance.standardAnswer
    }
    
    @IBAction func saveButtonDidPressed(_ sender: Any) {
        guard let answer = answerTextField.text, !answer.isEmpty else { return }
        DataManager.instance.changeStandardAnswer(answer)
        navigationController?.popViewController(animated: true)
    }
}
