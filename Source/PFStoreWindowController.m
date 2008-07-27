//
//  PFStoreWindowController.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFStoreWindowController.h"
#import "PFGradientView.h"

#import "PFOrder.h"
#import "PFAddress.h"

#import <AddressBook/AddressBook.h>

@implementation PFStoreWindowController

static PFStoreWindowController *gController = nil;

+ (id)sharedController
{
	if (gController == nil) {
		gController = [[PFStoreWindowController alloc] init];
	}
	
	return gController;
}

- (id)init
{
	self = [super initWithWindowNibName:@"Store"];
	if (self) {
		order = [[PFOrder alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[customAddress release];
	[order release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[self window];
	
	// If there's one or less addresses in address book, hide the address selection dropdown
	if ([self p_countOfAddresses] <= 1) {
		NSRect wframe = [[self window] frame];
		wframe.size.height -= NSHeight([addressSelectionContainerView frame]);
		[addressSelectionContainerView removeFromSuperview];
		[[self window] setFrame:wframe display:YES];
		addressPopUpButton = nil;
	}
	// Otherwise, populate the dropdown
	else {
		[self p_setupAddressPopUpButton];
	}

	[headerView setGradient:
	 [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.95]
									endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.95]] autorelease]];

	[mainContentView setGradient:
	 [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0]
									endingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0]] autorelease]];
	
	NSArray *countries = [NSArray arrayWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"countries" ofType:@"plist"]];
	[countriesArrayController setContent:countries];
}

- (void)close
{
	[super close];
	[self autorelease];
	gController = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)purchase:(id)sender
{
	if ([self p_validateOrder]) {
		[self p_setEnabled:NO toAllControlsInView:[[self window] contentView]];
		[self close];
		[NSApp endSheet:[self window] returnCode:NSOKButton];
	}
	else {
		NSBeep();
	}
}

- (IBAction)goBack:(id)sender
{
	[self close];
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)selectAddress:(id)sender
{
	NSInteger index = [sender indexOfItem:[sender selectedItem]];
	
	if (index < [self p_countOfAddresses]) {
		NSString *label = [[[[ABAddressBook sharedAddressBook] me] valueForProperty:kABAddressProperty] labelAtIndex:index];
		PFAddress *address = [[[order billingAddress] copy] autorelease];
		[address fillUsingAddressBookAddressWithLabel:label];
		[order setBillingAddress:address];
	}
	else if (customAddress) {
		[order setBillingAddress:customAddress];
	}
}

- (IBAction)selectCountry:(id)sender
{
	[self controlTextDidChange:nil];
}

#pragma mark -
#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == creditCardNumberField) return;
	if ([aNotification object] == creditCardExpirationMonthField) return;
	if ([aNotification object] == creditCardExpirationYearField) return;

	// Should get here iff address is edited

	// Only add the custom address item once
	if (customAddress == nil) {
		[addressPopUpButton addItemWithTitle:NSLocalizedString(@"other", nil)];
		[addressPopUpButton selectItemAtIndex:[addressPopUpButton numberOfItems] - 1];
		
		customAddress = [[order billingAddress] copy];
		[order setBillingAddress:customAddress];
	}
	else {
		[customAddress release];
		customAddress = [[order billingAddress] copy];
		[order setBillingAddress:customAddress];
		// Select the custom address in the pop up
		[addressPopUpButton selectItemAtIndex:[addressPopUpButton numberOfItems] - 1];
	}
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	// It would be nice to validate in control:isValidObject:, but I can't figure out how to customize
	// the error message there

	// Validate the credit card number right away
	if (control == creditCardNumberField) {
		NSString *ccnum = [creditCardNumberField stringValue];
		if ([ccnum length] != 0) {
			NSError *error = nil;
			if (![order validateValue:&ccnum forKey:@"creditCardNumber" error:&error]) {
				NSAlert *alert = [NSAlert alertWithError:error];
				[alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
				return NO;
			}
		}
	}

	return YES;
}

#pragma mark -
#pragma mark Accessors

- (PFOrder *)order { return order; }

#pragma mark -
#pragma mark Private

- (NSInteger)p_countOfAddresses
{
	ABMultiValue *addresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABAddressProperty];
	return [addresses count];
}

- (void)p_setupAddressPopUpButton
{
	ABMultiValue *addresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABAddressProperty];
	
	[addressPopUpButton removeAllItems];

	for (NSUInteger i = 0; i < [addresses count]; i++) {
		NSString *label = [addresses labelAtIndex:i];

		if ([label isEqualToString:kABHomeLabel])
			label = NSLocalizedString(@"home", nil);
		else if ([label isEqualToString:kABWorkLabel])
			label = NSLocalizedString(@"work", nil);

		[addressPopUpButton addItemWithTitle:label];
	}
	
	[addressPopUpButton setTarget:self];
	[addressPopUpButton setAction:@selector(selectAddress:)];
}

- (void)p_setEnabled:(BOOL)enabled toAllControlsInView:(NSView *)view
{
	NSEnumerator *e = [[view subviews] objectEnumerator];
	NSView *subview = nil;
	while ((subview = [e nextObject])) {
		[self p_setEnabled:enabled toAllControlsInView:subview];
	}

	if ([view respondsToSelector:@selector(setEnabled:)]) {
		[(NSControl *)view setEnabled:enabled];
	}
}

- (BOOL)p_validateOrder
{
	BOOL success = YES;

	NSColor *good = [NSColor controlTextColor];
	NSColor *bad = [[NSColor redColor] shadowWithLevel:0.15];
	
	[firstNameLabel setTextColor:good];
	[lastNameLabel setTextColor:good];
	[address1Label setTextColor:good];
	[cityLabel setTextColor:good];
	[stateLabel setTextColor:good];
	[zipcodeLabel setTextColor:good];
	[emailLabel setTextColor:good];
	[creditCardNumberLabel setTextColor:good];
	[creditCardSecurityCodeLabel setTextColor:good];
	[creditCardExpirationLabel setTextColor:good];

	id value = nil;
	NSError *error = nil;
	PFAddress *billingAddress = [order billingAddress];

	if (!(value = [billingAddress firstName]) && ![billingAddress validateValue:&value forKey:@"firstName" error:nil]) {
		[firstNameLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [billingAddress lastName]) && ![billingAddress validateValue:&value forKey:@"lastName" error:nil]) {
		[lastNameLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [billingAddress address1]) && ![billingAddress validateValue:&value forKey:@"address1" error:nil]) {
		[address1Label setTextColor:bad];
		success = NO;
	}

	if (!(value = [billingAddress city]) && ![billingAddress validateValue:&value forKey:@"city" error:nil]) {
		[cityLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [billingAddress state]) && ![billingAddress validateValue:&value forKey:@"state" error:nil]) {
		[stateLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [billingAddress zipcode]) && ![billingAddress validateValue:&value forKey:@"zipcode" error:nil]) {
		[zipcodeLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [billingAddress email]) && ![billingAddress validateValue:&value forKey:@"email" error:nil]) {
		[emailLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [order creditCardNumber]) || ![order validateValue:&value forKey:@"creditCardNumber" error:nil]) {
		[creditCardNumberLabel setTextColor:bad];
		success = NO;
	}

	if (!(value = [order creditCardSecurityCode]) && ![order validateValue:&value forKey:@"creditCardSecurityCode" error:nil]) {
		[creditCardSecurityCodeLabel setTextColor:bad];
		success = NO;
	}

	if (![order validateCreditCardExpiration:&error]) {
		[creditCardExpirationLabel setTextColor:bad];
		success = NO;
		
		if (error) {
			NSAlert *alert = [NSAlert alertWithError:error];
			[alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
		}
	}

	return success;
}

@end
