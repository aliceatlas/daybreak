/*

SBSplitView.h
 
Authoring by Atsushi Jike

Copyright 2010 Atsushi Jike. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SBDefinitions.h"
#import "SBSidebar.h"

@interface SBSplitView : NSSplitView <SBSidebarDelegate>
{
	NSView *view;
	SBSidebar *sidebar;
	SBSidebarPosition sidebarPosition;
	NSViewAnimation *_divideAnimation;
	CGFloat sidebarWidth;
	CGFloat dividerThickness;
	BOOL animating;
}
@property (nonatomic, retain) NSView *view;
@property (nonatomic, retain) SBSidebar *sidebar;
@property (nonatomic) SBSidebarPosition sidebarPosition;
@property (nonatomic) NSRect frame;
@property (nonatomic, readonly) BOOL visibleSidebar;
@property (nonatomic) BOOL animating;
@property (nonatomic) CGFloat sidebarWidth;

// Rects
- (NSRect)viewRect;
- (NSRect)sidebarRect;
// Setter
- (void)setFrame:(NSRect)frame;
- (void)setView:(NSView *)aView;
- (void)setSidebar:(SBSidebar *)aSidebar;
// Destruction
- (void)destructDividerAnimation;
// Actions
- (void)openSidebar:(id)sender;
- (void)closeSidebar:(id)sender;
- (void)switchView:(SBSidebarPosition)position;
- (void)takeSidebarIfNeeded;
- (void)takeSidebar;
- (void)returnSidebarIfNeeded;
- (void)returnSidebar;

@end