//
//  PFLockImageView.h
//  PotionStorefront
//
//  Created by Andy Kim on 7/28/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFLockImageView : NSImageView {
	IBOutlet NSTextField *securityExplanationField;
	NSTimer *orderOutTimer;
}
@end
