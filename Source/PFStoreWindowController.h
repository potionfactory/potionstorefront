//
//  PFStoreWindowController.h
//  PotionStorefront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	PFCreditCardPaymentMethod,
	PFWebStorePaymentMethod
};

@class PFOrder;
@class PFAddress;
@class PFBackgroundView;

#ifdef MAC_OS_X_VERSION_10_6
#define WINDOW_DELEGATE <NSWindowDelegate>
#else
#define WINDOW_DELEGATE
#endif

@interface PFStoreWindowController : NSWindowController WINDOW_DELEGATE
{
	IBOutlet PFBackgroundView *headerView;
	IBOutlet PFBackgroundView *mainContentView;

	IBOutlet NSTextField *headerTitleField;
	IBOutlet NSTextField *headerStepsField;
	IBOutlet NSButton *primaryButton;
	IBOutlet NSButton *secondaryButton;
	IBOutlet NSButton *tertiaryButton;
	IBOutlet NSImageView *lockImageView;
	IBOutlet NSProgressIndicator *progressSpinner;

	// -----
	// STUFF FOR PRICING VIEW
	IBOutlet NSView *pricingView;
	IBOutlet NSCollectionView *productCollectionView;
	IBOutlet NSTextField *orderTotalField;
	IBOutlet NSProgressIndicator *productFetchProgressSpinner;
	IBOutlet NSButton *creditCardButton;
	IBOutlet NSButton *paypalOrGoogleCheckoutButton;

	// -----
	// STUFF FOR BILLING VIEW
	IBOutlet NSView *billingView;
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
	IBOutlet NSTextField *firstNameField;
	IBOutlet NSTextField *address1Field;
	IBOutlet NSTextField *emailField;
	IBOutlet NSTextField *creditCardNumberField;
	IBOutlet NSTextField *creditCardExpirationMonthField;
	IBOutlet NSTextField *creditCardExpirationYearField;

	// Pop up buttons
	IBOutlet NSPopUpButton *countryPopUpButton;
	IBOutlet NSPopUpButton *addressPopUpButton;

	IBOutlet NSArrayController *countriesArrayController;

	PFAddress *customAddress;

	// -----
	// STUFF FOR THANK YOU VIEW
	IBOutlet NSView *thankYouView;

	// -----
	// OTHER STUFF
	id delegate;

	NSURL *storeURL;
	NSURL *productsPlistURL;
	PFOrder *order;
	NSInteger paymentMethod;
	BOOL validateFieldsImmediately;
}

+ (id)sharedController;

- (id)delegate;
- (void)setDelegate:(id)object;

// Accessors
- (PFOrder *)order;
- (NSURL *)storeURL;
- (void)setStoreURL:(NSURL *)URL;
- (NSURL *)productsPlistURL;
- (void)setProductsPlistURL:(NSURL *)value;
- (void)setWebStoreSupportsPayPal:(BOOL)flag1 googleCheckout:(BOOL)flag2;

// Actions
- (IBAction)showPricing:(id)sender;
- (IBAction)showBillingInformation:(id)sender;
- (IBAction)showThankYou:(id)sender;

- (IBAction)selectPaymentMethod:(id)sender;
- (IBAction)updatedOrderLineItems:(id)sender;
- (IBAction)purchase:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)selectAddress:(id)sender;
- (IBAction)selectCountry:(id)sender;
- (IBAction)openWebStore:(id)sender;
- (IBAction)showRegistrationWindow:(id)sender;

// Private
- (NSInteger)p_countOfAddresses;
- (void)p_setupAddressPopUpButton;
- (void)p_setEnabled:(BOOL)enabled toAllControlsInView:(NSView *)view;
- (void)p_setContentView:(NSView *)view;
- (void)p_setHeaderTitle:(NSString *)title;
- (BOOL)p_validateOrder;

@end
