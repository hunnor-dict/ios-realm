import UIKit

class SearchController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var query: String?
    var results: [Any] = []
    
    var style = [
        "body {font-family: -apple-system; font-size: 14pt;}",
        "div.infl {color: grey; font-size: 80%;}"]
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        tableView.dataSource = self
        tableView.delegate = self
        
        Dictionary.sharedInstance.delegate = self
        
        if (traitCollection.userInterfaceStyle == .dark) {
            style.append("body {color: white;}")
        }
        changeQuery(to: query)
    }
    
    func changeQuery(to query: String?) {
        self.query = query
        if let safeQuery = query {
            if safeQuery.isEmpty {
                results = History.sharedInstance.getTerms()
            } else {
                results = Dictionary.sharedInstance.queryWords(safeQuery)
            }
        } else {
            results = History.sharedInstance.getTerms()
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
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
    

}

extension SearchController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let result = results.first {
            if let term = result as? String {
                // String from History
                History.sharedInstance.saveTerm(term: term)
                results = Dictionary.sharedInstance.queryEntries(term)
                tableView.reloadData()
            } else if let word = result as? Word {
                // Word from Dictionary
                History.sharedInstance.saveTerm(term: word.value)
                results = Dictionary.sharedInstance.queryEntries(word.value)
                tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        changeQuery(to: searchBar.text)
    }
    
}

extension SearchController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let label = cell.textLabel {
                if  let text = label.text {
                    query = text
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
        searchBar.endEditing(true)
        let result = results[indexPath.row]
        if !(result is Entry) {
            if let safeQuery = query {
                searchBar.text = nil
                query = nil
                History.sharedInstance.saveTerm(term: safeQuery)
                results = Dictionary.sharedInstance.queryEntries(safeQuery)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCell", for: indexPath)
        if let label = cell.textLabel {
            let result = results[indexPath.row]
            if let term = result as? String {
                // String from History
                label.text = term
            } else if let word = result as? Word {
                // Word from Dictionary
                label.text = word.value
            } else if let entry = result as? Entry {
                // Entry from Dictionary
                label.numberOfLines = 0
                let content = entry.content
                let source = buildDocument(style: style, content: content)
                if let attributedText = parseDocument(source: source) {
                    label.attributedText = attributedText
                } else {
                    label.text = content
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var actions: [UIContextualAction] = []
        
        let result = results[indexPath.row]
        
        if result is String {
            let deleteAction = UIContextualAction(style: .destructive, title: "Törlés") { (action, view, completionHandler) in
                self.results.remove(at: indexPath.row)
                let terms = self.results.compactMap { result in
                    result as? String
                }
                History.sharedInstance.setTerms(to: terms)
                self.tableView.reloadData()
                completionHandler(true)
            }
            actions.append(deleteAction)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
        
    }
    
}

extension SearchController: DictionaryDelegate {
    
    func error(message: String) {
        print(message)
    }
    
}
