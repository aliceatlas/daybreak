/*
SBPopUpButton.swift

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

import Cocoa

class SBPopUpButton: NSPopUpButton {
    var backgroundImage: NSImage?
    var operation: ((NSMenuItem) -> Void)?
    override var menu: NSMenu? {
        get { return super.menu }
        set(inMenu) {
            super.menu = inMenu
            if inMenu != nil {
                for item in inMenu!.itemArray as [NSMenuItem] {
                    item.target = self
                    item.action = "executeAction:"
                }
            }
        }
    }
    
    override class func initialize() {
        SBPopUpButton.setCellClass(SBPopUpButtonCell.self)
    }
    
    override class func cellClass() -> AnyClass! { return SBPopUpButtonCell.self }
    
    // MARK: Actions
    
    func executeAction(sender: AnyObject) {
        if let item = sender as? NSMenuItem {
            self.selectItemWithRepresentedObject(item.representedObject?)
            self.setNeedsDisplayInRect(self.bounds)
            if let item = sender as? NSMenuItem {
                self.operation?(item)
            }
        }
    }
    
    func selectItemWithRepresentedObject(representedObject: AnyObject?) {
        if let menu = self.menu {
            menu.selectItemWithRepresentedObject(representedObject)
            self.setNeedsDisplayInRect(self.bounds)
        }
    }
    
    func deselectItem() {
        if let menu = self.menu {
            menu.deselectItem()
            self.setNeedsDisplayInRect(self.bounds)
        }
    }
}

class SBPopUpButtonCell: NSPopUpButtonCell {
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        let view = controlView as SBPopUpButton
        if let image = view.backgroundImage {
            NSGraphicsContext.saveGraphicsState()
            let transform = NSAffineTransform()
            transform.translateXBy(0.0, yBy: view.bounds.size.height)
            transform.scaleXBy(1.0, yBy:-1.0)
            transform.concat()
            image.drawInRect(view.bounds, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
        }
        if let menu = view.menu {
            if let item = menu.selectedItem {
                if let itemTitle: NSString = item.title {
                    if itemTitle.length > 0 {
                        var r = view.bounds
                        let padding: CGFloat = 10.0
                        let shadow = NSShadow()
                        shadow.shadowOffset = NSMakeSize(0.0, -1.0)
                        shadow.shadowColor = NSColor.whiteColor()
                        let style = NSMutableParagraphStyle()
                        style.lineBreakMode = .ByTruncatingTail
                        let attributes = [NSFontAttributeName:            NSFont.boldSystemFontOfSize(11.0),
                                          NSForegroundColorAttributeName: NSColor.blackColor(),
                                          NSShadowAttributeName:          shadow,
                                          NSParagraphStyleAttributeName:  style]
                        r.size = itemTitle.sizeWithAttributes(attributes)
                        r.size.width = min(r.size.width, view.bounds.size.width - padding * 2)
                        r.origin.x = padding
                        r.origin.y = (view.bounds.size.height - r.size.height) / 2
                        itemTitle.drawInRect(r, withAttributes: attributes)
                    }
                }
            }
        }
    }
}

/*
@implementation SBPopUpButton

@synthesize menu;

- (void)dealloc
{
    [menu release];
    [super dealloc];
}

#pragma mark Setter

- (void)setMenu:(NSMenu *)inMenu
{
    if (menu != inMenu)
    {
        [inMenu retain];
        [menu release];
        menu = inMenu;
        for (NSMenuItem *item in [menu itemArray])
        {
            [item setTarget:self];
            [item setAction:@selector(executeAction:)];
        }
    }
}

#pragma mark NSCoding Protocol

- (id)initWithCoder:(NSCoder *)decoder
{
    [super initWithCoder:decoder];
    if ([decoder allowsKeyedCoding])
    {
        if ([decoder containsValueForKey:@"menu"])
        {
            self.menu = [decoder decodeObjectForKey:@"menu"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    if (menu)
        [coder encodeObject:menu forKey:@"menu"];
}

#pragma mark Actions

- (void)executeAction:(id)sender
{
    [self selectItemWithRepresentedObject:[sender representedObject]];
    [self setNeedsDisplayInRect:self.bounds];
    if (target && action)
    {
        if ([target respondsToSelector:action])
        {
            [target performSelector:action withObject:sender];
        }
    }
}

- (void)selectItemWithRepresentedObject:(id)representedObject
{
    if (menu)
    {
        [menu selectItemWithRepresentedObject:representedObject];
        [self setNeedsDisplayInRect:self.bounds];
    }
}

- (void)deselectItem
{
    if (menu)
    {
        [menu deselectItem];
        [self setNeedsDisplayInRect:self.bounds];
    }
}

- (void)showMenu:(NSEvent *)theEvent
{
    if (menu)
    {
        NSPoint location = [theEvent locationInWindow];
        NSPoint point = [self convertPoint:location fromView:nil];
        NSPoint newLocation = NSMakePoint(location.x - point.x, location.y - point.y);
        NSEvent *event = [NSEvent mouseEventWithType:[theEvent type] location:newLocation modifierFlags:[theEvent modifierFlags] timestamp:[theEvent timestamp] windowNumber:[theEvent windowNumber] context:[theEvent context] eventNumber:[theEvent eventNumber] clickCount:[theEvent clickCount] pressure:[theEvent pressure]];
        [NSMenu popUpContextMenu:menu withEvent:event forView:self];
    }
}

#pragma mark Event

- (void)mouseDragged:(NSEvent *)theEvent
{
    
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (enabled)
    {
        NSPoint location = [theEvent locationInWindow];
        NSPoint point = [self convertPoint:location fromView:nil];
        if (NSPointInRect(point, self.bounds))
        {
            self.pressed = NO;
            [self showMenu:theEvent];
        }
    }
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if (menu)
    {
        NSMenuItem *item = [menu selectedItem];
        NSString *itemTitle = [item title];
        if ([itemTitle length] > 0)
        {
            NSRect r = self.bounds;
            NSDictionary *attributes = nil;
            NSShadow *shadow = nil;
            NSMutableParagraphStyle *style = nil;
            CGFloat padding = 10.0;
            shadow = [[NSShadow alloc] init];
            [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
            [shadow setShadowColor:[NSColor whiteColor]];
            style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:NSLineBreakByTruncatingTail];
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSFont boldSystemFontOfSize:11.0], NSFontAttributeName, 
                          [NSColor blackColor], NSForegroundColorAttributeName, 
                          shadow, NSShadowAttributeName, 
                          style, NSParagraphStyleAttributeName, nil];
            r.size = [itemTitle sizeWithAttributes:attributes];
            if (r.size.width > (self.bounds.size.width - padding * 2))
                r.size.width = (self.bounds.size.width - padding * 2);
            r.origin.x = padding;
            r.origin.y = (self.bounds.size.height - r.size.height) / 2;
            [itemTitle drawInRect:r withAttributes:attributes];
            [shadow release];
            [style release];
        }
    }
}

@end
 */


/*
@interface SBPopUpButton : SBButton <NSCoding>
{
    NSMenu *menu;
}
@property (retain) NSMenu *menu;

// Setter
- (void)setMenu:(NSMenu *)inMenu;
// Actions
- (void)executeAction:(id)sender;
- (void)selectItemWithRepresentedObject:(id)representedObject;
- (void)deselectItem;
- (void)showMenu:(NSEvent *)theEvent;

@end
*/