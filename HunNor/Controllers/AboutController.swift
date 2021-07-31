import UIKit

class AboutController: UIViewController {
    
    override func viewDidLoad() {
        let counts = Dictionary.sharedInstance.counts()
        let hu = counts["hu"] ?? 0
        let nb = counts["nb"] ?? 0
        statsLabel.text = "Az alkalmazás \(hu) magyar és \(nb) norvég szócikket tartalmaz."
        super.viewDidLoad()
    }
    
    @IBOutlet weak var statsLabel: UILabel!

    @IBAction func dictionaryLinkPressed(_ sender: UIButton) {
        openURL("https://dict.hunnor.net")
    }
    @IBAction func sourceLinkPressed(_ sender: UIButton) {
        openURL("https://github.com/hunnor-dict/ios-realm")
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
}
