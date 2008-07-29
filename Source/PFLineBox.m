//
//  PFLineBox.m
//  TheHitList
//
//  Created by Andy Kim on 7/19/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFLineBox.h"

@implementation PFLineBox

- (void)drawRect:(NSRect)rect
{
	BOOL drawHighlight = YES;
	BOOL drawShadow = YES;

	NSColor *highlightColor = nil;
	NSColor *shadowColor = nil;
	if (drawHighlight) highlightColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.4];
	if (drawShadow) shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.125];

	// Draw line at top
	NSRect lineRect = NSInsetRect([self bounds], 0, 0);

	// Highlight
	lineRect.size.height = 1;
	if (drawHighlight) {
		[highlightColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	}

	// Shadow
	lineRect.origin.y += 1;
	if (drawShadow) {
		[shadowColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	}

	if (NSHeight([self bounds]) > 5) {
		// Highlight
		lineRect.origin.y = NSMaxY([self bounds]) - 2;
		if (drawHighlight) {
			[highlightColor set];
			NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		}

		// Shadow
		lineRect.origin.y += 1;
		if (drawShadow) {
			[shadowColor set];
			NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		}
	}
}

@end
