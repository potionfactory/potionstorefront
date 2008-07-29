//
//  PFCollectionRow.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFCollectionRow.h"
#import "PFStoreWindowController.h"
#import "PFOrder.h"
#import "PFProduct.h"


@implementation PFCollectionRowView

@synthesize item;

- (void)dealloc
{
	// Don't need to release item it's a weak reference
	// This is here to keep scan-build happy
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)event
{
	// Make the whole view toggle the item. The checkbox can't cover the whole view.
	[super mouseDown:event];
	[[self viewWithTag:1] performClick:self];
}

@end




@implementation PFCollectionViewItem

- (IBAction)toggleItem:(id)sender
{
	[[self representedObject] setChecked:[sender state]];

	PFOrder *order = [[PFStoreWindowController sharedController] order];

	NSArray *allProducts = [[self collectionView] content];
	PFProduct *clickedProduct = [self representedObject];

	for (PFProduct *product in allProducts) {
		if (clickedProduct == product) continue;
		if ([[product radioGroupName] isEqualToString:[clickedProduct radioGroupName]]) {
			[product setChecked:NO];
		}
	}

	[order setLineItems:[allProducts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"checked = YES"]]];

	// Tell the main controller that the order line items were updated
	[[PFStoreWindowController sharedController] updatedOrderLineItems:sender];
}

- (NSButton *)checkboxButton
{
	return (NSButton *)[[self view] viewWithTag:1];
}

- (void)setRepresentedObject:(id)object
{
	[super setRepresentedObject:object];

	if (object && [object radioGroupName] == nil) {
		// If there's no radio group, this item should become optional.
		// So replace the radio button with a checkbox button.
		// For some reason just changing the button type has no effect here
		NSButton *oldButton = (NSButton *)[[self view] viewWithTag:1];
		NSButton *button = [[[NSButton alloc] initWithFrame:[oldButton frame]] autorelease];
		[button setTitle:[oldButton title]];
		[button setTarget:[oldButton target]];
		[button setAction:[oldButton action]];
		[button setTag:[oldButton tag]];
		[button setButtonType:NSSwitchButton];
		[button setState:[object checked]];
		[[self view] replaceSubview:oldButton with:button];
	}
}

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
