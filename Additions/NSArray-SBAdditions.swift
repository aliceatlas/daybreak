/*
NSArray-SBAdditions.swift

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

extension NSArray {
    func containsIndexes(indexes: NSIndexSet) -> Bool {
        var r = true
        for var i = indexes.lastIndex; i != NSNotFound; i = indexes.indexLessThanIndex(i) {
            if i >= count {
                r = false
            }
        }
        return r
    }
    
    func indexesOfObjects(objects: NSArray) -> NSIndexSet {
        let indexes = NSMutableIndexSet()
        for object in objects {
            let index = indexOfObject(object)
            if index != NSNotFound {
                indexes.addIndex(index)
            }
        }
        return indexes.copy() as! NSIndexSet
    }
    
    convenience init(arrays: [NSArray]) {
        self.init(array: NSMutableArray(arrays: arrays) as [AnyObject])
    }
}

extension NSMutableArray {
    convenience init(arrays: [NSArray]) {
        self.init(capacity: arrays.map({ $0.count }).reduce(0, combine: +))
        for a in arrays {
            addObjectsFromArray(a as! [AnyObject])
        }
    }
}