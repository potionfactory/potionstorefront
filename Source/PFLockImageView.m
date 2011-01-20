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

- (void)awakeFromNib {
	[self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self bounds]
															options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
															  owner:self
														   userInfo:nil] autorelease]];
}

- (void)mouseEntered:(NSEvent *)event {
	[securityExplanationField orderIn];
}

- (void)mouseExited:(NSEvent *)theEvent {
	[orderOutTimer invalidate];
	orderOutTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(orderOutTimerFired:) userInfo:nil repeats:NO];
}

- (void)orderOutTimerFired:(NSTimer *)timer {
	orderOutTimer = nil;
	[securityExplanationField orderOut];
}

@end



@implementation PFSecurityExplanationTextField

- (void)awakeFromNib {
	initialFrame = [self frame];
	NSRect frame = initialFrame;
	frame.origin.x -= NSWidth(frame);
	[self setFrame:frame];
}

- (CABasicAnimation *)orderInAnimation {
	CABasicAnimation *anim = [CABasicAnimation animation];
	anim.duration = 0.25;
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) {
		anim.duration = 3;
	}
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	return anim;
}

- (CABasicAnimation *)orderOutAnimation {
	CABasicAnimation *anim = [self orderInAnimation];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	return anim;
}

- (void)orderIn {
	NSPoint newOrigin = initialFrame.origin;
	[self setAnimations:[NSDictionary dictionaryWithObject:[self orderInAnimation] forKey:@"frameOrigin"]];
	[[self animator] setFrameOrigin:newOrigin];
}

- (void)orderOut {
	NSPoint newOrigin = initialFrame.origin;
	newOrigin.x -= NSWidth(initialFrame);
	if (self.frame.origin.x == newOrigin.x) return;
	[self setAnimations:[NSDictionary dictionaryWithObject:[self orderOutAnimation] forKey:@"frameOrigin"]];
	[[self animator] setFrameOrigin:newOrigin];
}

- (void)drawRect:(NSRect)rect {
	[NSGraphicsContext saveGraphicsState];
	NSRect clipRect = [self convertRect:initialFrame fromView:[self superview]];
	[[NSBezierPath bezierPathWithRect:clipRect] setClip];
	[super drawRect:rect];
	[NSGraphicsContext restoreGraphicsState];
}

@end
