/*
Array-SBAdditions.swift

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

extension Array {
    func objectsAtIndexes(indexes: NSIndexSet) -> [Element] {
        var objs: [Element] = []
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
    
    func any(condition: (Element) -> Bool) -> Bool {
        if let x = first(condition) {
            return true
        }
        return false
    }
    
    func get(index: Int) -> Element? {
        return (index >= 0 && index < count) &? self[index]
    }
}

func removeItem<T: Equatable>(inout array: [T], toRemove: T) {
    if let index = array.firstIndex({ $0 == toRemove }) {
        array.removeAtIndex(index)
    }
}

func removeItems<T: Equatable>(inout array: [T], toRemove: [T]) {
    for item in array {
        removeItem(&array, item)
    }
}

func containsItem<T: Equatable>(array: [T], value: T) -> Bool {
    return array.first({ $0 == value }) != nil
}

func indexOfItem<T: Equatable>(array: [T], value: T) -> Int? {
    return array.firstIndex { $0 == value }
}