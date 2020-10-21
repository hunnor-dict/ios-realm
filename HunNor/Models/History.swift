import Foundation

class History {
    
    static let sharedInstance = History()
    
    func setEnabled(to enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "historyEnabled")
    }
    
    func isEnabled() -> Bool {
        let defaultEnabled = true
        if let storedEnabled = UserDefaults.standard.object(forKey: "historyEnabled") as? Bool {
            return storedEnabled
        }
        return defaultEnabled
    }
    
    func setCapacity(to capacity: Int) {
        if (capacity > 0) {
            UserDefaults.standard.set(capacity, forKey: "historyCapacity")
        }
    }
    
    func getCapacity() -> Int {
        let defaultCapacity = 10
        let storedCapacity = UserDefaults.standard.integer(forKey: "historyCapacity")
        return storedCapacity > 0 ? storedCapacity : defaultCapacity
    }
    
    func setTerms(to terms: [String]) {
        UserDefaults.standard.set(terms, forKey: "historyTerms")
    }
    
    func getTerms() -> [String] {
        var terms: [String] = []
        if (isEnabled()) {
            if let storedTerms = UserDefaults.standard.array(forKey: "historyTerms") as? [String] {
                terms = storedTerms
            }
        }
        return terms
    }
    
    func saveTerm(term: String?) {
        if (isEnabled()) {
            if let safeTerm = term {
                var termsToSet: [String] = []
                if let storedTerms = UserDefaults.standard.array(forKey: "historyTerms") as? [String] {
                    termsToSet = storedTerms
                    termsToSet.removeAll { $0 == safeTerm }
                    termsToSet.insert(contentsOf: [safeTerm], at: 0)
                    termsToSet = Array(termsToSet.prefix(getCapacity()))
                } else {
                    termsToSet.append(safeTerm)
                }
                UserDefaults.standard.set(termsToSet, forKey: "historyTerms")
            }
        }
    }
    
}
