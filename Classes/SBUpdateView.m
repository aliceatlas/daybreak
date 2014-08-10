/*

SBUpdateView.m
 
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

#import "SBUpdateView.h"

#import "Sunrise3-Bridging-Header.h"
#import "Sunrise3-Swift.h"

#define kSBMinFrameSizeWidth 600
#define kSBMaxFrameSizeWidth 900
#define kSBMinFrameSizeHeight 480
#define kSBMaxFrameSizeHeight 720

@implementation SBUpdateView

@dynamic title;
@dynamic text;
@synthesize versionString;
@synthesize webView;

- (instancetype)initWithFrame:(NSRect)frame
{
	NSRect r = frame;
	if (r.size.width < kSBMinFrameSizeWidth)
		r.size.width = kSBMinFrameSizeWidth;
	if (r.size.width > kSBMaxFrameSizeWidth)
		r.size.width = kSBMaxFrameSizeWidth;
	if (r.size.height < kSBMinFrameSizeHeight)
		r.size.height = kSBMinFrameSizeHeight;
	if (r.size.height > kSBMaxFrameSizeHeight)
		r.size.height = kSBMaxFrameSizeHeight;
	if (self = [super initWithFrame:r])
	{
		[self constructImageView];
		[self constructTitleLabel];
		[self constructTextLabel];
		[self constructWebView];
		[self constructButtons];
        self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
	}
	return self;
}

#pragma mark Rect

- (NSPoint)margin
{
	return NSMakePoint(20.0, 20.0);
}

- (CGFloat)bottomMargin
{
	return 50.0;
}

- (NSRect)imageRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = r.size.height = 64.0;
	r.origin.x = margin.x;
	r.origin.y = self.bounds.size.height - (margin.y + r.size.height);
	return r;
}

- (NSRect)titleRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = self.margin;
	NSRect imageRect = self.imageRect;
	r.size.height = 19.0;
	r.origin.x = NSMaxX(imageRect) + 10;
	r.origin.y = imageRect.origin.y + 34;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	return r;
}

- (NSRect)textRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = self.margin;
	NSRect imageRect = self.imageRect;
	r.size.height = 19.0;
	r.origin.x = NSMaxX(imageRect) + 10;
	r.origin.y = imageRect.origin.y + 10;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	return r;
}

- (NSRect)webRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = self.margin;
	NSRect imageRect = self.imageRect;
	CGFloat bottomMargin = self.bottomMargin;
	r.origin.x = imageRect.origin.x;
	r.origin.y = bottomMargin;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = self.bounds.size.height - (imageRect.size.height + margin.y + 8.0 + bottomMargin);
	return r;
}

- (NSRect)indicatorRect
{
	NSRect r = NSZeroRect;
	NSRect webRect = self.webRect;
	r.size.width = r.size.height = 32.0;
	r.origin.x = NSMidX(webRect) - r.size.width / 2;
	r.origin.y = NSMidY(webRect) - r.size.height / 2;
	return r;
}

- (NSRect)skipButtonRect
{
	NSRect r = NSZeroRect;
	NSRect webRect = self.webRect;
	r.size.height = 32.0;
	r.origin.x = webRect.origin.x;
	r.origin.y = (self.bottomMargin - r.size.height) / 2;
	r.size.width = 165.0;
	return r;
}

- (NSRect)cancelButtonRect
{
	NSRect r = NSZeroRect;
	NSRect skipButtonRect = self.skipButtonRect;
	r = skipButtonRect;
	r.origin.x = self.bounds.size.width - 273.0;
	r.size.width = 131.0;
	return r;
}

- (NSRect)doneButtonRect
{
	NSRect r = NSZeroRect;
	NSRect skipButtonRect = self.skipButtonRect;
	r = skipButtonRect;
	r.origin.x = self.bounds.size.width - 134.0;
	r.size.width = 114.0;
	return r;
}

#pragma mark Construct
- (void)constructImageView
{
	NSImage *image = nil;
	imageView = [[NSImageView alloc] initWithFrame:self.imageRect];
	image = [NSImage imageNamed:@"Application.icns"];
	if (image)
	{
		image.size = imageView.frame.size;
        imageView.image = image;
	}
	[self addSubview:imageView];
}

- (void)constructTitleLabel
{
	titleLabel = [[NSTextField alloc] initWithFrame:self.titleRect];
    titleLabel.bordered = NO;
    titleLabel.editable = NO;
    titleLabel.selectable = NO;
	titleLabel.drawsBackground = NO;
	titleLabel.font = [NSFont boldSystemFontOfSize:16.0];
	titleLabel.textColor = NSColor.whiteColor;
    titleLabel.autoresizingMask = NSViewWidthSizable;
	[self addSubview:titleLabel];
}

- (void)constructTextLabel
{
    textLabel = [[NSTextField alloc] initWithFrame:self.titleRect];
    textLabel.bordered = NO;
    textLabel.editable = NO;
    textLabel.selectable = NO;
    textLabel.drawsBackground = NO;
    textLabel.font = [NSFont systemFontOfSize:13.0];
    textLabel.textColor = NSColor.lightGrayColor;
    textLabel.autoresizingMask = NSViewWidthSizable;
	[self addSubview:textLabel];
}

- (void)constructWebView
{
	indicator = [[NSProgressIndicator alloc] initWithFrame:self.indicatorRect];
	webView = [[WebView alloc] initWithFrame:self.webRect frameName:nil groupName:nil];
    indicator.controlSize = NSRegularControlSize;
    indicator.style = NSProgressIndicatorSpinningStyle;
    indicator.displayedWhenStopped = NO;
    webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    webView.frameLoadDelegate = self;
    webView.UIDelegate = self;
    webView.hidden = YES;
    webView.drawsBackground = NO;
//	[webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]]];
	[self addSubview:webView];
	[self addSubview:indicator];
}

- (void)constructButtons
{
	skipButton = [[SBBLKGUIButton alloc] initWithFrame:self.skipButtonRect];
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:self.cancelButtonRect];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:self.doneButtonRect];
    skipButton.autoresizingMask = NSViewMaxXMargin | NSViewMinYMargin;
    cancelButton.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin;
    doneButton.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin;
    skipButton.target = self;
    cancelButton.target = self;
    doneButton.target = self;
    skipButton.action = nil;
    skipButton.action = @selector(skip);
    cancelButton.action = @selector(cancel);
    doneButton.action = @selector(done);
    skipButton.buttonType = NSMomentaryPushInButton;
    cancelButton.buttonType = NSMomentaryPushInButton;
    doneButton.buttonType = NSMomentaryPushInButton;
    skipButton.title = NSLocalizedString(@"Skip This Version", nil);
    cancelButton.title = NSLocalizedString(@"Not Now", nil);
    doneButton.title = NSLocalizedString(@"Download", nil);
    skipButton.font = [NSFont systemFontOfSize:11.0];
    cancelButton.font = [NSFont systemFontOfSize:11.0];
    doneButton.font = [NSFont systemFontOfSize:11.0];
	cancelButton.keyEquivalent = @"\e";
	doneButton.keyEquivalent = @"\r";
    doneButton.enabled = NO;
	[self addSubview:skipButton];
	[self addSubview:cancelButton];
	[self addSubview:doneButton];
}

#pragma mark Delegate

- (void)downloader:(SBDownloader *)downloader didFinish:(NSData *)data
{
	NSString *htmlString = nil;
	NSURL *baseURL = nil;
	baseURL = [NSBundle.mainBundle URLForResource:@"Releasenotes" withExtension:@"html"];
	htmlString = [self htmlStringWithBaseURL:baseURL releaseNotesData:data];
	[indicator stopAnimation:nil];
	[webView.mainFrame loadHTMLString:htmlString baseURL:baseURL];
    doneButton.enabled = YES;
}

- (void)downloader:(SBDownloader *)downloader didFail:(NSError *)error
{
	[indicator stopAnimation:nil];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	[indicator startAnimation:nil];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    webView.hidden = NO;
	[indicator stopAnimation:nil];
    doneButton.enabled = YES;
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	[indicator stopAnimation:nil];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	[indicator stopAnimation:nil];
}

#pragma mark Getter

- (NSString *)title
{
	return titleLabel.stringValue;
}

- (NSString *)text
{
	return textLabel.stringValue;
}

#pragma mark Setter

- (void)setTitle:(NSString *)title
{
    titleLabel.stringValue = title;
}

- (void)setText:(NSString *)text
{
    textLabel.stringValue = text;
}

#pragma mark Actions

- (void)loadRequest:(NSURL *)url
{
	SBDownloader *downloader = nil;
	downloader = [SBDownloader downloadWithURL:url];
	downloader.delegate = self;
	[downloader start];
	[indicator startAnimation:nil];
}

- (void)skip
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:versionString forKey:kSBUpdaterSkipVersion];
	[self cancel];
}

#pragma mark Functions

- (NSString *)htmlStringWithBaseURL:(NSURL *)baseURL releaseNotesData:(NSData *)data
{
	NSString *htmlString = nil;
	if (data)
	{
		NSString *baseHTML = nil;
		NSString *releasenotes = nil;
		baseHTML = [NSString stringWithContentsOfURL:baseURL encoding:NSUTF8StringEncoding error:nil];
		releasenotes = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (baseHTML && releasenotes)
		{
			htmlString = [NSString stringWithFormat:baseHTML, releasenotes];
		}
		else if (baseHTML)
		{
			htmlString = [NSString stringWithFormat:baseHTML, NSLocalizedString(@"No data", nil)];
		}
	}
	return htmlString;
}

@end
