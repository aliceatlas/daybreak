/*
NSString-SBURLAdditions.swift

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

extension NSString {
    func containsCharacter(character: unichar) -> Bool {
        for i in 0..<length {
            let c = characterAtIndex(i)
            if c == character {
                return true
            }
        }
        return false
    }
    
    func format(args: CVarArgType...) -> NSString {
        return withVaList(args) { NSString(format: self as! String, arguments: $0) }
    }
}

// URL additions
extension NSString {
    func isURLString(hasScheme: UnsafeMutablePointer<ObjCBool>) -> Bool {
        if (rangeOfString(" ").location == NSNotFound && rangeOfString(".").location != NSNotFound) || hasPrefix("http://localhost") {
            let string = URLEncodedString
            let attributedString = NSAttributedString(string: string as! String)
            var range = NSMakeRange(0, 0)
            let URL = attributedString.URLAtIndex(NSMaxRange(range), effectiveRange: &range)
            if range.location == 0 {
                hasScheme.memory = ObjCBool(URL?.scheme?.ifNotEmpty &! string.hasPrefix)
                return true
            }
        }
        return false
    }
    
    var stringByDeletingScheme: NSString? {
        return SBSchemes.first(self.hasPrefix) !! count !! substringFromIndex
    }
    
    var URLEncodedString: NSString {
        let requestURL = NSURL._web_URLWithUserTypedString(self as! String)
        return requestURL.absoluteString!
    }
    
    var requestURLString: NSString {
        var stringValue: NSString = self
        var hasScheme: ObjCBool = false
        if stringValue.isURLString(&hasScheme) {
            if !hasScheme {
                if stringValue.hasPrefix("/") {
                    stringValue = "file://\(stringValue)"
                } else {
                    stringValue = "http://\(stringValue)"
                }
            }
            stringValue = stringValue.URLEncodedString
        } else {
            stringValue = searchURLString
        }
        return stringValue
    }
    
    var searchURLString: NSString {
        var stringValue = self
        
        let info = NSBundle.mainBundle().localizedInfoDictionary!
        if let gSearchFormat = info["SBGSearchFormat"] as? String {
            let str = gSearchFormat.format(stringValue)
            let requestURL = NSURL._web_URLWithUserTypedString(str)
            stringValue = requestURL.absoluteString!
        }
        return stringValue
    }
}