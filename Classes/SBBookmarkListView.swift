/*
SBBookmarkListView.swift

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

@objc protocol SBBookmarkListViewDelegate {
    optional func bookmarkListViewShouldOpenSearchbar(SBBookmarkListView)
    optional func bookmarkListViewShouldCloseSearchbar(SBBookmarkListView) -> Bool
}

class SBBookmarkListView: SBView, NSAnimationDelegate, NSDraggingDestination {
    unowned var wrapperView: SBBookmarksView
    weak var delegate: SBBookmarkListViewDelegate?
    var cellSize: NSSize!
    private var itemViews: [SBBookmarkListItemView] = []
    var draggedItems: NSArray?
    var draggedItemView: SBBookmarkListItemView?
    private var toolsItemView: SBBookmarkListItemView?
    private var _block = NSZeroPoint
    private var point = NSZeroPoint
    private var offset: NSSize!
    private var animationIndex: Int!
    
    private var selectionView: SBView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var draggingLineView: SBView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var toolsTimer: NSTimer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    private var searchAnimations: NSViewAnimation? {
        didSet {
            if let animations = oldValue {
                if animations.animating {
                    animations.stopAnimation()
                }
            }
        }
    }
    
    var mode: SBBookmarkMode = .Icon {
        didSet {
            if mode != oldValue {
                setCellSizeForMode(mode)
                layout(0.0)
            }
        }
    }
    
    var cellWidth: CGFloat! {
        didSet {
            if cellWidth != oldValue {
                switch mode {
                    case .Icon:
                        cellSize = NSMakeSize(cellWidth, cellWidth)
                    case .List:
                        cellSize = NSMakeSize(width, 22.0)
                    case .Tile:
                        cellSize = NSMakeSize(cellWidth / kSBBookmarkFactorForImageHeight * kSBBookmarkFactorForImageWidth, cellWidth)
                }
                layout(0.0)
            }
        }
    }
    
    private lazy var removeButton: SBButton = {
        let removeRect = self.removeButtonRect(nil)
        let removeButton = SBButton(frame: removeRect)
        removeButton.autoresizingMask = .ViewMaxXMargin | .ViewMinYMargin
        removeButton.image = SBIconImage(SBCloseIconImage(), .Left, removeRect.size)
        removeButton.action = "remove"
        return removeButton
    }()
    
    private lazy var editButton: SBButton = {
        let editRect = self.editButtonRect(nil)
        let editButton = SBButton(frame: editRect)
        editButton.autoresizingMask = .ViewMaxXMargin | .ViewMinYMargin
        editButton.image = SBIconImageWithName("Edit", .Center, editRect.size)
        editButton.action = "edit"
        return editButton
    }()
    
    private lazy var updateButton: SBButton = {
        let updateRect = self.updateButtonRect(nil)
        let updateButton = SBButton(frame: updateRect)
        updateButton.autoresizingMask = .ViewMaxXMargin | .ViewMinYMargin
        updateButton.image = SBIconImageWithName("Update", .Right, updateRect.size) // !!! editRect.size?
        updateButton.action = "update"
        return updateButton
    }()
    
    init(frame: NSRect, wrapperView: SBBookmarksView) {
        self.wrapperView = wrapperView
        super.init(frame: frame)
        registerForDraggedTypes([SBBookmarkPboardType, NSURLPboardType, NSFilenamesPboardType])
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        toolsTimer = nil
        searchAnimations = nil
    }
    
    // MARK: Responder

    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        needsDisplaySelectedItemViews()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        needsDisplaySelectedItemViews()
        return true
    }
    
    override var flipped: Bool {
        return true
    }
    
    // MARK: Getter
    
    func splitWidth(proposedWidth: CGFloat) -> CGFloat {
        var width = proposedWidth
        if mode == .Tile {
            #if true
                let scrollerWidth: CGFloat = 0
            #else
                let scrollerWidth: CGFloat = enclosingScrollView.bounds.size.width - self.width
            #endif
            let x = trunc((proposedWidth - scrollerWidth) / cellSize.width)
            width = cellSize.width * x + scrollerWidth
            width += 2 // plus 1 for fitting
        }
        return width
    }
    
    var width: CGFloat {
        if let scrollView = enclosingScrollView {
            let documentRect = scrollView.documentView.frame
            let documentVisibleRect = scrollView.documentVisibleRect
            return documentRect.size.height > documentVisibleRect.size.height ? scrollView.contentSize.width : scrollView.frame.size.width
        }
        return 0.0
    }
    
    var minimumHeight: CGFloat {
        return enclosingScrollView?.contentSize.height ?? 0
    }
    
    var spacing: NSPoint {
        var s = NSZeroPoint
        s.x = (width - _block.x * cellSize.width) / (_block.x + 1)
        return s
    }
    
    var block: NSPoint {
        var block = NSZeroPoint
        let count = items.count
        block.x = trunc(width / cellSize.width)
        if block.x == 0 { block.x = 1 }
        block.y = trunc(CGFloat(items.count) / trunc(block.x)) + CGFloat(SBRemainderIsZero(count, Int(block.x)) ? 0 : 1)
        if block.y == 0 { block.y = 1 }
        return block
    }
    
    func itemRectAtIndex(index: Int) -> NSRect {
        var r = NSZeroRect
        var pos = NSZeroPoint
        r.size = cellSize
        let spacing = mode == .Icon ? self.spacing : NSZeroPoint
        pos.y = trunc(CGFloat(index) / trunc(_block.x))
        pos.x = CGFloat(SBRemainder(index, Int(_block.x)))
        r.origin.x = pos.x * cellSize.width + spacing.x * pos.x
        r.origin.y = pos.y * cellSize.height
        return r
    }
    
    func itemViewAtPoint(point: NSPoint) -> SBBookmarkListItemView? {
        var view: SBBookmarkListItemView?
        #if true
            var index: Int!
            let count = items.count
            var loc = NSZeroPoint
            var location: CGFloat!
            switch mode {
                case .Icon, .Tile:
                    loc.y = trunc(point.y / cellSize.height)
                    location = point.x / (cellSize.width + spacing.x)
                    loc.x = trunc(location)
                    index = Int(_block.x * loc.y + loc.x)
                    if index > count {
                        loc.x = CGFloat(count) - _block.x * loc.y
                        index = Int(_block.x * loc.y + loc.x)
                    }
                case .List:
                    loc.y = trunc(point.y / 22.0)
                    location = point.y - loc.y * 22.0
                    if location > 22.0 / 2 {
                        loc.y += 1
                    }
                    index = Int(loc.y)
            }
            view = itemViews[index!]
        #else
            for itemView in itemViews {
                let r = itemView.frame
                if itemView.hitToPoint(NSMakePoint(point.x - r.origin.x, r.size.height - (point.y - r.origin.y))) {
                    view = itemView
                    break
                }
            }
        #endif
        return view
    }
    
    func indexAtPoint(point: NSPoint) -> Int {
        var index: Int!
        let count = items.count
        var loc = NSZeroPoint
        var location: CGFloat!
        switch mode {
            case .Icon, .Tile:
                loc.y = trunc(point.y / cellSize.height)
                location = point.x / (cellSize.width + spacing.x)
                loc.x = trunc(location)
                if location - trunc(location) > 0.5 {
                    loc.x += 1
                }
                index = Int(_block.x * loc.y + loc.x)
                if index > count {
                    loc.x = CGFloat(count) - _block.x * loc.y
                    index = Int(_block.x * loc.y + loc.x)
                }
            case .List:
                loc.y = trunc(point.y / 22.0)
                location = point.y - loc.y * 22.0
                if location > 22.0 / 2 {
                    loc.y += 1
                }
                index = Int(loc.y)
        }
        return index
    }
    
    var selectedIndexes: NSIndexSet {
        let indexes = NSMutableIndexSet()
        for (index, itemView) in enumerate(itemViews) {
            if itemView.selected {
                indexes.addIndex(index)
            }
        }
        return indexes.copy() as NSIndexSet
    }
    
    func draggingLineRectAtPoint(point: NSPoint) -> NSRect {
        var r = NSZeroRect
        let count = CGFloat(items.count)
        var loc = NSZeroPoint
        var location: CGFloat!
        switch mode {
            case .Icon, .Tile:
                loc.y = trunc(point.y / cellSize.height)
                location = point.x / (cellSize.width + spacing.x)
                loc.x = trunc(location)
                if location - trunc(location) > 0.5 {
                    loc.x += 1
                }
                let index = _block.x * loc.y + loc.x
                if index > count {
                    loc.x = count - _block.x * loc.y
                }
                r.size.width = 5.0
                r.size.height = cellSize.height
                let spacingX = loc.x > 0 ? (loc.x * spacing.x - spacing.x / 2) : 0
                r.origin.x = loc.x * cellSize.width - r.size.width / 2 + spacingX
                r.origin.y = loc.y * cellSize.height
            case .List:
                loc.y = trunc(point.y / 22.0)
                location = point.y - loc.y * 22.0
                if location > 22.0 / 2 {
                    loc.y += 1
                }
                r.size.width = cellSize.width
                r.size.height = 5.0
                r.origin.y = loc.y * 22.0 - r.size.height / 2
        }
        return r
    }
    
    func removeButtonRect(itemView: SBBookmarkListItemView?) -> NSRect {
        var r = NSZeroRect
        r.size.width = 24.0
        r.size.height = r.size.width
        itemView !! { r.origin = $0.frame.origin }
        return r
    }
    
    func editButtonRect(itemView: SBBookmarkListItemView?) -> NSRect {
        var r = NSZeroRect
        let removeButtonRect = self.removeButtonRect(itemView)
        r.size.width = 24.0
        r.size.height = r.size.width
        itemView !! { r.origin = $0.frame.origin }
        r.origin.x = NSMaxX(removeButtonRect)
        return r
    }
    
    func updateButtonRect(itemView: SBBookmarkListItemView?) -> NSRect {
        var r = NSZeroRect
        let editButtonRect = self.editButtonRect(itemView)
        r.size.width = 24.0
        r.size.height = r.size.width
        itemView !! { r.origin = $0.frame.origin }
        r.origin.x = NSMaxX(editButtonRect)
        return r
    }
    
    var items: [NSMutableDictionary] {
        return SBBookmarks.sharedBookmarks.items
    }
    
    var selectedItems: [NSDictionary]? {
        var ditems = itemViews.filter({ $0.selected }).map({ $0.item })
        return !ditems.isEmpty ? ditems : nil
    }
    
    var canScrollToNext: Bool {
        return NSMaxY(visibleRect) < NSMaxY(bounds)
    }
    
    var canScrollToPrevious: Bool {
        return visibleRect.origin.y > 0
    }
    
    // MARK: Setter
    
    func setCellSizeForMode(mode: SBBookmarkMode) {
        switch mode {
            case .Icon:
                cellSize = NSMakeSize(cellWidth, cellWidth)
            case .List:
                cellSize = NSMakeSize(width, 22.0)
            case .Tile:
                cellSize = NSMakeSize(cellWidth / kSBBookmarkFactorForImageHeight * kSBBookmarkFactorForImageWidth, cellWidth)
        }
    }
    
    // MARK: Actions
    
    func addForItem(item: NSDictionary) {
        let index = items.count - 1 //count > 0 ? count - 1 : 0
        layoutFrame()
        addItemViewAtIndex(index, item: item)
    }
    
    func addForItems(items: [NSDictionary], toIndex: Int) {
        layoutFrame()
        addItemViewsToIndex(toIndex, items: items)
    }
    
    func createItemViews() {
        layoutFrame()
        itemViews.removeAll()
        for (index, item) in enumerate(items) {
            addItemViewAtIndex(index, item: item)
        }
    }
    
    func addItemViewAtIndex(index: Int, item: NSDictionary) {
        let r = itemRectAtIndex(index)
        let itemView = SBBookmarkListItemView(frame: r, item: item)
        itemView.target = self
        itemView.mode = mode
        itemViews.insert(itemView, atIndex: index)
        addSubview(itemView)
    }
    
    func addItemViewsToIndex(toIndex: Int, items: [NSDictionary]) {
        for (index, item) in enumerate(items) {
            addItemViewAtIndex(index + toIndex, item: item)
        }
        layoutItemViewsWithAnimationFromIndex(0)
    }
    
    func moveItemViewsAtIndexes(indexes: NSIndexSet, toIndex: Int) {
        let views = itemViews.objectsAtIndexes(indexes)
        if !views.isEmpty && toIndex <= itemViews.count {
            if itemViews.containsIndexes(indexes) {
                var to = toIndex
                var offset = 0
                for var i = indexes.lastIndex; i != NSNotFound; i = indexes.indexLessThanIndex(i) {
                    if i < to {
                        offset++
                    }
                }
                to -= offset
                itemViews.removeObjectsAtIndexes(indexes)
                itemViews.insertItems(views, atIndexes: NSIndexSet(indexesInRange: NSMakeRange(to, indexes.count)))
            }
        }
    }
    
    func removeItemView(itemView: SBBookmarkListItemView) {
        itemView.removeFromSuperview()
        removeItemViewsAtIndexes(NSIndexSet(index: indexOfItem(itemViews, itemView)!))
    }
    
    func removeItemViewsAtIndexes(indexes: NSIndexSet) {
        let bookmarks = SBBookmarks.sharedBookmarks
        if itemViews.containsIndexes(indexes) && bookmarks.items.containsIndexes(indexes) {
            itemViews.removeObjectsAtIndexes(indexes)
            bookmarks.removeItemsAtIndexes(indexes)
            layout(0)
        }
        layoutToolsHidden()
    }
    
    func editItemView(itemView: SBBookmarkListItemView) {
        editItemViewsAtIndex(indexOfItem(itemViews, itemView)!)
    }
    
    func editItemViewsAtIndex(index: Int) {
        wrapperView.executeShouldEditItemAtIndex(index)
    }
    
    func openItemsAtIndexes(indexes: NSIndexSet) {
        SBBookmarks.sharedBookmarks.doubleClickItemsAtIndexes(indexes)
    }
    
    func selectPoint(point: NSPoint, toPoint: NSPoint, exclusive: Bool) {
        if selectionView != nil {
            let r = NSUnionRect(NSMakeRect(toPoint.x, toPoint.y, 1.0, 1.0), NSMakeRect(point.x, point.y, 1.0, 1.0))
            for itemView in itemViews {
                let intersectionRect = NSIntersectionRect(r, itemView.frame)
                if intersectionRect == NSZeroRect {
                    if exclusive {
                        itemView.selected = false
                    }
                } else {
                    var intersectionRectInView = intersectionRect
                    intersectionRectInView.origin.x = intersectionRect.origin.x - itemView.frame.origin.x
                    intersectionRectInView.origin.y = intersectionRect.origin.y - itemView.frame.origin.y
                    intersectionRectInView.origin.y = itemView.frame.size.height - NSMaxY(intersectionRectInView)
                    itemView.selected = itemView.hitToRect(intersectionRectInView)
                }
            }
        }
    }
    
    func layout(animationTime: NSTimeInterval) {
        animationIndex = NSNotFound
        layoutFrame()
        if animationTime > 0 {
            layoutItemViewsWithAnimationFromIndex(0, duration: animationTime)
        } else {
            layoutItemViews()
        }
    }
    
    func layoutFrame() {
        var r = frame
        let size = NSMakeSize(width, minimumHeight)
        _block = block
        r.size.width = size.width
        r.size.height = _block.y * cellSize.height
        SBConstrain(&r.size.height, min: size.height)
        frame = r
    }
    
    func layoutItemViews() {
        if mode == .List {
            cellSize.width = width
        }
        for (index, itemView) in enumerate(itemViews) {
            itemView.mode = mode
            itemView.frame = itemRectAtIndex(index)
            itemView.needsDisplay = true
        }
    }
    
    func layoutItemViewsWithAnimationFromIndex(fromIndex: Int, duration: NSTimeInterval = 0.25) {
        var animations: [[NSObject: AnyObject]] = []
        let count = itemViews.count
        for i in fromIndex..<count {
            let index = i + fromIndex
            let itemView = itemViews[index]
            itemView.mode = mode
            let r = itemRectAtIndex(index)
            if NSIntersectsRect(visibleRect, itemView.frame) || NSIntersectsRect(visibleRect, r) {  // Only visible views
                animations.append([
                    NSViewAnimationTargetKey: itemView,
                    NSViewAnimationStartFrameKey: NSValue(rect: itemView.frame),
                    NSViewAnimationEndFrameKey: NSValue(rect: r)])
            } else {
                itemView.frame = r
            }
        }
        if !animations.isEmpty {
            let animation = NSViewAnimation(viewAnimations: animations)
            animation.duration = duration
            animation.delegate = self
            animation.startAnimation()
        }
    }
    
    func layoutSelectionView(point: NSPoint) {
        if selectionView == nil {
            selectionView = SBView(frame: NSZeroRect)
            selectionView!.frameColor = NSColor.alternateSelectedControlColor()
            addSubview(selectionView!)
        }
        let r = NSUnionRect(NSMakeRect(self.point.x, self.point.y, 1.0, 1.0), NSMakeRect(point.x, point.y, 1.0, 1.0))
        selectionView!.frame = r
    }
    
    func layoutToolsForItem(itemView: SBBookmarkListItemView) {
        if toolsItemView !== itemView {
            toolsItemView = itemView
            toolsTimer = NSTimer.scheduledTimerWithTimeInterval(kSBBookmarkToolsInterval, target: self, selector: "layoutTools", userInfo: nil, repeats: false)
        }
    }
    
    func layoutTools() {
        toolsTimer = nil
        if toolsItemView != nil {
            removeButton.frame = removeButtonRect(toolsItemView)
            editButton.frame = editButtonRect(toolsItemView)
            updateButton.frame = updateButtonRect(toolsItemView)
            removeButton.target = toolsItemView
            editButton.target = toolsItemView
            updateButton.target = toolsItemView
            addSubview(removeButton)
            addSubview(editButton)
            addSubview(updateButton)
            toolsItemView!.needsDisplay = true
        }
    }
    
    func layoutToolsHidden() {
        removeButton.target = nil
        editButton.target = nil
        updateButton.target = nil
        removeButton.removeFromSuperview()
        editButton.removeFromSuperview()
        updateButton.removeFromSuperview()
        toolsItemView = nil
    }
    
    func layoutDraggingLineView(point: NSPoint) {
        if draggingLineView == nil {
            draggingLineView = SBView(frame: NSZeroRect)
            draggingLineView!.frameColor = NSColor.alternateSelectedControlColor()
            addSubview(draggingLineView!)
        }
        let r = draggingLineRectAtPoint(point)
        draggingLineView!.frame = r
    }
    
    func updateItems() {
        var index = itemViews.count - 1
        var shouldLayout = false
        for itemView in reverse(itemViews) {
            if let item = items.get(index) {
                itemView.item = item
                itemView.needsDisplay = true
            } else {
                shouldLayout = true
                itemView.removeFromSuperview()
            }
            if itemView.selected {
                itemView.selected = false
                itemView.needsDisplay = true
            }
            index--
        }
        if shouldLayout {
            layoutFrame()
        }
    }
    
    func scrollToNext() {
        var r = visibleRect
        if NSMaxY(visibleRect) + visibleRect.size.height < bounds.size.height {
            r.origin.y = NSMaxY(visibleRect)
        } else {
            r.origin.y = bounds.size.height - visibleRect.size.height
        }
        scrollRectToVisible(r)
    }
    
    func scrollToPrevious() {
        var r = visibleRect
        if visibleRect.origin.y - visibleRect.size.height > 0 {
            r.origin.y = visibleRect.origin.y - visibleRect.size.height
        } else {
            r.origin.y = 0
        }
        scrollRectToVisible(r)
    }
    
    func needsDisplaySelectedItemViews() {
        itemViews.filter({ $0.selected }).map({ $0.needsDisplay = true })
    }
    
    func executeShouldOpenSearchbar() {
        animationIndex = NSNotFound
        delegate?.bookmarkListViewShouldOpenSearchbar?(self)
    }
    
    func executeShouldCloseSearchbar() -> Bool {
        animationIndex = NSNotFound
        return delegate?.bookmarkListViewShouldCloseSearchbar?(self) ?? false
    }
    
    func searchWithText(text: String) {
        if !text.isEmpty {
            let indexes = NSMutableIndexSet()
            
            // Search in bookmarks
            for (index, bookmarkItem) in enumerate(items) {
                let title = bookmarkItem[kSBBookmarkTitle] as NSString
                let URLString = bookmarkItem[kSBBookmarkURL] as NSString
                let schemelessURLString = URLString.stringByDeletingScheme!
                var range = title.rangeOfString(text, options: .CaseInsensitiveSearch)
                if range.location == NSNotFound {
                    range = URLString.rangeOfString(text)
                }
                if range.location == NSNotFound {
                    range = schemelessURLString.rangeOfString(text)
                }
                if range.location != NSNotFound {
                    indexes.addIndex(index)
                }
            }
            if indexes.count > 0 {
                showIndexes(indexes.copy() as NSIndexSet)
            } else {
                NSBeep()
            }
        }
    }
    
    func showIndexes(indexes: NSIndexSet) {
        var infos: [[NSObject: AnyObject]] = []
        var firstIndex = NSNotFound
        if animationIndex == indexes.lastIndex || !indexes.containsIndex(animationIndex) {
            animationIndex = NSNotFound
        }
        for var index = indexes.firstIndex; index != NSNotFound; index = indexes.indexGreaterThanIndex(index) {
            let itemView = itemViews[index]
            if firstIndex == NSNotFound && (animationIndex == NSNotFound || animationIndex < index) {
                // Get first index
                firstIndex = index
                
                // Add animation
                let endRect = itemRectAtIndex(firstIndex)
                var startRect = endRect
                switch mode {
                    case .Icon, .Tile:
                        startRect.size.width *= 1.5
                        startRect.size.height *= 1.5
                    case .List:
                        startRect.size.width *= 1.2
                        startRect.size.height *= 2.0
                }
                startRect.origin.x -= (startRect.size.width - endRect.size.width) / 2
                startRect.origin.y -= (startRect.size.height - endRect.size.height) / 2
                let info = [NSViewAnimationTargetKey: itemView,
                            NSViewAnimationStartFrameKey: NSValue(rect: startRect),
                            NSViewAnimationEndFrameKey: NSValue(rect: endRect)]
                infos.append(info)
                
                // Put to top level
                itemView.superview!.addSubview(itemView)
                
                // Scroll to item as top
                scrollPoint(endRect.origin)
                animationIndex = index
                break
            }
        }
        if !infos.isEmpty {
            SBDispatch {
                self.startAnimations(infos)
            }
        }
    }
    
    func startAnimations(infos: [[NSObject: AnyObject]]) {
        searchAnimations = NSViewAnimation(viewAnimations: infos)
        searchAnimations!.duration = 0.25
        searchAnimations!.animationCurve = .EaseIn
        searchAnimations!.delegate = self
        searchAnimations!.startAnimation()
    }
    
    func animationDidEnd(animation: NSAnimation) {
        if animation === searchAnimations {
        }
    }
    
    // MARK: Menu Actions
    
    func delete(sender: AnyObject?) {
        let indexes = NSMutableIndexSet()
        for (index, itemView) in enumerate(itemViews) {
            if itemView.selected {
                itemView.removeFromSuperview()
                indexes.addIndex(index)
            }
        }
        removeItemViewsAtIndexes(indexes.copy() as NSIndexSet)
    }
    
    override func selectAll(sender: AnyObject?) {
        itemViews.filter({ !$0.selected }).map({ $0.selected = true })
    }
    
    func openSelectedItems(sender: AnyObject?) {
        let indexes = NSMutableIndexSet()
        for (index, itemView) in enumerate(itemViews) {
            if itemView.selected {
                indexes.addIndex(index)
            }
        }
        openItemsAtIndexes(indexes.copy() as NSIndexSet)
    }
    
    // MARK: Event
    
    override func mouseDown(event: NSEvent) {
        if event.clickCount == 2 {
        } else {
            let location = event.locationInWindow
            let modifierFlags = event.modifierFlags
            var selectedViews: [SBBookmarkListItemView] = []
            var alreadySelect = false
            var selection = false
            point = convertPoint(location, fromView: nil)
            for (index, itemView) in enumerate(itemViews) {
                let r = itemRectAtIndex(index)
                if itemView.hitToPoint(NSMakePoint(point.x - r.origin.x, r.size.height - (point.y - r.origin.y))) {
                    selection = true
                    alreadySelect = itemView.selected
                    itemView.selected = true
                } else {
                    if itemView.selected {
                        selectedViews.append(itemView)
                    }
                }
            }
            if !alreadySelect && (modifierFlags & .CommandKeyMask == nil) && (modifierFlags & .ShiftKeyMask == nil) {
                selectedViews.map { $0.selected = false }
            }
            if selection {
                point = NSZeroPoint
            }
        }
        draggedItemView?.dragged = false
        draggedItemView = nil
        draggedItems = nil
        selectionView = nil
        draggingLineView = nil
    }
    
    override func mouseDragged(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        let modifierFlags = event.modifierFlags
        let exclusive = modifierFlags & .ShiftKeyMask == nil
        if self.point == NSZeroPoint {
            // Drag
            if (draggedItemView !! draggedItems) != nil {
                let image = NSImage(view: draggedItemView!)!
                let dragLocation = NSMakePoint(point.x + offset.width, point.y + (draggedItemView!.frame.size.height - offset.height))
                let pasteboard = NSPasteboard(name: NSDragPboard)
                let title = draggedItemView!.item[kSBBookmarkTitle] as NSString
                let imageData = draggedItemView!.item[kSBBookmarkImage] as NSData
                let URLString = draggedItemView!.item[kSBBookmarkURL] as NSString
                let URL = URLString !! {NSURL(string: $0)}
                pasteboard.declareTypes([SBBookmarkPboardType, NSURLPboardType], owner: nil)
                draggedItems !! { pasteboard.setPropertyList($0, forType: SBBookmarkPboardType) }
                URL?.writeToPasteboard(pasteboard)
                title !! { pasteboard.setString($0, forType: NSStringPboardType) }
                imageData !! { pasteboard.setData($0, forType: NSTIFFPboardType) }
                tempDragImage(image, at: dragLocation, offset: NSZeroSize, event: event, pasteboard: pasteboard, source: window!, slideBack: true)
                draggedItemView!.dragged = false
            } else {
                draggedItemView = itemViewAtPoint(point)
                draggedItems = selectedItems
                if (draggedItemView !! draggedItems) != nil {
                    offset = NSMakeSize(draggedItemView!.frame.origin.x - point.x, point.y - draggedItemView!.frame.origin.y)
                    draggedItemView!.dragged = true
                    layoutToolsHidden()
                }
            }
        } else {
            // Selection
            autoscroll(event)
            layoutSelectionView(point)
            selectPoint(point, toPoint: self.point, exclusive: exclusive)
        }
    }
    
    override func mouseUp(event: NSEvent) {
        if event.clickCount == 2 {
            let location = event.locationInWindow
            let point = convertPoint(location, fromView: nil)
            for (index, itemView) in enumerate(itemViews) {
                let r = itemRectAtIndex(index)
                if itemView.hitToPoint(NSMakePoint(point.x - r.origin.x, r.size.height - (point.y - r.origin.y))) {
                    openSelectedItems(nil)
                    break
                }
            }
        }
        draggedItemView?.dragged = false
        draggedItemView = nil
        draggedItems = nil
        selectionView = nil
        draggingLineView = nil
    }
    
    override func mouseEntered(event: NSEvent) {
        layoutToolsHidden()
    }

    override func mouseExited(event: NSEvent) {
        layoutToolsHidden()
    }
    
    override func rightMouseDown(event: NSEvent) {
        mouseDown(event)
        point = NSZeroPoint
        draggedItemView?.dragged = false
        draggedItemView = nil
        draggedItems = nil
        selectionView = nil
        draggingLineView = nil
        if let menu = menuForEvent(event) {
            NSMenu.popUpContextMenu(menu, withEvent: event, forView: self)
        }
    }
    
    override func keyDown(event: NSEvent) {
        let character = Int((event.characters as NSString).characterAtIndex(0))
        switch character {
            case NSDeleteCharacter:
                // Delete
                delete(nil)
            case NSEnterCharacter, NSCarriageReturnCharacter:
                // Open URL
                openSelectedItems(nil)
            case 0x66: // f
                if event.modifierFlags & .CommandKeyMask != nil {
                    // Open searchbar
                    executeShouldOpenSearchbar()
                }
            case 0x1B:
                // Close searchbar
                executeShouldCloseSearchbar()
            default:
                break
        }
    }
    
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        let indexes = selectedIndexes
        if indexes.count > 0 {
            let bookmarks = SBBookmarks.sharedBookmarks
            var representedItems: [NSDictionary] = []
            let menu = NSMenu()
            var title: String = indexes.count == 1 ? NSLocalizedString("Open an item", comment: "") : NSString(format: NSLocalizedString("Open %d items", comment: ""), indexes.count)
            let openItem = NSMenuItem(title: title, action: "openItemsFromMenuItem:", keyEquivalent: "")
            title = indexes.count == 1 ? NSLocalizedString("Remove an item", comment: "") : NSString(format: NSLocalizedString("Remove %d items", comment: ""), indexes.count)
            let removeItem = NSMenuItem(title: title, action: "removeItemsFromMenuItem:", keyEquivalent: "")
            let labelsItem = NSMenuItem(title: NSLocalizedString("Label", comment: ""), action:nil, keyEquivalent: "")
            openItem.target = bookmarks
            removeItem.target = bookmarks
            for var i = indexes.lastIndex; i != NSNotFound; i = indexes.indexLessThanIndex(i) {
                let item = bookmarks.items[i]
                //if item
                representedItems.append(item)
            }
            openItem.representedObject = representedItems
            removeItem.representedObject = indexes
            let labelsMenu = SBBookmarkLabelColorMenu(false, bookmarks, "changeLabelFromMenuItem:", indexes)
            labelsItem.submenu = labelsMenu
            menu.addItem(openItem)
            menu.addItem(removeItem)
            menu.addItem(NSMenuItem.separatorItem())
            menu.addItem(labelsItem)
            return menu
        }
        return nil
    }
    
    // MARK: Dragging DataSource
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }
    
    override func draggingExited(sender: NSDraggingInfo) {
        draggingLineView = nil
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        let point = convertPoint(sender.draggingLocation(), fromView: nil)
        layoutDraggingLineView(point)
        autoscroll(NSApplication.sharedApplication().currentEvent)
        return .Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        let point = convertPoint(sender.draggingLocation(), fromView: nil)
        let types = pasteboard.types as [NSString] as [String]
        
        if containsItem(types, SBBookmarkPboardType) {
            // Sunrise bookmarks
            let pbItems = pasteboard.propertyListForType(SBBookmarkPboardType) as NSArray as [NSDictionary]
            if !pbItems.isEmpty {
                let bookmarks = SBBookmarks.sharedBookmarks
                let indexes = bookmarks.indexesOfItems(pbItems)
                let toIndex = indexAtPoint(point)
                if indexes.count > 0 {
                    // Move item
                    bookmarks.moveItemsAtIndexes(indexes, toIndex: toIndex)
                    moveItemViewsAtIndexes(indexes, toIndex: toIndex)
                } else {
                    // Add as new item
                    bookmarks.addItems(pbItems, toIndex: toIndex)
                    addForItems(pbItems, toIndex: toIndex)
                }
                layoutItemViewsWithAnimationFromIndex(0)
            }
        } else if containsItem(types, SBSafariBookmarkDictionaryListPboardType) {
            // Safari bookmarks
            let pbItems = pasteboard.propertyListForType(SBSafariBookmarkDictionaryListPboardType) as NSArray as [NSDictionary]
            let bookmarkItems = SBBookmarkItemsFromBookmarkDictionaryList(pbItems)
            if !bookmarkItems.isEmpty {
                let bookmarks = SBBookmarks.sharedBookmarks
                let toIndex = indexAtPoint(point)
                bookmarks.addItems(bookmarkItems, toIndex: toIndex)
                addForItems(bookmarkItems, toIndex: toIndex)
                layoutItemViewsWithAnimationFromIndex(0)
            }
        } else if containsItem(types, NSURLPboardType) {
            // General URL
            if let URL = NSURL(fromPasteboard: pasteboard).absoluteString {
                var title: String!
                var data: NSData?
                if containsItem(types, NSStringPboardType) {
                    title = pasteboard.stringForType(NSStringPboardType)
                } else {
                    title = NSLocalizedString("Untitled", comment: "")
                }
                if containsItem(types, NSTIFFPboardType) {
                    var shouldInset = true
                    data = pasteboard.dataForType(NSTIFFPboardType)
                    if let image = NSImage(data: data) {
                        shouldInset = image.size != SBBookmarkImageMaxSize
                    }
                    if shouldInset {
                        if let insetImage = NSImage(data: data)?.inset(size: SBBookmarkImageMaxSize, intersectRect: NSZeroRect, offset: NSZeroPoint) {
                            insetImage.bitmapImageRep !! { data = $0.data }
                        }
                    }
                } else {
                    data = SBEmptyBookmarkImageData
                }
                
                let bookmarks = SBBookmarks.sharedBookmarks
                let item = SBCreateBookmarkItem(title, URL, data, NSDate(), nil, NSStringFromPoint(NSZeroPoint))
                let fromIndex = bookmarks.containsItem(item)
                let toIndex = indexAtPoint(point)
                var bookmarkItems: [BookmarkItem] = []
                if fromIndex != NSNotFound {
                    // Move item
                    bookmarks.moveItemsAtIndexes(NSIndexSet(index: fromIndex), toIndex: toIndex)
                    moveItemViewsAtIndexes(NSIndexSet(index: fromIndex), toIndex: toIndex)
                    layoutItemViewsWithAnimationFromIndex(0)
                } else {
                    // Add as new item
                    if toIndex != NSNotFound {
                        bookmarkItems.append(item)
                        bookmarks.addItems(bookmarkItems, toIndex: toIndex)
                        addForItems(bookmarkItems, toIndex: toIndex)
                    }
                }
            }
        }
        draggingLineView = nil
        return true
    }
    
    // MARK: Drawing
    
    /*override func drawRect(rect: NSRect) {
        super.drawRect(rect)
    }*/
    
    // MARK: Gesture
    
    override var acceptsTouchEvents: Bool {
        get { return true }
        set(acceptsTouchEvents) {}
    }
    
    override func swipeWithEvent(event: NSEvent) {
        let deltaX = event.deltaX
        if deltaX > 0 { // Left
            if canScrollToPrevious {
                scrollToPrevious()
            } else {
                NSBeep()
            }
        } else if deltaX < 0 { // Right
            if canScrollToNext {
                scrollToNext()
            } else {
                NSBeep()
            }
        }
    }
}