//
//  PFOrder.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFOrder.h"
#import "PFAddress.h"

@implementation PFOrder

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isVisaCard"];
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isMasterCard"];
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isAmexCard"];
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isDiscoverCard"];
}

- (id)init
{
	billingAddress = [[PFAddress alloc] init];
	[billingAddress fillUsingAddressBook];
	return self;
}

- (void)dealloc
{
	[billingAddress release];

	[creditCardNumber release];
	[creditCardSecurityCode release];
	[creditCardExpirationMonth release];
	[creditCardExpirationYear release];
	
	[super dealloc];
}

- (NSString *)cleanedCreditCardNumber
{
	return [self p_cleanCreditCardNumber:[self creditCardNumber]];
}

// Return the credit card type based on the credit card number
- (PFCreditCardType)creditCardType
{
	NSString *ccnum = [self cleanedCreditCardNumber];

	if ([ccnum length] == 0) return PFUnknownType;

	if ([ccnum hasPrefix:@"3"]) {
		// Diners (Mastercard) (36) or Amex (34 or 37)
		if ([ccnum length] < 2)
			return PFUnknownType;
		else if ([ccnum hasPrefix:@"36"])
			return PFMasterCardType;
		else
			return PFAmexType;
	}
	else if ([ccnum hasPrefix:@"4"]) {
		return PFVisaType;
	}
	else if ([ccnum hasPrefix:@"5"]) {
		return PFMasterCardType;
	}
	else if ([ccnum hasPrefix:@"6"]) {
		return PFDiscoverType;
	}
	
	return PFUnknownType;
}

// These are used in binding enabled state of card type buttons
- (BOOL)isVisaCard { return [self creditCardType] == PFVisaType; }
- (BOOL)isMasterCard { return [self creditCardType] == PFMasterCardType; }
- (BOOL)isAmexCard { return [self creditCardType] == PFAmexType; }
- (BOOL)isDiscoverCard { return [self creditCardType] == PFDiscoverType; }
	
#pragma mark -
#pragma mark Accessors

- (PFAddress *)billingAddress { return billingAddress; }
- (void)setBillingAddress:(PFAddress *)value { if (billingAddress != value) { [billingAddress release]; billingAddress = [value retain]; } }

- (NSString *)creditCardNumber { return creditCardNumber; }
- (void)setCreditCardNumber:(NSString *)value { if (creditCardNumber != value) { [creditCardNumber release]; creditCardNumber = [value copy]; } }

- (NSString *)creditCardSecurityCode { return creditCardSecurityCode; }
- (void)setCreditCardSecurityCode:(NSString *)value { if (creditCardSecurityCode != value) { [creditCardSecurityCode release]; creditCardSecurityCode = [value copy]; } }

- (NSNumber *)creditCardExpirationMonth { return creditCardExpirationMonth; }
- (void)setCreditCardExpirationMonth:(NSNumber *)value { if (creditCardExpirationMonth != value) { [creditCardExpirationMonth release]; creditCardExpirationMonth = [value copy]; } }

- (NSNumber *)creditCardExpirationYear { return creditCardExpirationYear; }
- (void)setCreditCardExpirationYear:(NSNumber *)value { if (creditCardExpirationYear != value) { [creditCardExpirationYear release]; creditCardExpirationYear = [value copy]; } }

#pragma mark -
#pragma mark Validation

- (BOOL)validateCreditCardNumber:(id *)value error:(NSError **)outError
{
	// Do a Luhn algorithm check
	NSString *ccnum = [self p_cleanCreditCardNumber:*value];
	
	// American Express is 15 digits and everything else is at least 16
	if ([ccnum length] < 15 || [ccnum length] > 16) goto fail;
	
	NSInteger sum = 0;
	BOOL alt = NO;
	
	for(NSInteger i = [ccnum length] - 1; i >= 0; i--) {
		NSInteger thedigit = [[ccnum substringWithRange:NSMakeRange(i, 1)] integerValue];
		if (alt) {
			thedigit = 2 * thedigit;
			if (thedigit > 9) {
				thedigit -= 9; 
			}
		}
		sum += thedigit;
		alt = !alt;
	}
	if (sum % 10 == 0) {
		if (outError) *outError = nil;
		return YES;
	}
	
fail:
	*outError = [NSError errorWithDomain:@"PotionStoreFrontErrorDomain"
									code:0 // whatever, it's never used anyway
								userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
										  NSLocalizedString(@"Invalid credit card number", nil),
										  NSLocalizedDescriptionKey,
										  NSLocalizedString(@"Please make sure you typed in the credit card number correctly.", nil),
										  NSLocalizedRecoverySuggestionErrorKey,
										  nil]];
	return NO;
}

- (BOOL)validateCreditCardSecurityCode:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] != 0;
}

- (BOOL)validateCreditCardExpiration:(NSError **)outError
{
	NSInteger month = [[self creditCardExpirationMonth] integerValue];
	NSInteger year = [[self creditCardExpirationYear] integerValue];
	if (month < 1 || month > 12 || year <= 0 || year > 99) {
		if (outError) *outError = nil; // Don't specify error to not show an alert sheet for this simple error condition
		return NO;
	}

	// Validate expiration date
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setMonth:month];
	[comps setYear:year + 2000];
	[comps setDay:2];
	NSDate *expirationDate = [cal dateFromComponents:comps];
	
	comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
	[comps setDay:1];
	
	NSDate *firstDayOfCurrentMonth = [cal dateFromComponents:comps];

	if ([firstDayOfCurrentMonth compare:expirationDate] != NSOrderedAscending) {
		*outError = [NSError errorWithDomain:@"PotionStoreFrontErrorDomain"
										code:1 // whatever, it's never used anyway
									userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
											  NSLocalizedString(@"Your credit card is expired", nil),
											  NSLocalizedDescriptionKey,
											  NSLocalizedString(@"Please make sure that your credit card is not expired and that you typed in the expiration date correctly.", nil),
											  NSLocalizedRecoverySuggestionErrorKey,
											  nil]];
		return NO;
	}
	else {
		return YES;
	}
}

#pragma mark -
#pragma mark Private

- (NSString *)p_cleanCreditCardNumber:(NSString *)value
{
	NSCharacterSet *digitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
	
	// Construct credit card number string using only numbers
	NSMutableString *ccnum = [NSMutableString stringWithCapacity:32];
	for (NSUInteger i = 0; i < [value length]; i++) {
		if ([digitCharacterSet characterIsMember:[value characterAtIndex:i]]) {
			[ccnum appendString:[value substringWithRange:NSMakeRange(i, 1)]];
		}
	}
	
	return ccnum;
}

@end
