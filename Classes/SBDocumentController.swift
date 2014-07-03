//
//  SBDocumentController.swift
//  Sunrise
//
//  Created by Alice Atlas on 6/29/14.
//
//

import Cocoa

class SBDocumentController: NSDocumentController {
    override func defaultType() -> String {
        return kSBDocumentTypeName
    }
    
    override func typeForContentsOfURL(inAbsoluteURL: NSURL?, error outError: NSErrorPointer) -> String! {
        if inAbsoluteURL?.fileURL {
            return super.typeForContentsOfURL(inAbsoluteURL, error: outError)
        } else {
            return kSBDocumentTypeName
        }
    }
    
    override func openUntitledDocumentAndDisplay(displayDocument: Bool, error outError: NSErrorPointer) -> AnyObject! {
        let sidebarVisibility = NSUserDefaults.standardUserDefaults().boolForKey(kSBSidebarVisibilityFlag)
        if let homepage = SBPreferences.sharedPreferences().homepage(true) {
            NSLog("YES", homepage)
            let url = (countElements(homepage) > 0) ? NSURL.URLWithString(NSString(string: homepage).requestURLString()) : nil
            return self.openUntitledDocumentAndDisplay(displayDocument, sidebarVisibility: sidebarVisibility, initialURL: url, error: outError)
        }
        NSLog("NO")
        return nil
    }
    
    func openUntitledDocumentAndDisplay(displayDocument: Bool, sidebarVisibility: Bool, initialURL url: NSURL?, error outError: NSErrorPointer) -> AnyObject! {
        let type = self.typeForContentsOfURL(url, error: outError)
        if type == kSBStringsDocumentTypeName {
        } else {
            if let document = self.makeUntitledDocumentOfType(kSBDocumentTypeName, error: outError) as? SBDocument {
                if url? {
                    document.initialURL = url
                }
                document.sidebarVisibility = sidebarVisibility
                self.addDocument(document)
                document.makeWindowControllers()
                if displayDocument {
                    document.showWindows()
                }
                return document
            }
        }
        return nil
    }
}
