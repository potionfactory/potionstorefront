//
//  PotionStoreFront.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PFOrder.h"
#import "PFAddress.h"
#import "PFProduct.h"

#define DEBUG_POTION_STORE_FRONT 0

@interface PotionStoreFront : NSObject
{
}

+ (PotionStoreFront *)sharedStoreFront;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSURL *)potionStoreURL;
- (void)setPotionStoreURL:(NSURL *)URL;

- (NSURL *)productsPlistURL;
- (void)setProductsPlistURL:(NSURL *)URL;

- (void)beginSheetModalForWindow:(NSWindow *)window;

@end



@interface NSObject (PotionStoreFrontDelegate)
- (void)orderDidFinishCharging:(PFOrder *)order;
@end
