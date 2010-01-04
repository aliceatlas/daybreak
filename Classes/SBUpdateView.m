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
#import "SBDownloader.h"

#define kSBMinFrameSizeWidth 600
#define kSBMaxFrameSizeWidth 900
#define kSBMinFrameSizeHeight 480
#define kSBMaxFrameSizeHeight 720

@implementation SBUpdateView

@dynamic title;
@dynamic text;
@synthesize versionString;
@synthesize webView;

- (id)initWithFrame:(NSRect)frame
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
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[imageView release];
	[titleLabel release];
	[textLabel release];
	[webView release];
	[indicator release];
	[skipButton release];
	[cancelButton release];
	[doneButton release];
	[versionString release];
	[super dealloc];
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
	NSPoint margin = [self margin];
	NSRect imageRect = [self imageRect];
	r.size.height = 19.0;
	r.origin.x = NSMaxX(imageRect) + 10;
	r.origin.y = imageRect.origin.y + 34;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	return r;
}

- (NSRect)textRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect imageRect = [self imageRect];
	r.size.height = 19.0;
	r.origin.x = NSMaxX(imageRect) + 10;
	r.origin.y = imageRect.origin.y + 10;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	return r;
}

- (NSRect)webRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect imageRect = [self imageRect];
	CGFloat bottomMargin = [self bottomMargin];
	r.origin.x = imageRect.origin.x;
	r.origin.y = bottomMargin;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = self.bounds.size.height - (imageRect.size.height + margin.y + 8.0 + bottomMargin);
	return r;
}

- (NSRect)indicatorRect
{
	NSRect r = NSZeroRect;
	NSRect webRect = [self webRect];
	r.size.width = r.size.height = 32.0;
	r.origin.x = NSMidX(webRect) - r.size.width / 2;
	r.origin.y = NSMidY(webRect) - r.size.height / 2;
	return r;
}

- (NSRect)skipButtonRect
{
	NSRect r = NSZeroRect;
	NSRect webRect = [self webRect];
	r.size.height = 32.0;
	r.origin.x = webRect.origin.x;
	r.origin.y = ([self bottomMargin] - r.size.height) / 2;
	r.size.width = 165.0;
	return r;
}

- (NSRect)cancelButtonRect
{
	NSRect r = NSZeroRect;
	NSRect skipButtonRect = [self skipButtonRect];
	r = skipButtonRect;
	r.origin.x = self.bounds.size.width - 273.0;
	r.size.width = 131.0;
	return r;
}

- (NSRect)doneButtonRect
{
	NSRect r = NSZeroRect;
	NSRect skipButtonRect = [self skipButtonRect];
	r = skipButtonRect;
	r.origin.x = self.bounds.size.width - 134.0;
	r.size.width = 114.0;
	return r;
}

#pragma mark Construct
- (void)constructImageView
{
	NSImage *image = nil;
	imageView = [[NSImageView alloc] initWithFrame:[self imageRect]];
	image = [NSImage imageNamed:@"Application.icns"];
	if (image)
	{
		[image setSize:[imageView frame].size];
		[imageView setImage:image];
	}
	[self addSubview:imageView];
}

- (void)constructTitleLabel
{
	titleLabel = [[NSTextField alloc] initWithFrame:[self titleRect]];
	[titleLabel setBordered:NO];
	[titleLabel setEditable:NO];
	[titleLabel setSelectable:NO];
	[titleLabel setDrawsBackground:NO];
	[titleLabel setFont:[NSFont boldSystemFontOfSize:16.0]];
	[titleLabel setTextColor:[NSColor whiteColor]];
	[titleLabel setAutoresizingMask:(NSViewWidthSizable)];
	[self addSubview:titleLabel];
}

- (void)constructTextLabel
{
	textLabel = [[NSTextField alloc] initWithFrame:[self textRect]];
	[textLabel setBordered:NO];
	[textLabel setEditable:NO];
	[textLabel setSelectable:NO];
	[textLabel setDrawsBackground:NO];
	[textLabel setFont:[NSFont systemFontOfSize:13.0]];
	[textLabel setTextColor:[NSColor lightGrayColor]];
	[textLabel setAutoresizingMask:(NSViewWidthSizable)];
	[self addSubview:textLabel];
}

- (void)constructWebView
{
	indicator = [[NSProgressIndicator alloc] initWithFrame:[self indicatorRect]];
	webView = [[WebView alloc] initWithFrame:[self webRect] frameName:nil groupName:nil];
	[indicator setControlSize:NSRegularControlSize];
	[indicator setStyle:NSProgressIndicatorSpinningStyle];
	[indicator setDisplayedWhenStopped:NO];
	[webView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[webView setFrameLoadDelegate:self];
	[webView setUIDelegate:self];
	[webView setHidden:YES];
	[webView setDrawsBackground:NO];
//	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]]];
	[self addSubview:webView];
	[self addSubview:indicator];
}

- (void)constructButtons
{
	skipButton = [[SBBLKGUIButton alloc] initWithFrame:[self skipButtonRect]];
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:[self cancelButtonRect]];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:[self doneButtonRect]];
	[skipButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
	[cancelButton setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[doneButton setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[skipButton setTarget:self];
	[cancelButton setTarget:self];
	[doneButton setTarget:self];
	[skipButton setAction:nil];
	[skipButton setAction:@selector(skip)];
	[cancelButton setAction:@selector(cancel)];
	[doneButton setAction:@selector(done)];
	[skipButton setButtonType:NSMomentaryLight];
	[cancelButton setButtonType:NSMomentaryLight];
	[doneButton setButtonType:NSMomentaryLight];
	[skipButton setTitle:NSLocalizedString(@"Skip This Version", nil)];
	[cancelButton setTitle:NSLocalizedString(@"Not Now", nil)];
	[doneButton setTitle:NSLocalizedString(@"Download", nil)];
	[skipButton setFont:[NSFont systemFontOfSize:11.0]];
	[cancelButton setFont:[NSFont systemFontOfSize:11.0]];
	[doneButton setFont:[NSFont systemFontOfSize:11.0]];
	[cancelButton setKeyEquivalent:@"\e"];
	[doneButton setKeyEquivalent:@"\r"];
	[doneButton setEnabled:NO];
	[self addSubview:skipButton];
	[self addSubview:cancelButton];
	[self addSubview:doneButton];
}

#pragma mark Delegate

- (void)downloader:(SBDownloader *)downloader didFinish:(NSData *)data
{
	NSString *htmlString = nil;
	NSURL *baseURL = nil;
	baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Releasenotes" ofType:@"html"]];
	htmlString = [self htmlStringWithBaseURL:baseURL releaseNotesData:data];
	[indicator stopAnimation:nil];
	[[webView mainFrame] loadHTMLString:htmlString baseURL:baseURL];
	[doneButton setEnabled:YES];
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
	[webView setHidden:NO];
	[indicator stopAnimation:nil];
	[doneButton setEnabled:YES];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)errorforFrame:(WebFrame *)frame
{
	[indicator stopAnimation:nil];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)errorforFrame:(WebFrame *)frame
{
	[indicator stopAnimation:nil];
}

#pragma mark Getter

- (NSString *)title
{
	return [titleLabel stringValue];
}

- (NSString *)text
{
	return [textLabel stringValue];
}

#pragma mark Setter

- (void)setTitle:(NSString *)title
{
	[titleLabel setStringValue:title];
}

- (void)setText:(NSString *)text
{
	[textLabel setStringValue:text];
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
		releasenotes = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
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
