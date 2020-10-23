import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry] = []
    var texts: [NSAttributedString] = []
    
    var style = [
        "body {font-family: -apple-system; font-size: 14pt;}",
        "div.infl {color: grey; font-size: 80%;}"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if let context = extensionContext {
            let items = context.inputItems
            if let item = items.first {
                if let extensionItem = item as? NSExtensionItem {
                    if let itemProviders = extensionItem.attachments {
                        if let itemProvider = itemProviders.first {
                            if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                                itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (result, error) in
                                    if let query = result as? String {
                                        DispatchQueue.main.async {
                                            print("Query for \(query)")
                                            self.entries = Dictionary.sharedInstance.queryEntriesWithInflections(query)
                                            self.refreshTable()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func refreshTable() {
        for entry in self.entries {
            let content = entry.content
            let source = self.buildDocument(style: self.style, content: content)
            if let attributedText = self.parseDocument(source: source) {
                self.texts.append(attributedText)
            }
        }
        self.tableView.reloadData()
    }
    
    func buildDocument(style: [String], content: String) -> String {
        return "<html><head><style type=\"text/css\">\(style.joined(separator: " "))</style></head><body>\(content)</body></html>"
    }
    
    func parseDocument(source: String) -> NSAttributedString? {
        return try? NSAttributedString(
            data: Data(source.utf8),
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
}

extension ActionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "extensionTableCell", for: indexPath)
        if let label = cell.textLabel {
            let text = texts[indexPath.row]
            label.numberOfLines = 0
            label.attributedText = text
        } else {
            print("No text label")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
