/*

SBTabView.h
 
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
#import "SBTabViewItem.h"

@interface SBTabView : NSTabView
{
	id<SBTabViewDelegate> delegate;
}
@property (nonatomic, assign) id<SBTabViewDelegate> delegate;
@property (nonatomic) NSRect frame;
@property (nonatomic) NSRect bounds;

- (id)initWithFrame:(NSRect)frame;
- (SBTabViewItem *)selectedTabViewItem;
- (SBTabViewItem *)tabViewItemWithIdentifier:(NSNumber *)identifier;
// Actions
- (SBTabViewItem *)addItemWithIdentifier:(NSNumber *)identifier;
- (SBTabViewItem *)selectTabViewItemWithItemIdentifier:(NSNumber *)identifier;
- (void)openURLInSelectedTabViewItem:(NSString *)URLString;
- (void)closeAllTabViewItem;
// Exec
- (void)executeSelectedItemDidStartLoading:(SBTabViewItem *)aTabViewItem;
- (void)executeSelectedItemDidFinishLoading:(SBTabViewItem *)aTabViewItem;
- (void)executeSelectedItemDidFailLoading:(SBTabViewItem *)aTabViewItem;
- (void)executeSelectedItemDidReceiveTitle:(SBTabViewItem *)aTabViewItem;
- (void)executeSelectedItemDidReceiveIcon:(SBTabViewItem *)aTabViewItem;
- (void)executeSelectedItemDidReceiveServerRedirect:(SBTabViewItem *)aTabViewItem;
- (void)executeShouldAddNewItemForURL:(NSURL *)url selection:(BOOL)selection;
- (void)executeShouldSearchString:(NSString *)string newTab:(BOOL)newTab;
- (BOOL)executeShouldConfirmMessage:(NSString *)message;
- (void)executeShouldShowMessage:(NSString *)message;
- (void)executeSelectedItemDidAddResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)executeSelectedItemDidReceiveExpectedContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)executeSelectedItemDidReceiveContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)executeSelectedItemDidReceiveFinishLoadingOfResourceID:(SBWebResourceIdentifier *)resourceID;
- (NSString *)executeShouldTextInput:(NSString *)prompt;
- (void)executeDidSelectTabViewItem:(SBTabViewItem *)aTabViewItem;

@end
