//
//  PFStoreWindowController.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PFGradientView;
@class PFOrder;
@class PFAddress;

@interface PFStoreWindowController : NSWindowController
{
	IBOutlet PFGradientView *headerView;
	IBOutlet PFGradientView *mainContentView;
	IBOutlet NSView *addressSelectionContainerView;
	
	// Labels
	IBOutlet NSTextField *firstNameLabel;
	IBOutlet NSTextField *lastNameLabel;
	IBOutlet NSTextField *address1Label;
	IBOutlet NSTextField *cityLabel;
	IBOutlet NSTextField *stateLabel;
	IBOutlet NSTextField *zipcodeLabel;
	IBOutlet NSTextField *emailLabel;
	IBOutlet NSTextField *creditCardNumberLabel;
	IBOutlet NSTextField *creditCardSecurityCodeLabel;
	IBOutlet NSTextField *creditCardExpirationLabel;

	// Input Fields
	IBOutlet NSTextField *creditCardNumberField;
	IBOutlet NSTextField *creditCardExpirationMonthField;
	IBOutlet NSTextField *creditCardExpirationYearField;
	
	// Pop up buttons
	IBOutlet NSPopUpButton *countryPopUpButton;
	IBOutlet NSPopUpButton *addressPopUpButton;
	
	IBOutlet NSArrayController *countriesArrayController;
	
	PFOrder *order;
	PFAddress *customAddress;
}

+ (id)sharedController;

- (PFOrder *)order;

- (IBAction)purchase:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)selectAddress:(id)sender;
- (IBAction)selectCountry:(id)sender;

// Private
- (NSInteger)p_countOfAddresses;
- (void)p_setupAddressPopUpButton;
- (void)p_setEnabled:(BOOL)enabled toAllControlsInView:(NSView *)view;
- (BOOL)p_validateOrder;

@end
