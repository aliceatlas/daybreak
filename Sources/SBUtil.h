/*

SBUtil.h
 
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
#import <WebKit/WebKit.h>
#include <mach/mach_host.h>

@class SBApplicationDelegate;
@class SBDocumentController;
@class SBDocument;

// Paths

CF_IMPLICIT_BRIDGING_ENABLED

CGPathRef SBEllipsePath3D(CGRect r, CATransform3D transform);
CGPathRef SBRoundedPath3D(CGRect rect, CGFloat curve, CATransform3D transform);

CF_IMPLICIT_BRIDGING_DISABLED

// Math

CF_IMPLICIT_BRIDGING_ENABLED

NSInteger SBRemainder(NSInteger value1, NSInteger value2);
BOOL SBRemainderIsZero(NSInteger value1, NSInteger value2);
NSInteger SBGreatestCommonDivisor(NSInteger a, NSInteger b);

CF_IMPLICIT_BRIDGING_DISABLED

// Others

NSMenu *SBEncodingMenu(id target, SEL selector, BOOL showDefault);
NSComparisonResult SBStringEncodingSortFunction(id num1, id num2, void *context);
NSInteger SBUnsignedIntegerSortFunction(id num1, id num2, void *context);
NSData *SBLocalizableStringsData(NSArray *fieldSet);

// Debug

id SBValueForKey(NSString *keyName, NSDictionary *dictionary);
NSDictionary *SBDebugViewStructure(NSView *view);
NSDictionary *SBDebugLayerStructure(CALayer *layer);
NSDictionary *SBDebugDumpMainMenu();
NSArray *SBDebugDumpMenu(NSMenu *menu);
BOOL SBDebugWriteViewStructure(NSView *view, NSString *path);
BOOL SBDebugWriteLayerStructure(CALayer *layer, NSString *path);
BOOL SBDebugWriteMainMenu(NSString *path);

void SBPerform(id target, SEL action, id object);
void SBPerformWithModes(id target, SEL action, id object, NSArray *modes);
kern_return_t SBCPUType(cpu_type_t *cpuType);
