//
//  String-SBAdditions.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/2/14.
//
//

import Foundation

extension String {
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        let zot = NSString(string: self)
        return zot.stringByAppendingPathComponent(pathComponent)
    }
}