/*

SBTabViewItem.h
 
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
#import "SBBLKGUI.h"
#import "SBSourceTextView.h"
#import "SBWebResourceIdentifier.h"
#import "SBWebView.h"

@class SBDrawer;
@class SBFixedSplitView;
@class SBTabbarItem;
@class SBTabSplitView;
@class SBTabView;
@class SBWebView;
@class SBSourceTextView;
@interface SBTabViewItem : NSTabViewItem <NSSplitViewDelegate>
{
	SBTabbarItem *tabbarItem;
	NSURL *URL;
	SBTabSplitView *splitView;
	SBDrawer *sourceView;
	SBWebView *webView;
	SBSourceTextView *sourceTextView;
	SBFixedSplitView *webSplitView;
	SBFixedSplitView *sourceSplitView;
	SBBLKGUIButton *sourceSaveButton;
	SBBLKGUIButton *sourceCloseButton;
	NSMutableArray *resourceIdentifiers;
	BOOL showSource;
}
@property (nonatomic, assign) NSView *view;
@property (nonatomic, retain) SBTabSplitView *splitView;
@property (nonatomic, assign) SBTabbarItem *tabbarItem;
@property (nonatomic, readonly) SBTabView *tabView;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) SBWebView *webView;
@property (nonatomic, retain) NSMutableArray *resourceIdentifiers;
@property (nonatomic) BOOL showSource;
@property (nonatomic) BOOL selected;
@property (nonatomic, readonly) BOOL canBackward;
@property (nonatomic, readonly) BOOL canForward;
@property (nonatomic, readonly) NSString *mainFrameURLString;
@property (nonatomic, readonly) NSString *pageTitle;
@property (nonatomic, readonly) NSString *requestURLString;
@property (nonatomic, readonly) NSString *documentSource;

// Getter
- (CGFloat)sourceBottomMargin;
- (NSString *)URLString;
- (NSMutableArray *)webFramesInFrame:(WebFrame *)frame;
// Setter
- (void)setURL:(NSURL *)inURL;
- (void)setURLString:(NSString *)URLString;
- (void)toggleShowSource;
- (void)hideShowSource;
- (void)setShowSource:(BOOL)inShowSource;
- (BOOL)setShowFindbarInWebView:(BOOL)showFindbar;
- (void)setShowFindbarInSource:(BOOL)showFindbar;
- (void)hideFinderbarInWebView;
- (void)hideFinderbarInSource;
// Destruction
- (void)destructWebView;
// Construction
- (void)constructSplitView;
- (void)constructWebView;
- (void)setUserAgent;
// Actions
- (BOOL)addResourceIdentifier:(SBWebResourceIdentifier *)identifier;
- (void)removeAllResourceIdentifiers;
- (void)backward:(id)sender;
- (void)forward:(id)sender;
- (void)openDocumentSource:(id)sender;
- (void)saveDocumentSource:(id)sender;
- (void)removeFromTabView;
- (void)serverCertificateUntrustedSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)showErrorPageWithTitle:(NSString *)title urlString:(NSString *)urlString frame:(WebFrame *)frame;
// Menu Actions
- (void)searchStringFromMenu:(NSMenuItem *)menuItem;
- (void)searchStringInNewTabFromMenu:(NSMenuItem *)menuItem;
- (void)openURLInApplicationFromMenu:(NSMenuItem *)menuItem;
- (void)openURLInSelectedApplicationFromMenu:(NSMenuItem *)menuItem;
- (BOOL)openURL:(NSURL *)url inBundleIdentifier:(NSString *)bundleIdentifier;
- (void)openFrameInCurrentFrameFromMenu:(NSMenuItem *)menuItem;
- (void)openURLInNewTabFromMenu:(NSMenuItem *)menuItem;

@end

@interface SBTabSplitView : NSSplitView
{
	CGFloat dividerThickness;
}
@property (nonatomic) CGFloat dividerThickness;

@end