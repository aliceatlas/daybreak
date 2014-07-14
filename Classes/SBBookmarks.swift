/*
SBBookmarks.swift

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

import Foundation

//typealias BookmarkItem = [String: Any]
typealias BookmarkItem = NSDictionary
var _sharedBookmarks = SBBookmarks()

class SBBookmarks: NSObject {
    var items: [NSMutableDictionary] = []
    class var sharedBookmarks: SBBookmarks {
        return _sharedBookmarks
    }

    init() {
        super.init()
        self.readFromFile()
    }
    
    // Getter
    
    func containsURL(urlString: String) -> Bool {
        return self.indexOfURL(urlString) != NSNotFound
    }
    
    func indexOfURL(urlString: String) -> UInt {
        if let index = items.firstIndex({ $0[kSBBookmarkURL] as NSString == urlString }) {
            return UInt(index)
        }
        return NSNotFound
    }
    
    func isEqualBookmarkItems(item1: BookmarkItem, anotherItem item2: BookmarkItem) -> Bool {
        return
            (item1[kSBBookmarkTitle] as String) == (item2[kSBBookmarkTitle] as String) &&
            (item1[kSBBookmarkURL] as String) == (item2[kSBBookmarkURL] as String) &&
            (item1[kSBBookmarkImage] as NSData) == (item2[kSBBookmarkImage] as NSData)
    }
    
    func itemAtIndex(index: UInt) -> BookmarkItem? {
        let i = Int(index)
        if i < items.count {
            return items[i]
        }
        return nil
    }
    
    func containsItem(bookmarkItem: BookmarkItem) -> UInt {
        if let i = items.firstIndex({ self.isEqualBookmarkItems($0, anotherItem: bookmarkItem) }) {
            return UInt(i)
        }
        return NSNotFound
    }
    
    func indexOfItem(bookmarkItem: BookmarkItem) -> UInt {
        if let i = items.firstIndex({ $0 === bookmarkItem }) {
            return UInt(i)
        }
        return NSNotFound
    }

    func indexesOfItems(bookmarkItems: [BookmarkItem]) -> NSIndexSet {
        let indexes = NSMutableIndexSet()
        for bookmarkItem in bookmarkItems {
            let index = self.indexOfItem(bookmarkItem)
            if index != NSNotFound {
                indexes.addIndex(Int(index))
            }
        }
        return indexes
    }
    
    // Notify
    
    func notifyDidUpdate() {
        NSNotificationCenter.defaultCenter().postNotificationName(SBBookmarksDidUpdateNotification, object: self)
    }
    
    // Actions
    
    func readFromFile() -> Bool {
        if kSBCountOfDebugBookmarks > 0 {
            for index in 0..<kSBCountOfDebugBookmarks {
                let title = "Title \(index)"
                let url = "http://\(index).com/"
                let item = SBCreateBookmarkItem(title, url, SBEmptyBookmarkImageData(), NSDate.date(), nil, NSStringFromPoint(NSZeroPoint))
                items.append(NSMutableDictionary(dictionary: item))
            }
        } else {
            let info = NSDictionary(contentsOfFile: SBBookmarksFilePath())
            if info.count > 0 {
                if let bookmarkItems = info[kSBBookmarkItems] as? [BookmarkItem] {
                    if bookmarkItems.count > 0 {
                        items.removeAll()
                        items += bookmarkItems.map { NSMutableDictionary(dictionary: $0) }
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func writeToFile() -> Bool {
        var r = false
        if items.count > 0 {
            let path = SBBookmarksFilePath()
            var error: NSError?
            let data = NSPropertyListSerialization.dataWithPropertyList(
                SBBookmarksWithItems(items), format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: &error)
            if error? {
                DebugLogS("\(__FUNCTION__) error = \(error)")
            } else {
                r = data.writeToFile(path, atomically: true)
            }
        }
        return r
    }
    
    
    func addItem(bookmarkItem: BookmarkItem?) {
        if let item = bookmarkItem {
            let dict = NSMutableDictionary(dictionary: item)
            let index = indexOfURL(dict[kSBBookmarkURL] as String)
            if index == NSNotFound {
                items.append(dict)
            } else {
                items[Int(index)] = dict
            }
            self.writeToFile()
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "notifyDidUpdate", userInfo: nil, repeats: false)
        }
    }
    
    func replaceItem(item: BookmarkItem, atIndex index: UInt) {
        items[Int(index)] = NSMutableDictionary(dictionary: item)
        self.writeToFile()
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "notifyDidUpdate", userInfo: nil, repeats: false)
    }
    
    func replaceItem(oldItem: BookmarkItem, withItem newItem: BookmarkItem) {
        let index = indexOfItem(oldItem)
        if index != NSNotFound {
            items[Int(index)] = NSMutableDictionary(dictionary: newItem)
            self.writeToFile()
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "notifyDidUpdate", userInfo: nil, repeats: false)
        }
    }
    
    func addItems(inItems: [BookmarkItem], toIndex: UInt) {
        if !inItems.isEmpty && Int(toIndex) <= items.count {
    		//[items insertObjects:inItems atIndexes:[NSIndexSet indexSetWithIndex:toIndex]];
            for (i, item) in enumerate(inItems) {
                items.insert(NSMutableDictionary(dictionary: item), atIndex: i + Int(toIndex))
            }
            self.writeToFile()
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "notifyDidUpdate", userInfo: nil, repeats: false)
        }
    }
    
    func moveItemsAtIndexes(indexes: NSIndexSet, toIndex: UInt) {
        /*
        NSArray *bookmarkItems = [items objectsAtIndexes:indexes];
        if ([bookmarkItems count] > 0 && toIndex <= [items count])
        {
            NSUInteger to = toIndex;
            NSUInteger offset = 0;
            NSUInteger i = 0;
            for (i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
            {
                if (i < to)
                    offset++;
            }
            if (to >= offset)
            {
                to -= offset;
            }
            [bookmarkItems retain];
            [items removeObjectsAtIndexes:indexes];
            [items insertObjects:bookmarkItems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(to, [indexes count])]];
            [bookmarkItems release];
            [self writeToFile];
            [self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
        }
        */
    }

    func removeItemsAtIndexes(indexes: NSIndexSet) {
        self.items.removeObjectsAtIndexes(indexes)
        self.writeToFile()
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "notifyDidUpdate", userInfo: nil, repeats: false)
    }
    
    func doubleClickItemsAtIndexes(indexes: NSIndexSet) {
        let selectedItems = self.items.objectsAtIndexes(indexes)
        self.openItemsInSelectedDocument(selectedItems)
    }
    
    func changeLabelName(labelName: String, atIndexes indexes: NSIndexSet) {
        indexes.enumerateIndexesWithOptions(.Reverse) {
            (index: Int, _) in
            self.items[index][kSBBookmarkLabelName] = labelName
            return
        }
        
        self.writeToFile()
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "notifyDidUpdate", userInfo: nil, repeats: false)
    }
    
    // Exec
    
    func openItemsFromMenuItem(menuItem: NSMenuItem) {
        let representedItems = menuItem.representedObject as [BookmarkItem]
        if representedItems.count > 0 {
            self.openItemsInSelectedDocument(representedItems)
        }
    }
    
    func openItemsInSelectedDocument(inItems: [BookmarkItem]) {
        if let selectedDocument = SBGetSelectedDocument() {
            if selectedDocument.respondsToSelector("openAndConstructTabWithBookmarkItems:") {
                selectedDocument.openAndConstructTabWithBookmarkItems(inItems)
            }
        }
    }
    
    func removeItemsFromMenuItem(menuItem: NSMenuItem) {
        let representedIndexes = menuItem.representedObject as NSIndexSet
        if representedIndexes.count > 0 {
            self.removeItemsAtIndexes(representedIndexes)
        }
    }
    
    func changeLabelFromMenuItem(menuItem: NSMenuItem) {
        let representedIndexes = menuItem.representedObject as NSIndexSet
        let tag = menuItem.menu.indexOfItem(menuItem)
        if representedIndexes.count > 0 && tag < SBBookmarkLabelColorNames.count {
            let labelName = SBBookmarkLabelColorNames[tag]
            self.changeLabelName(labelName, atIndexes: representedIndexes)
        }
    }
}