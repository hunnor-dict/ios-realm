import Foundation
import RealmSwift

class Entry: Object {
    
    @objc dynamic var lang = ""
    @objc dynamic var id = 0
    
    @objc dynamic var content = ""
    
    let roots = List<Word>()
    let inflections = List<Word>()
    
}
