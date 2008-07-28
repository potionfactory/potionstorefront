//
//  PFOrder.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PFAddress;

typedef enum {
	PFUnknownType,
	PFVisaType,
	PFMasterCardType,
	PFAmexType,
	PFDiscoverType
} PFCreditCardType;

@interface PFOrder : NSObject
{
	id delegate;

	PFAddress *billingAddress;
	NSArray *lineItems;
	
	NSString *creditCardNumber;
	NSString *creditCardSecurityCode;
	NSNumber *creditCardExpirationMonth;
	NSNumber *creditCardExpirationYear;
	
	NSURL *submitURL;
}

- (void)submitInBackground;

- (NSString *)cleanedCreditCardNumber;
- (PFCreditCardType)creditCardType;
- (NSString *)creditCardTypeString;

// Simple accessors

@property(copy) NSArray *lineItems;

- (id)delegate;
- (void)setDelegate:(id)object;

- (CGFloat)totalAmount;

- (NSURL *)submitURL;
- (void)setSubmitURL:(NSURL *)value;

- (PFAddress *)billingAddress;
- (void)setBillingAddress:(PFAddress *)value;

- (NSString *)creditCardNumber;
- (void)setCreditCardNumber:(NSString *)value;

- (NSString *)creditCardSecurityCode;
- (void)setCreditCardSecurityCode:(NSString *)value;

- (NSNumber *)creditCardExpirationMonth;
- (void)setCreditCardExpirationMonth:(id)value;

- (NSNumber *)creditCardExpirationYear;
- (void)setCreditCardExpirationYear:(id)value;

// Validation
- (BOOL)validateCreditCardExpiration:(NSError **)outError;

// Private
- (NSString *)p_cleanCreditCardNumber:(NSString *)value;

@end


@interface NSObject (PFOrderDelegate)

- (void)orderDidFinishSubmitting:(PFOrder *)order;
- (void)order:(PFOrder *)order failedWithError:(NSError *)error;

@end
