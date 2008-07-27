//
//  PotionStoreFront.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PotionStoreFront.h"
#import "PFStoreWindowController.h"

@implementation PotionStoreFront

+ (void)load
{
	NSLog(@"Loading Potion Store Front framework");
}

+ (NSWindowController *)sharedController
{
	return [PFStoreWindowController sharedController];
}

@end
