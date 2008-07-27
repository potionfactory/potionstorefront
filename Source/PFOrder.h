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
	PFAddress *billingAddress;
	
	NSString *creditCardNumber;
	NSString *creditCardSecurityCode;
	NSNumber *creditCardExpirationMonth;
	NSNumber *creditCardExpirationYear;
}

- (NSString *)cleanedCreditCardNumber;
- (PFCreditCardType)creditCardType;

// Simple accessors
- (PFAddress *)billingAddress;
- (void)setBillingAddress:(PFAddress *)value;

- (NSString *)creditCardNumber;
- (void)setCreditCardNumber:(NSString *)value;

- (NSString *)creditCardSecurityCode;
- (void)setCreditCardSecurityCode:(NSString *)value;

- (NSNumber *)creditCardExpirationMonth;
- (void)setCreditCardExpirationMonth:(NSNumber *)value;

- (NSNumber *)creditCardExpirationYear;
- (void)setCreditCardExpirationYear:(NSNumber *)value;

// Validation
- (BOOL)validateCreditCardExpiration:(NSError **)outError;

// Private
- (NSString *)p_cleanCreditCardNumber:(NSString *)value;

@end
