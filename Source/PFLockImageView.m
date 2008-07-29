//
//  PFLockImageView.m
//  PotionStorefront
//
//  Created by Andy Kim on 7/28/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFLockImageView.h"

#import <QuartzCore/QuartzCore.h>

@implementation PFLockImageView

- (void)awakeFromNib
{
	[self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self bounds]
															options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
															  owner:self
														   userInfo:nil] autorelease]];
}

- (void)mouseEntered:(NSEvent *)event
{
	[securityExplanationField orderIn];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[securityExplanationField orderOut];
}

@end



@implementation PFSecurityExplanationTextField

- (void)awakeFromNib
{
	initialFrame = [self frame];
	NSRect frame = initialFrame;
	frame.origin.x -= NSWidth(frame);
	[self setFrame:frame];
}

- (CABasicAnimation *)orderInAnimation
{
	CABasicAnimation *anim = [CABasicAnimation animation];
	anim.duration = 0.25;
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) {
		anim.duration = 3;
	}
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	return anim;
}

- (CABasicAnimation *)orderOutAnimation
{
	CABasicAnimation *anim = [self orderInAnimation];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	return anim;
}

- (void)orderIn
{
	[self setAnimations:[NSDictionary dictionaryWithObject:[self orderInAnimation] forKey:@"frameOrigin"]];
	NSPoint newOrigin = initialFrame.origin;
	[[self animator] setFrameOrigin:newOrigin];
}

- (void)orderOut
{
	[self setAnimations:[NSDictionary dictionaryWithObject:[self orderOutAnimation] forKey:@"frameOrigin"]];
	NSPoint newOrigin = initialFrame.origin;
	newOrigin.x -= NSWidth(initialFrame);
	[[self animator] setFrameOrigin:newOrigin];
}

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	NSRect clipRect = [self convertRect:initialFrame fromView:[self superview]];
	[[NSBezierPath bezierPathWithRect:clipRect] setClip];
	[super drawRect:rect];
	[NSGraphicsContext restoreGraphicsState];
}

@end
