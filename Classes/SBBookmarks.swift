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
private var _sharedBookmarks = SBBookmarks()

class SBBookmarks: NSObject {
    var items: [NSMutableDictionary] = []
    class var sharedBookmarks: SBBookmarks {
        return _sharedBookmarks
    }

    override init() {
        super.init()
        readFromFile()
    }
    
    // MARK: Getter
    
    func containsURL(URLString: String) -> Bool {
        return indexOfURL(URLString) != NSNotFound
    }
    
    func indexOfURL(URLString: String) -> Int {
        return items.firstIndex({ $0[kSBBookmarkURL] as! String == URLString }) ?? NSNotFound
    }
    
    func isEqualBookmarkItems(item1: BookmarkItem, anotherItem item2: BookmarkItem) -> Bool {
        return
            (item1[kSBBookmarkTitle] as! String) == (item2[kSBBookmarkTitle] as! String) &&
            (item1[kSBBookmarkURL] as! String) == (item2[kSBBookmarkURL] as! String) &&
            (item1[kSBBookmarkImage] as! NSData) == (item2[kSBBookmarkImage] as! NSData)
    }
    
    func itemAtIndex(index: Int) -> BookmarkItem? {
        return items.get(index)
    }
    
    func containsItem(bookmarkItem: BookmarkItem) -> Int {
        if let i = items.firstIndex({ self.isEqualBookmarkItems($0, anotherItem: bookmarkItem) }) {
            return i
        }
        return NSNotFound
    }
    
    func indexOfItem(bookmarkItem: BookmarkItem) -> Int {
        if let i = items.firstIndex({ $0 === bookmarkItem }) {
            return i
        }
        return NSNotFound
    }

    func indexesOfItems(bookmarkItems: [BookmarkItem]) -> NSIndexSet {
        let indexes = NSMutableIndexSet()
        for bookmarkItem in bookmarkItems {
            let index = indexOfItem(bookmarkItem)
            if index != NSNotFound {
                indexes.addIndex(index)
            }
        }
        return indexes
    }
    
    // MARK: Notify
    
    func notifyDidUpdate() {
        NSNotificationCenter.defaultCenter().postNotificationName(SBBookmarksDidUpdateNotification, object: self)
    }
    
    // MARK: Actions
    
    func readFromFile() -> Bool {
        if kSBCountOfDebugBookmarks > 0 {
            for index in 0..<kSBCountOfDebugBookmarks {
                let title = "Title \(index)"
                let url = "http://\(index).com/"
                let item = SBCreateBookmarkItem(title, url, SBEmptyBookmarkImageData, NSDate(), nil, NSStringFromPoint(NSZeroPoint))
                items.append(NSMutableDictionary(dictionary: item as! [NSObject: AnyObject]))
            }
        } else {
            let info = NSDictionary(contentsOfFile: SBBookmarksFilePath!)
            if let bookmarkItems = info?[kSBBookmarkItems] as? [BookmarkItem] {
                if !bookmarkItems.isEmpty {
                    items = bookmarkItems.map { NSMutableDictionary(dictionary: $0 as! [NSObject: AnyObject]) }
                    return true
                }
            }
        }
        return false
    }
    
    func writeToFile() -> Bool {
        var r = false
        if !items.isEmpty {
            let path = SBBookmarksFilePath!
            var error: NSError?
            let data = NSPropertyListSerialization.dataWithPropertyList(
                SBBookmarksWithItems(items), format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: &error)
            if error != nil {
                DebugLog("%@ error = %@", __FUNCTION__, error!)
            } else {
                r = data!.writeToFile(path, atomically: true)
            }
        }
        return r
    }
    
    
    func addItem(bookmarkItem: BookmarkItem?) {
        if let item = bookmarkItem {
            let dict = NSMutableDictionary(dictionary: item as! [NSObject: AnyObject])
            let index = indexOfURL(dict[kSBBookmarkURL] as! String)
            if index == NSNotFound {
                items.append(dict)
            } else {
                items[index] = dict
            }
            writeToFile()
            SBDispatch(notifyDidUpdate)
        }
    }
    
    func replaceItem(item: BookmarkItem, atIndex index: Int) {
        items[index] = NSMutableDictionary(dictionary: item as! [NSObject: AnyObject])
        writeToFile()
        SBDispatch(notifyDidUpdate)
    }
    
    func replaceItem(oldItem: BookmarkItem, withItem newItem: BookmarkItem) {
        let index = indexOfItem(oldItem)
        if index != NSNotFound {
            items[index] = NSMutableDictionary(dictionary: newItem as! [NSObject: AnyObject])
            writeToFile()
            SBDispatch(notifyDidUpdate)
        }
    }
    
    func addItems(inItems: [BookmarkItem], toIndex: Int) {
        if !inItems.isEmpty && toIndex <= items.count {
    		//[items insertObjects:inItems atIndexes:[NSIndexSet indexSetWithIndex:toIndex]];
            for (i, item) in enumerate(inItems) {
                items.insert(NSMutableDictionary(dictionary: item as! [NSObject: AnyObject]), atIndex: i + toIndex)
            }
            writeToFile()
            SBDispatch(notifyDidUpdate)
        }
    }
    
    func moveItemsAtIndexes(indexes: NSIndexSet, toIndex: Int) {
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
        items.removeObjectsAtIndexes(indexes)
        writeToFile()
        SBDispatch(notifyDidUpdate)
    }
    
    func doubleClickItemsAtIndexes(indexes: NSIndexSet) {
        let selectedItems = items.objectsAtIndexes(indexes)
        openItemsInSelectedDocument(selectedItems)
    }
    
    func changeLabelName(labelName: String, atIndexes indexes: NSIndexSet) {
        indexes.enumerateIndexesWithOptions(.Reverse) {
            (index: Int, _) in
            self.items[index][kSBBookmarkLabelName] = labelName
            return
        }
        
        writeToFile()
        SBDispatch(notifyDidUpdate)
    }
    
    // MARK: Exec
    
    func openItemsFromMenuItem(menuItem: NSMenuItem) {
        let representedItems = menuItem.representedObject as! [BookmarkItem]
        if !representedItems.isEmpty {
            openItemsInSelectedDocument(representedItems)
        }
    }
    
    func openItemsInSelectedDocument(inItems: [BookmarkItem]) {
        if let selectedDocument = SBGetSelectedDocument {
            if selectedDocument.respondsToSelector("openAndConstructTabWithBookmarkItems:") {
                selectedDocument.openAndConstructTab(bookmarkItems: inItems)
            }
        }
    }
    
    func removeItemsFromMenuItem(menuItem: NSMenuItem) {
        let representedIndexes = menuItem.representedObject as! NSIndexSet
        if representedIndexes.count > 0 {
            removeItemsAtIndexes(representedIndexes)
        }
    }
    
    func changeLabelFromMenuItem(menuItem: NSMenuItem) {
        let representedIndexes = menuItem.representedObject as! NSIndexSet
        let tag = menuItem.menu!.indexOfItem(menuItem)
        if representedIndexes.count > 0 && tag < SBBookmarkLabelColorNames.count {
            let labelName = SBBookmarkLabelColorNames[tag]
            changeLabelName(labelName, atIndexes: representedIndexes)
        }
    }
}