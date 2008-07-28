//
//  AppDelegate.m
//  RaisedEditor2
//
//  Created by Andy Kim on 1/29/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "AppDelegate.h"

#import <PotionStoreFront/PotionStoreFront.h>

@implementation AppDelegate

+ (void)load
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loaded:) name:NSBundleDidLoadNotification object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loaded:) name:NSBundleDidLoadNotification object:nil];
}

+ (void)loaded:(NSNotification *)notification
{
	NSLog(@"loaded bundle: %@", [notification userInfo]);
}

- (IBAction)buy:(id)sender
{
	[[PotionStoreFront sharedStoreFront] setStoreURL:[NSURL URLWithString:@"http://localhost:3000/store"]];
	[[PotionStoreFront sharedStoreFront] setDelegate:self];
	[[PotionStoreFront sharedStoreFront] beginSheetModalForWindow:mainWindow];
}

- (IBAction)unload:(id)sender
{
	if ([[NSBundle bundleWithIdentifier:@"com.potionfactory.PotionStoreFront"] unload])
		NSLog(@"unloaded");
	else
		NSLog(@"did not unload");
}

@end
