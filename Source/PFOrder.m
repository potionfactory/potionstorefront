//
//  PFOrder.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFOrder.h"
#import "PFAddress.h"
#import "PotionStoreFront.h"

#import <JSON/JSON.h>

#import "NSInvocationAdditions.h"

@implementation PFOrder

@synthesize lineItems;

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isVisaCard"];
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isMasterCard"];
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isAmexCard"];
	[self setKeys:[NSArray arrayWithObject:@"creditCardNumber"] triggerChangeNotificationsForDependentKey:@"isDiscoverCard"];
	[self setKeys:[NSArray arrayWithObject:@"lineItems"] triggerChangeNotificationsForDependentKey:@"totalAmount"];
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
	
	[submitURL release];
	
	[super dealloc];
}

- (NSDictionary *)dictionaryRepresentationForPotionStore
{
	PFAddress *a = [self billingAddress];
	NSString *creditCard = [self creditCardTypeString];
	NSAssert(creditCard != nil, @"credit card type should not be unknown at this point");

	NSMutableDictionary *orderDict = [NSMutableDictionary dictionary];

	@try {
		// This should give no trouble by the time we're here since everything
		// should be validated already. Putting it inside @try just in case though.
		[orderDict setObject:[a firstName]	forKey:@"first_name"];
		[orderDict setObject:[a lastName]	forKey:@"last_name"];
		[orderDict setObject:[NSString stringWithFormat:@"%@ %@", [a firstName], [a lastName]] forKey:@"licensee_name"];
		if ([a company]) [orderDict setObject:[a company]	forKey:@"company"];
		[orderDict setObject:[a address1]	forKey:@"address1"];
		if ([a address2]) [orderDict setObject:[a address2]	forKey:@"address2"];
		[orderDict setObject:[a city]		forKey:@"city"];
		[orderDict setObject:[a state]		forKey:@"state"];
		[orderDict setObject:[a zipcode]	forKey:@"zipcode"];
		[orderDict setObject:[a countryCode] forKey:@"country"];
		[orderDict setObject:[a email]		forKey:@"email"];
		[orderDict setObject:creditCard		forKey:@"payment_type"];
		[orderDict setObject:[self cleanedCreditCardNumber]			forKey:@"cc_number"];
		[orderDict setObject:[self creditCardSecurityCode]		forKey:@"cc_code"];
		[orderDict setObject:[[self creditCardExpirationMonth] stringValue]	forKey:@"cc_month"];
		[orderDict setObject:[[self creditCardExpirationYear] stringValue] forKey:@"cc_year"];
		
		NSMutableDictionary *itemsDict = [NSMutableDictionary dictionaryWithCapacity:[lineItems count]];
		for (PFProduct *item in lineItems) {
			// Items dictionary uses the product_id as the key and the quantity as the value
			// I KNOW this is ugly but it's a carry over from when I first wrote Potion Store.
			[itemsDict setObject:[NSNumber numberWithInteger:1] forKey:[[item identifierNumber] stringValue]];
		}

		[orderDict setObject:itemsDict forKey:@"items"];
	}
	@catch (NSException *e) {
		NSLog(@"Got exception while building order dictionary: %@", e);
	}

	return orderDict;
}

// Helper error constructor used in submitInBackground
static NSError *ErrorWithObject(id object)
{
	NSString *message = nil;
	if ([object isKindOfClass:[NSError class]]) {
		message = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [(NSError *)object localizedDescription]];
	}
	else if ([object isKindOfClass:[NSException class]]) {
		return ErrorWithObject([NSString stringWithFormat:NSLocalizedString(@"Exception: %@", nil), [object description]]);
	}
	else {
		message = [object description];
	}
	
	return [NSError errorWithDomain:@"PotionStoreFrontErrorDomain"
							   code:0
						   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									 NSLocalizedString(@"Could not process order", nil), NSLocalizedDescriptionKey,
									 message, NSLocalizedRecoverySuggestionErrorKey,
									 nil]];
}

static NSError *ErrorWithJSONResponse(NSString *string)
{
	NSArray *array = [string JSONValue];
	if ([array isKindOfClass:[NSArray class]] == NO) goto fail;
	@try {
		NSMutableArray *messages = [NSMutableArray array];
		for (NSString *msg in array) {
			if (![msg hasSuffix:@"."] && ![msg hasSuffix:@"?"] && ![msg hasSuffix:@"!"])
				[messages addObject:[msg stringByAppendingString:@"."]];
			else
				[messages addObject:msg];
		}
		return ErrorWithObject([messages componentsJoinedByString:@" "]);
	}
	@catch (NSException * e) {
		NSLog(@"ERROR -- Got exception while trying to parse JSON error response:", e);
		return ErrorWithObject(e);
	}
fail:
	return ErrorWithObject(@"Could not process order due to an unexpected error. Please try again later.");
}

- (void)submitInBackground
{
	if ([NSThread currentThread] == [NSThread mainThread]) {
		[NSThread detachNewThreadSelector:@selector(submitInBackground) toTarget:self withObject:nil];
		return;
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error = nil;

	@try {
		if ([self submitURL] == nil) {
			NSLog(@"ERROR -- Cannot submit order without a URL");
			return;
		}
		NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[self submitURL]];
		NSHTTPURLResponse *response = nil;
		NSString *json = [[self dictionaryRepresentationForPotionStore] JSONRepresentation];

		if (DEBUG_POTION_STORE_FRONT) {
			NSLog(@"SENDING JSON: %@", json);
		}

		[postRequest setHTTPMethod:@"POST"];
		[postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[postRequest setValue:@"PotionStoreFront" forHTTPHeaderField:@"User-Agent"];
		[postRequest setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
		[postRequest setTimeoutInterval:10.0];
		
		NSData *responseData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
		if (error != nil) {
			error = ErrorWithObject(error);
			goto error;
		}

		NSString *responseBody = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
		NSInteger statusCode = [response statusCode];

		if (DEBUG_POTION_STORE_FRONT) {
			NSLog(@"STATUS: %ld", statusCode);
			NSLog(@"REPLY BODY: %@", responseBody);
		}

		if (statusCode == 200) {
			NSDictionary *responseOrder = [responseBody JSONValue];
			if (DEBUG_POTION_STORE_FRONT) {
				debug(@"RESPONSE ORDER: %@", responseOrder);
			}
			
			NSInteger licensedCount = 0;
			
			// Update license key from returned order
			for (PFProduct *myitem in lineItems) {
				for (NSDictionary *dict in [responseOrder objectForKey:@"line_items"]) {
					if ([[dict objectForKey:@"product_id"] isEqual:[myitem identifierNumber]]) {
						PFAssert([myitem checked], @"Only purchased items should be getting license keys");
						[myitem setLicenseKey:[dict objectForKey:@"license_key"]];
						licensedCount += 1;
					}
				}
			}
			
			PFAssert(licensedCount >= 1, @"There should be at least one licensed product when an order is successful");
			
			if ([[self delegate] respondsToSelector:@selector(orderDidFinishSubmitting:)]) {
				[[self delegate] performSelectorOnMainThread:@selector(orderDidFinishSubmitting:) withObject:self waitUntilDone:YES];
			}
		}
		else {
			error = ErrorWithJSONResponse(responseBody);
			goto error;
		}
	}
	@catch (NSException *e) {
		NSLog(@"ERROR -- Exception while submitting order: %@", e);
		error = ErrorWithObject(e);
		goto error;
	}

	[pool release];
	return;

error:
	if ([[self delegate] respondsToSelector:@selector(order:failedWithError:)]) {
		NSInvocation *invocation = [NSInvocation invocationWithTarget:[self delegate] selector:@selector(order:failedWithError:)];
		[invocation setArgument:&self atIndex:2];
		[invocation setArgument:&error atIndex:3];
		[invocation invokeOnMainThreadWaitUntilDone:YES];
	}
		
	[pool release];
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

- (NSString *)creditCardTypeString
{
	switch ([self creditCardType]) {
		case PFVisaType:
			return @"Visa";
		case PFMasterCardType:
			return @"MasterCard";
		case PFAmexType:
			return @"Amex";
		case PFDiscoverType:
			return @"Discover";
		default:
			return nil;
	}
}

// These are used in binding enabled state of card type buttons
- (BOOL)isVisaCard { return [self creditCardType] == PFVisaType; }
- (BOOL)isMasterCard { return [self creditCardType] == PFMasterCardType; }
- (BOOL)isAmexCard { return [self creditCardType] == PFAmexType; }
- (BOOL)isDiscoverCard { return [self creditCardType] == PFDiscoverType; }
	
#pragma mark -
#pragma mark Accessors

- (id)delegate { return delegate; }
- (void)setDelegate:(id)object { delegate = object; }

- (CGFloat)totalAmount
{
	CGFloat total = 0;
	for (PFProduct *product in lineItems) {
		total += [[product price] floatValue];
	}
	
	return total;
}

- (NSURL *)submitURL { return submitURL; }
- (void)setSubmitURL:(NSURL *)value { if (submitURL != value) { [submitURL release]; submitURL = [value copy]; } }

- (PFAddress *)billingAddress { return billingAddress; }
- (void)setBillingAddress:(PFAddress *)value { if (billingAddress != value) { [billingAddress release]; billingAddress = [value retain]; } }

- (NSString *)creditCardNumber { return creditCardNumber; }
- (void)setCreditCardNumber:(NSString *)value { if (creditCardNumber != value) { [creditCardNumber release]; creditCardNumber = [value copy]; } }

- (NSString *)creditCardSecurityCode { return creditCardSecurityCode; }
- (void)setCreditCardSecurityCode:(NSString *)value { if (creditCardSecurityCode != value) { [creditCardSecurityCode release]; creditCardSecurityCode = [value copy]; } }

- (NSNumber *)creditCardExpirationMonth { return creditCardExpirationMonth; }
- (void)setCreditCardExpirationMonth:(id)value
{
	if (creditCardExpirationMonth != value) {
		[creditCardExpirationMonth release];
		if ([value isKindOfClass:[NSNumber class]])
			creditCardExpirationMonth = [value copy];
		else if ([value isKindOfClass:[NSString class]])
			creditCardExpirationMonth = [[NSNumber numberWithInteger:[value integerValue]] retain];
		else
			creditCardExpirationMonth = [value retain];
	}
}

- (NSNumber *)creditCardExpirationYear { return creditCardExpirationYear; }
- (void)setCreditCardExpirationYear:(id)value
{
	if (creditCardExpirationYear != value) { 
		[creditCardExpirationYear release];
		if ([value isKindOfClass:[NSNumber class]])
			creditCardExpirationYear = [value copy];
		else if ([value isKindOfClass:[NSString class]])
			creditCardExpirationYear = [[NSNumber numberWithInteger:[value integerValue]] retain];
		else
			creditCardExpirationYear = [value retain];
	}
}

#pragma mark -
#pragma mark Validation

- (BOOL)validateCreditCardNumber:(id *)value error:(NSError **)outError
{
	// Do a Luhn algorithm check

	// 1. Double all the alternating numbers starting from the end.
	// 2. If their sum isn't divisible by 10, it's a bad card number

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
	*outError = [NSError errorWithDomain:@"PotionStoreFrontErrorDomain"	code:0 // whatever, it's never used anyway
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
		*outError = [NSError errorWithDomain:@"PotionStoreFrontErrorDomain" code:1 // whatever, it's never used anyway
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
