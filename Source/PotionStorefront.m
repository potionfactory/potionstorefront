//
//  PotionStorefront.m
//  PotionStorefront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PotionStorefront.h"
#import "PFStoreWindowController.h"

@implementation PotionStorefront

//+ (void)load
//{
//	NSLog(@"Loading Potion Store Front framework");
//}

static PotionStorefront *gStorefront = nil;

+ (PotionStorefront *)sharedStorefront
{
	if (gStorefront == nil) {
		gStorefront = [[PotionStorefront alloc] init];
	}
	return gStorefront;
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
	NSWindow *storeWindow = [[PFStoreWindowController sharedController] window];

	// Don't open twice
	if ([storeWindow isVisible]) {
		[storeWindow makeKeyAndOrderFront:self];
		return;
	}

	[NSApp beginSheet:storeWindow
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:nil
		  contextInfo:NULL];

	// Clear the first responder. By default it's getting set to the web store button, and that looks quite fugly
	[storeWindow makeFirstResponder:nil];
}

@end
