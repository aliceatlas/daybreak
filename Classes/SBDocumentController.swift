/*
SBDocumentController.swift

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

class SBDocumentController: NSDocumentController {
    override var defaultType: String? { return kSBDocumentTypeName }
    
    override func typeForContentsOfURL(inAbsoluteURL: NSURL, error outError: NSErrorPointer) -> String? {
        if inAbsoluteURL.fileURL {
            return super.typeForContentsOfURL(inAbsoluteURL, error: outError)
        } else {
            return kSBDocumentTypeName
        }
    }
    
    override func openUntitledDocumentAndDisplay(displayDocument: Bool, error outError: NSErrorPointer) -> AnyObject? {
        let sidebarVisibility = NSUserDefaults.standardUserDefaults().boolForKey(kSBSidebarVisibilityFlag)
        let homepage = SBPreferences.sharedPreferences.homepage(true)?.ifNotEmpty
        let URL = homepage !! {NSURL(string: $0.requestURLString)}
        return openUntitledDocumentAndDisplay(displayDocument, sidebarVisibility: sidebarVisibility, initialURL: URL, error: outError)
    }
    
    func openUntitledDocumentAndDisplay(displayDocument: Bool, sidebarVisibility: Bool, initialURL URL: NSURL?, error outError: NSErrorPointer) -> AnyObject? {
        let type = URL !! {typeForContentsOfURL($0, error: outError)}
        if type == kSBStringsDocumentTypeName {
        } else if let document = makeUntitledDocumentOfType(kSBDocumentTypeName, error: outError) as? SBDocument {
            URL !! { document.initialURL = $0 }
            document.sidebarVisibility = sidebarVisibility
            addDocument(document)
            document.makeWindowControllers()
            if displayDocument {
                document.showWindows()
            }
            return document
        }
        return nil
    }
}
