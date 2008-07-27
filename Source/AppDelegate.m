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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)buy:(id)sender
{
	[NSApp beginSheet:[[PotionStoreFront sharedController] window]
	   modalForWindow:mainWindow
		modalDelegate:self 
	   didEndSelector:nil
		  contextInfo:NULL];
}

@end
