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

//+ (void)load
//{
//	NSLog(@"Loading Potion Store Front framework");
//}

static PotionStoreFront *gStoreFront = nil;

+ (PotionStoreFront *)sharedStoreFront
{
	if (gStoreFront == nil) {
		gStoreFront = [[PotionStoreFront alloc] init];
	}
	return gStoreFront;
}

- (id)delegate
{
	return [[PFStoreWindowController sharedController] delegate];
}

- (void)setDelegate:(id)delegate
{
	[[PFStoreWindowController sharedController] setDelegate:delegate];
}

- (NSURL *)potionStoreURL
{
	return [[PFStoreWindowController sharedController] storeURL];
}

- (void)setPotionStoreURL:(NSURL *)URL
{
	[[PFStoreWindowController sharedController] setStoreURL:URL];
}

- (NSURL *)productsPlistURL
{
	return [[PFStoreWindowController sharedController] productsPlistURL];
}

- (void)setProductsPlistURL:(NSURL *)URL
{
	[[PFStoreWindowController sharedController] setProductsPlistURL:URL];
}

- (void)setWebStoreSupportsPayPal:(BOOL)flag1 googleCheckout:(BOOL)flag2
{
	[[PFStoreWindowController sharedController] setWebStoreSupportsPayPal:flag1 googleCheckout:flag2];
}

- (void)beginSheetModalForWindow:(NSWindow *)window
{
	[NSApp beginSheet:[[PFStoreWindowController sharedController] window]
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:nil
		  contextInfo:NULL];

	// Clear the first responder. By default it's getting set to the web store button, and that looks quite fugly
	[[[PFStoreWindowController sharedController] window] makeFirstResponder:nil];
}

@end
