/*

SBUpdateView.h
 
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
#import "SBView.h"

@class SBBLKGUIButton;
@protocol SBDownloaderDelegate;
@interface SBUpdateView : SBView <SBDownloaderDelegate>
{
	NSImageView *imageView;
	NSTextField *titleLabel;
	NSTextField *textLabel;
	WebView *webView;
	NSProgressIndicator *indicator;
	SBBLKGUIButton *skipButton;
	SBBLKGUIButton *cancelButton;
	SBBLKGUIButton *doneButton;
	NSString *versionString;
}
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *text;
@property (nonatomic, strong) NSString *versionString;
@property (nonatomic, strong) WebView *webView;
@property (nonatomic, readonly) NSRect imageRect;
@property (nonatomic, readonly) NSRect titleRect;
@property (nonatomic, readonly) NSRect textRect;
@property (nonatomic, readonly) NSRect webRect;
@property (nonatomic, readonly) NSRect indicatorRect;
@property (nonatomic, readonly) NSRect skipButtonRect;
@property (nonatomic, readonly) NSRect cancelButtonRect;
@property (nonatomic, readonly) NSRect doneButtonRect;

// Construct
- (void)constructImageView;
- (void)constructTitleLabel;
- (void)constructTextLabel;
- (void)constructWebView;
- (void)constructButtons;
// Actions
- (void)loadRequest:(NSURL *)url;

- (NSString *)htmlStringWithBaseURL:(NSURL *)baseURL releaseNotesData:(NSData *)data;

@end
