//
//  Array-SBAdditions.swift
//  Sunrise
//
//  Created by Alice Atlas on 6/29/14.
//
//

import Foundation

extension Array {
    func objectsAtIndexes(indexes: NSIndexSet) -> Element[] {
        var objs = Element[]()
        indexes.enumerateIndexesUsingBlock {
            (Int i, _) in
            objs.append(self[i])
        }
        return objs
    }
    
    mutating func removeObjectsAtIndexes(indexes: NSIndexSet) {
        indexes.enumerateIndexesWithOptions(NSEnumerationOptions.Reverse) {
            (index: Int, _) in
            self.removeAtIndex(index)
            return
        }
    }
    
    func first(condition: (Element) -> Bool) -> Element? {
        for item in self {
            if condition(item) {
                return item
            }
        }
        return nil
    }
    
    func firstIndex(condition: (Element) -> Bool) -> Int? {
        for (index, item) in enumerate(self) {
            if condition(item) {
                return index
            }
        }
        return nil
    }
    
    func any(condition: (T) -> Bool) -> Bool {
        return self.first(condition) != nil
    }
}

func removeObject<T: Equatable>(inout array: T[], toRemove: T) {
    if let index = array.firstIndex({ $0 == toRemove }) {
        array.removeAtIndex(index)
    }
}

func removeObjects<T: Equatable>(inout array: T[], toRemove: T[]) {
    for item in array {
        removeObject(&array, item)
    }
}
