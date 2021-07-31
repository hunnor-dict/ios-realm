import Foundation
import RealmSwift

class Dictionary {
    
    static let sharedInstance = Dictionary()
    
    private var realm: Realm?
    
    var delegate: DictionaryDelegate?
    
    func counts() -> [String: Int] {
        if !isOpen() {
            open()
        }
        var hu = 0
        var nb = 0
        if let safeRealm = realm {
            hu = safeRealm.objects(Entry.self)
                .filter("lang = \"hu\"")
                .count
            nb = safeRealm.objects(Entry.self)
                .filter("lang = \"nb\"")
                .count
        }
        return ["hu": hu, "nb": nb]
    }

    func queryWords(_ query: String) -> [Word] {
        if !isOpen() {
            open()
        }
        var words: [Word] = []
        if let safeRealm = realm {
            var results = safeRealm.objects(Word.self)
                .filter("value BEGINSWITH[c] \"\(query)\" AND inflected = 0")
                .sorted(by: ["value"])
                .distinct(by: ["value"])
            if (results.isEmpty) {
                results = safeRealm.objects(Word.self)
                    .filter("value BEGINSWITH[cd] \"\(query)\" AND inflected = 0")
                    .sorted(by: ["value"])
                    .distinct(by: ["value"])
            }
            while (words.count < 100 && results.count > words.count) {
                words.append(results[words.count])
            }
        }
        return words
    }
    
    func queryEntries(_ query: String) -> [Entry] {
        if !isOpen() {
            open()
        }
        var entries: [Entry] = []
        if let safeRealm = realm {
            let results = safeRealm.objects(Entry.self)
                .filter("ANY roots.value = \"\(query)\"")
            for result in results {
                entries.append(result)
            }
        }
        return entries
    }
    
    func queryEntriesWithInflections(_ query: String) -> [Entry] {
        if !isOpen() {
            open()
        }
        var entries: [Entry] = []
        if let safeRealm = realm {
            let results = safeRealm.objects(Entry.self)
                .filter("ANY roots.value = \"\(query)\" OR ANY inflections.value = \"\(query)\"")
            for result in results {
                entries.append(result)
            }
        }
        return entries
    }
    
    private func isOpen() -> Bool {
        return realm != nil
    }
    
    private func open() {
        let realmURL = Bundle.main.url(forResource: "HunNor", withExtension: "realm")
        let config = Realm.Configuration(fileURL: realmURL, readOnly: true)
        Realm.Configuration.defaultConfiguration = config
        do {
            realm = try Realm()
        } catch {
            if let safeRealmURL = realmURL {
                delegate?.error(message: "Error opening Realm at \(safeRealmURL.absoluteString)")
            }
        }
    }
    
}
