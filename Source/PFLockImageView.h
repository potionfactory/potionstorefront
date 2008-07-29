//
//  PFLockImageView.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/28/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PFSecurityExplanationTextField : NSTextField
{
	NSRect initialFrame;
}
- (void)orderIn;
- (void)orderOut;
@end


@interface PFLockImageView : NSImageView
{
	IBOutlet PFSecurityExplanationTextField *securityExplanationField;
}
@end
