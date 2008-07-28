//
//  PFGradientView.m
//  TheHitList
//
//  Created by Andy Kim on 6/9/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFBackgroundView.h"


@implementation PFBackgroundView

- (void)dealloc
{
	[image release];
	[backgroundColor release];
	[gradient release];
	[minYBorderColor release];
	[maxYBorderColor release];
	[super dealloc];
}

#pragma mark Drawing

- (void)viewWillMoveToSuperview
{
	rebuild = YES;
}

- (void)setFrame:(NSRect)rect
{
	if (NSHeight(self.frame) != NSHeight(rect)) {
		rebuild = YES;
	}
	[super setFrame:rect];
}

- (void)drawRect:(NSRect)rect
{
	if (backgroundColor) {
		[backgroundColor set];
		NSRectFillUsingOperation(rect, NSCompositeSourceOver);
		
		BOOL drawMinYBorder = minYBorderColor != nil;
		BOOL drawMaxYBorder = maxYBorderColor != nil;

		// Draw the top border
		if (drawMaxYBorder) {
			NSRect lineRect = rect;
			lineRect.origin.y = NSHeight(rect) - 2;
			lineRect.size.height = 2;
			[maxYBorderColor set];
			NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		}
		
		// Draw the bottom border
		if (drawMinYBorder) {
			NSRect lineRect = rect;
			lineRect.origin.y = 0;
			lineRect.size.height = 1;
			[minYBorderColor set];
			NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		}
	}
	else {
		if (rebuild) [self rebuildImage];
		
		NSRect bounds = [self bounds];
		rect.origin.y = bounds.origin.y;
		rect.size.height = bounds.size.height;
		
		NSRect srcRect = NSZeroRect;
		srcRect.size = [image size];
		[image setFlipped:NO];
		
		[image drawInRect:rect fromRect:srcRect operation:NSCompositeCopy fraction:1.0];
	}
}

- (void)rebuildImage
{
	[image release];

	BOOL drawMinYBorder = minYBorderColor != nil;
	BOOL drawMaxYBorder = maxYBorderColor != nil;

	NSRect rect = NSZeroRect;
	rect.size = [self frame].size;
	
	// Build texture the first time
	image = [[NSImage alloc] initWithSize:rect.size];
	[image lockFocus];

	// Draw the top border
	if (drawMaxYBorder) {
		NSRect lineRect = rect;
		lineRect.origin.y = NSHeight(rect) - 2;
		lineRect.size.height = 2;
		[maxYBorderColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	}
	
	// Draw the bottom border
	if (drawMinYBorder) {
		NSRect lineRect = rect;
		lineRect.origin.y = 0;
		lineRect.size.height = 1;
		[minYBorderColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	}
	
	NSRect gradientRect = rect;
	// Draw the gradient
	if (drawMinYBorder) {
		gradientRect.origin.y += 1;
		gradientRect.size.height -= 1;
	}
	if (drawMaxYBorder) {
		gradientRect.size.height -= 1;
	}

	[gradient drawInRect:gradientRect angle:-90];
	
	[image unlockFocus];
	[image autorelease];
	image = [[NSImage alloc] initWithData:[image TIFFRepresentation]];

	rebuild = NO;
}

#pragma mark Accessors

- (NSColor *)backgroundColor { return backgroundColor; }
- (void)setBackgroundColor:(NSColor *)color
{
	if (backgroundColor != color) {
		[backgroundColor release];
		backgroundColor = [color retain];
		[gradient release];
		gradient = nil;
	}
}

- (NSGradient *)gradient { return gradient; }
- (void)setGradient:(NSGradient *)value
{
	if (value != gradient) {
		[gradient release];
		gradient = [value retain];
		[backgroundColor release];
		backgroundColor = nil;
		rebuild = YES;
	}
}

- (NSColor *)minYBorderColor { return minYBorderColor; }
- (void)setMinYBorderColor:(NSColor *)color
{
	if (color != minYBorderColor) {
		[minYBorderColor release];
		minYBorderColor = [color retain];
		rebuild = YES;
	}
}

- (NSColor *)maxYBorderColor { return maxYBorderColor; }
- (void)setMaxYBorderColor:(NSColor *)color
{
	if (color != maxYBorderColor) {
		[maxYBorderColor release];
		maxYBorderColor = [color retain];
		rebuild = YES;
	}
}

@end