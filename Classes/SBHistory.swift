//
//  SBHistory.swift
//  Sunrise
//
//  Created by Alice Atlas on 6/29/14.
//
//

var _sharedHistory = SBHistory()

class SBHistory: NSObject {
	var history = WebHistory()
    
    class func sharedHistory() -> SBHistory {
        return _sharedHistory
    }
    
    init() {
        super.init()
        WebHistory.setOptionalSharedHistory(history)
        self.readFromFile()
    }
    
    func URL() -> NSURL {
        return NSURL.fileURLWithPath(SBHistoryFilePath())
    }
    
    var items: WebHistoryItem[] {
        var _items = WebHistoryItem[]()
        for date in history.orderedLastVisitedDays {
            let orderedItems = history.orderedItemsLastVisitedOnDay(date as NSCalendarDate) as WebHistoryItem[]
            _items += orderedItems
        }
        return _items
    }
    
    func itemsAtIndexes(indexes: NSIndexSet) -> WebHistoryItem[] {
        return items.objectsAtIndexes(indexes)
    }
    
    func addNewItem(#URLString: String, title: String) {
        let item = WebHistoryItem(URLString: URLString, title: title, lastVisitedTimeInterval: NSDate().timeIntervalSince1970)
        history.addItems([item])
        self.writeToFile()
    }
    
    func removeItems(inItems: WebHistoryItem[]) {
        if inItems.count > 0 {
            history.removeItems(inItems)
            self.writeToFile()
        }
    }
    
    func removeAtIndexes(indexes: NSIndexSet) {
        self.removeItems(self.itemsAtIndexes(indexes))
    }
    
    func removeAllItems() {
        history.removeAllItems()
        self.writeToFile()
    }
    
    func readFromFile() -> Bool {
        return history.loadFromURL(self.URL(), error: nil)
    }
    
    func writeToFile() -> Bool {
        return history.saveToURL(self.URL(), error: nil)
    }
}