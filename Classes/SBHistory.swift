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

private func swindle<T, U>(fn: T -> U) (_ arg: AnyObject) -> U {
    return fn(arg as! T)
}

class SBHistory: NSObject {
    static let sharedHistory = SBHistory()
    
	var history = WebHistory()
    
    override init() {
        super.init()
        WebHistory.setOptionalSharedHistory(history)
        readFromFile()
    }
    
    var URL: NSURL {
        return NSURL(fileURLWithPath: SBHistoryFilePath)
    }
    
    var items: [WebHistoryItem] {
        return history.orderedLastVisitedDays.flatMap{swindle(history.orderedItemsLastVisitedOnDay)($0) as! [WebHistoryItem]}
    }
    
    func itemsAtIndexes(indexes: NSIndexSet) -> [WebHistoryItem] {
        return items.objectsAtIndexes(indexes)
    }
    
    func addNewItem(URLString URLString: String, title: String) {
        let item = WebHistoryItem(URLString: URLString, title: title, lastVisitedTimeInterval: NSDate().timeIntervalSince1970)
        history.addItems([item])
        writeToFile()
    }
    
    func removeItems(inItems: [WebHistoryItem]) {
        if !inItems.isEmpty {
            history.removeItems(inItems)
            writeToFile()
        }
    }
    
    func removeAtIndexes(indexes: NSIndexSet) {
        removeItems(itemsAtIndexes(indexes))
    }
    
    func removeAllItems() {
        history.removeAllItems()
        writeToFile()
    }
    
    func readFromFile() -> Bool {
        return (try? history.loadFromURL(URL)) != nil
    }
    
    func writeToFile() -> Bool {
        return (try? history.saveToURL(URL)) != nil
    }
}