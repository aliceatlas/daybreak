/*

SBWebView.h
 
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

@class SBWebView;
@protocol SBWebViewDelegate <NSObject>
- (void)webViewShouldOpenFindbar:(SBWebView *)aWebView;
- (BOOL)webViewShouldCloseFindbar:(SBWebView *)aWebView;
@end

@interface SBWebView : WebView
{
	id delegate;
	BOOL showFindbar;
	BOOL _magnified;
	NSString *textEncodingName;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic) BOOL showFindbar;
@property (nonatomic, retain) NSString *textEncodingName;

- (id)initWithFrame:(NSRect)frameRect frameName:(NSString *)frameName groupName:(NSString *)groupName;

- (void)executeOpenFindbar;
- (BOOL)executeCloseFindbar;
- (NSString *)textEncodingName;
- (void)performFind:(id)sender;	// performFindPanelAction: of WebView is broken
- (void)performFindNext:(id)sender;
- (void)performFindPrevious:(id)sender;

- (BOOL)searchFor:(NSString *)searchString direction:(BOOL)forward caseSensitive:(BOOL)caseFlag wrap:(BOOL)wrapFlag continuous:(BOOL)continuous;

- (NSString *)documentString;
- (BOOL)isEmpty;
- (NSRange)rageOfStringInWebDocument:(NSString *)string caseSensitive:(BOOL)caseFlag;

- (id)inspector;
- (void)showWebInspector:(id)sender;
- (void)showConsole:(id)sender;

@end