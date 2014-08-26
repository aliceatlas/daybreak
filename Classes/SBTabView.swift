/*
SBTabView.swift

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

@objc
protocol SBTabViewDelegate: NSTabViewDelegate {
    optional func tabView(tabView: SBTabView, selectedItemDidStartLoading tabViewItem: SBTabViewItem)
    optional func tabView(tabView: SBTabView, selectedItemDidFinishLoading tabViewItem: SBTabViewItem)
    optional func tabView(tabView: SBTabView, selectedItemDidFailLoading tabViewItem: SBTabViewItem)
    optional func tabView(tabView: SBTabView, selectedItemDidReceiveTitle tabViewItem: SBTabViewItem)
    optional func tabView(tabView: SBTabView, selectedItemDidReceiveIcon tabViewItem: SBTabViewItem)
    optional func tabView(tabView: SBTabView, selectedItemDidReceiveServerRedirect tabViewItem: SBTabViewItem)
    optional func tabView(tabView: SBTabView, shouldAddNewItemForURL url: NSURL, selection: Bool)
    optional func tabView(tabView: SBTabView, shouldSearchString string: String, newTab: Bool)
    optional func tabView(tabView: SBTabView, shouldConfirmWithMessage message: String) -> Bool
    optional func tabView(tabView: SBTabView, shouldShowMessage message: String)
    optional func tabView(tabView: SBTabView, shouldTextInput prompt: String) -> String
    optional func tabView(tabView: SBTabView, didAddResourceID resourceID: SBWebResourceIdentifier)
    optional func tabView(tabView: SBTabView, didReceiveExpectedContentLengthOfResourceID resourceID: SBWebResourceIdentifier)
    optional func tabView(tabView: SBTabView, didReceiveContentLengthOfResourceID resourceID: SBWebResourceIdentifier)
    optional func tabView(tabView: SBTabView, didReceiveFinishLoadingOfResourceID resourceID: SBWebResourceIdentifier)
    optional func tabView(tabView: SBTabView, didSelectTabViewItem tabViewItem: SBTabViewItem)
}

class SBTabView: NSTabView {
    var sbDelegate: SBTabViewDelegate? {
        get { return delegate as? SBTabViewDelegate }
        set(sbDelegate) { delegate = sbDelegate }
    }
    
    var sbTabViewItems: [SBTabViewItem] {
        return tabViewItems as [SBTabViewItem]
    }

    override var selectedTabViewItem: SBTabViewItem? {
        return super.selectedTabViewItem as? SBTabViewItem
    }
    
    deinit {
        delegate = nil
    }
    
    override var description: String {
        let desc = super.description
        return prefix(desc, desc.utf16Count - 1) + " frame = \(frame)>"
    }
    
    func tabViewItem(#identifier: NSNumber) -> SBTabViewItem? {
        return sbTabViewItems.first { $0.identifier as NSObject == identifier }
    }
    
    // MARK: Actions
    
    override func selectTabViewItem(tabViewItem: NSTabViewItem) {
        super.selectTabViewItem(tabViewItem)
        SBDispatch { self.executeDidSelectTabViewItem(tabViewItem as SBTabViewItem) }
    }
    
    func addItemWithIdentifier(identifier: NSNumber) -> SBTabViewItem {
        let tabViewItem = SBTabViewItem(identifier: identifier)
        addTabViewItem(tabViewItem)
        return tabViewItem
    }
    
    func selectTabViewItemWithItemIdentifier(identifier: NSNumber) -> SBTabViewItem? {
        super.selectTabViewItemWithIdentifier(identifier)
        return selectedTabViewItem
    }
    
    func openURLInSelectedTabViewItem(URLString: String) {
        if let tabViewItem = selectedTabViewItem {
            tabViewItem.URLString = URLString
        }
    }
    
    func closeAllTabViewItems() {
        for item in reverse(sbTabViewItems) {
            item.removeFromTabView()
        }
    }
    
    // MARK: Exec
    
    func executeSelectedItemDidStartLoading(tabViewItem: SBTabViewItem) {
        sbDelegate?.tabView?(self, selectedItemDidStartLoading: tabViewItem)
    }

    func executeSelectedItemDidFinishLoading(tabViewItem: SBTabViewItem) {
        sbDelegate?.tabView?(self, selectedItemDidFinishLoading: tabViewItem)
    }
    
    func executeSelectedItemDidFailLoading(tabViewItem: SBTabViewItem) {
        sbDelegate?.tabView?(self, selectedItemDidFailLoading: tabViewItem)
    }
    
    func executeSelectedItemDidReceiveTitle(tabViewItem: SBTabViewItem) {
        sbDelegate?.tabView?(self, selectedItemDidReceiveTitle: tabViewItem)
    }
    
    func executeSelectedItemDidReceiveIcon(tabViewItem: SBTabViewItem) {
        sbDelegate?.tabView?(self, selectedItemDidReceiveIcon: tabViewItem)
    }
    
    func executeSelectedItemDidReceiveServerRedirect(tabViewItem: SBTabViewItem) {
        sbDelegate?.tabView?(self, selectedItemDidReceiveServerRedirect: tabViewItem)
    }
    
    func executeShouldAddNewItemForURL(url: NSURL, selection: Bool) {
        sbDelegate?.tabView?(self, shouldAddNewItemForURL: url, selection: selection)
    }
    
    func executeShouldSearchString(string: String, newTab: Bool) {
        sbDelegate?.tabView?(self, shouldSearchString: string, newTab: newTab)
    }
    
    func executeShouldConfirmMessage(message: String) -> Bool {
        return sbDelegate?.tabView?(self, shouldConfirmWithMessage: message) ?? false
    }
    
    func executeShouldShowMessage(message: String) {
        sbDelegate?.tabView?(self, shouldShowMessage: message)
    }
    
    func executeShouldTextInput(prompt: String) -> String? {
        return sbDelegate?.tabView?(self, shouldTextInput: prompt)
    }
    
    func executeSelectedItemDidAddResourceID(resourceID: SBWebResourceIdentifier) {
        sbDelegate?.tabView?(self, didAddResourceID: resourceID)
    }
    
    func executeSelectedItemDidReceiveExpectedContentLengthOfResourceID(resourceID: SBWebResourceIdentifier) {
        sbDelegate?.tabView?(self, didReceiveExpectedContentLengthOfResourceID: resourceID)
    }
    
    func executeSelectedItemDidReceiveContentLengthOfResourceID(resourceID: SBWebResourceIdentifier) {
        sbDelegate?.tabView?(self, didReceiveContentLengthOfResourceID: resourceID)
    }
    
    func executeSelectedItemDidReceiveFinishLoadingOfResourceID(resourceID: SBWebResourceIdentifier) {
        sbDelegate?.tabView?(self, didReceiveFinishLoadingOfResourceID: resourceID)
    }
    
    func executeDidSelectTabViewItem(tabViewItem: SBTabViewItem) {
        delegate?.tabView?(self, didSelectTabViewItem: tabViewItem)
    }
    
    // MARK: Event
    
    override func mouseDown(event: NSEvent) {
        super.mouseDown(event)
        superview!.mouseDown(event)
    }
    
    override func mouseDragged(event: NSEvent) {
        super.mouseDragged(event)
        superview!.mouseDragged(event)
    }
    
    override func mouseMoved(event: NSEvent) {
        super.mouseMoved(event)
        superview!.mouseMoved(event)
    }
    
    override func mouseEntered(event: NSEvent) {
        super.mouseEntered(event)
        superview!.mouseEntered(event)
    }
    
    override func mouseExited(event: NSEvent) {
        super.mouseExited(event)
        superview!.mouseExited(event)
    }
    
    override func mouseUp(event: NSEvent) {
        super.mouseUp(event)
        superview!.mouseUp(event)
    }
}