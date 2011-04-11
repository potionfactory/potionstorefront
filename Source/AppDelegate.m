//
//  AppDelegate.m
//  RaisedEditor2
//
//  Created by Andy Kim on 1/29/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "AppDelegate.h"

#import <PotionStorefront/PotionStorefront.h>

@implementation AppDelegate

- (IBAction)buy:(id)sender {
	[[PotionStorefront sharedStorefront] setDelegate:self];
	[[PotionStorefront sharedStorefront] setPotionStoreURL:[NSURL URLWithString:@"https://localhost:3000/store"]];
	[[PotionStorefront sharedStorefront] setProductsPlistURL:[NSURL URLWithString:@"http://www.potionfactory.com/files/thehitlist/store_products.plist"]];
	[[PotionStorefront sharedStorefront] setWebStoreSupportsPayPal:YES googleCheckout:YES];
	[[PotionStorefront sharedStorefront] runModal];
//	[[PotionStorefront sharedStorefront] beginSheetModalForWindow:mainWindow];
}

@end
