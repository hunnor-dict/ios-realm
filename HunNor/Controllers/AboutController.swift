import UIKit

class AboutController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
