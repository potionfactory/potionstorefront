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
	[securityExplanationField setAlphaValue:0.0];
	[self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self bounds]
															options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
															  owner:self
														   userInfo:nil] autorelease]];
}

- (void)mouseEntered:(NSEvent *)event {
	if ([securityExplanationField alphaValue] == 1.0) return;

	CABasicAnimation *anim = [CABasicAnimation animation];
	anim.duration = 0.25;
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

	[securityExplanationField setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"alphaValue"]];
	[[securityExplanationField animator] setAlphaValue:1.0];
}

- (void)setHidden:(BOOL)flag {
	[super setHidden:flag];
	[securityExplanationField setHidden:flag];

	if (flag)
		[securityExplanationField setAlphaValue:0.0];
}

@end
