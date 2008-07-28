//
//  PFProductView.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFCollectionRowView.h"
#import "PFStoreWindowController.h"
#import "PFProduct.h"

@implementation PFCollectionRowView

@synthesize item;

- (void)mouseDown:(NSEvent *)event
{
	[super mouseDown:event];
	[[item representedObject] setChecked:![[item representedObject] checked]];
	[[PFStoreWindowController sharedController] updateOrderLineItems:nil];
}

@end




@implementation PFCollectionViewItem

- (void)setView:(PFCollectionRowView *)view
{
	[super setView:view];
	[view setItem:self];
}

@end




@implementation PFClickThroughImageView

- (void)mouseDown:(NSEvent *)event
{
	[[self nextResponder] mouseDown:event];
}

@end
