//
//  PFGradientView.h
//  TheHitList
//
//  Created by Andy Kim on 6/9/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PFBackgroundView : NSView
{
	NSImage *image;
	NSGradient *gradient;
	NSColor *backgroundColor;
	NSColor *minYBorderColor;
	NSColor *maxYBorderColor;
	BOOL rebuild;
}

@property (retain) NSGradient *gradient;
@property (retain) NSColor *backgroundColor;
@property (retain) NSColor *minYBorderColor;
@property (retain) NSColor *maxYBorderColor;

// Private
- (void)rebuildImage;

@end
