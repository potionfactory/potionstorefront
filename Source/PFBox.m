//
//  PFBox.m
//  TheHitList
//
//  Created by Andy Kim on 7/19/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFBox.h"

//#import "NSBezierPathAdditions.h"

@implementation PFBox

- (void)drawLineBoxWithRect:(NSRect)rect
{
	// Draw background
//	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.03] set];
//	NSRectFillUsingOperation(rect, NSCompositeSourceOver);

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

- (void)drawBezelBoxWithRect:(NSRect)rect
{
	rect = [self bounds];
//	[[NSColor clearColor] set];
//	NSRectFill(rect);

	NSRect roundedRect = NSInsetRect([self bounds], 0.0, 0.0);
//	roundedRect.origin.y += 3.5;
//	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:3];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:roundedRect];

	[NSGraphicsContext saveGraphicsState];
	NSRect shadowRect = NSInsetRect(roundedRect, -1.0, -1.0);
//	NSRect shadowRect = NSInsetRect(roundedRect, -0.5, -0.5);
//	NSBezierPath *spath = [NSBezierPath bezierPathWithRoundedRect:shadowRect cornerRadius:4];
	NSBezierPath *spath = [NSBezierPath bezierPathWithRect:shadowRect];
//	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
//	[shadow setShadowOffset:NSMakeSize(0, 0)];
//	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
//	[shadow setShadowBlurRadius:1.0];
//	[shadow set];

	// Outer border fill
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
	[spath fill];
	[NSGraphicsContext restoreGraphicsState];

	// Background
	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
//	[[NSColor colorWithPatternImage:[NSImage imageNamed:@"StripePattern"]] set];
	[path fill];

	// Inner border stroke
//	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
//	[path stroke];
}

- (void)drawRect:(NSRect)rect
{
	if ([self boxType] != NSBoxCustom) {
		if (NSHeight([self bounds]) > 5)
			[self drawBezelBoxWithRect:rect];
		else
			[self drawLineBoxWithRect:rect];
	}
	else {
		NSBorderType borderType = [self borderType];
		if (borderType == NSLineBorder) {
			[self drawLineBoxWithRect:rect];
		}
		else if (borderType == NSBezelBorder) {
			[self drawBezelBoxWithRect:rect];
		}
		else {
			[self drawLineBoxWithRect:rect];
		}
	}
}

@end
