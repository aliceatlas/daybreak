/*
SBHistory.swift

Copyright (c) 2014, Alice Atlas
Copyright (c) 2010, Atsushi Jike
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
    
    var items: [WebHistoryItem] {
        var _items: [WebHistoryItem] = []
        for date in history.orderedLastVisitedDays {
            let orderedItems = history.orderedItemsLastVisitedOnDay(date as NSCalendarDate) as [WebHistoryItem]
            _items += orderedItems
        }
        return _items
    }
    
    func itemsAtIndexes(indexes: NSIndexSet) -> [WebHistoryItem] {
        return items.objectsAtIndexes(indexes)
    }
    
    func addNewItem(#URLString: String, title: String) {
        let item = WebHistoryItem(URLString: URLString, title: title, lastVisitedTimeInterval: NSDate().timeIntervalSince1970)
        history.addItems([item])
        self.writeToFile()
    }
    
    func removeItems(inItems: [WebHistoryItem]) {
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