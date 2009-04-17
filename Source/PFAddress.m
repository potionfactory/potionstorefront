//
//  PFAddress.m
//  PotionStorefront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFAddress.h"
#import <AddressBook/AddressBook.h>

@implementation PFAddress

- (id)copyWithZone:(NSZone *)zone
{
	PFAddress *copy = [[PFAddress alloc] init];
	copy->firstName = [firstName copy];
	copy->lastName = [lastName copy];
	copy->company = [company copy];
	copy->address1 = [address1 copy];
	copy->address2 = [address2 copy];
	copy->city = [city copy];
	copy->state = [state copy];
	copy->zipcode = [zipcode copy];
	copy->countryCode = [countryCode copy];
	copy->email = [email copy];
	return copy;
}

- (void)dealloc
{
	[firstName release];
	[lastName release];
	[company release];
	[address1 release];
	[address2 release];
	[city release];
	[state release];
	[zipcode release];
	[countryCode release];
	[email release];

	[super dealloc];
}

- (void)fillUsingAddressBookAddressWithLabel:(NSString *)label
{
	ABPerson *me = [[ABAddressBook sharedAddressBook] me];

	if (firstName == nil) [self setFirstName:[me valueForProperty:kABFirstNameProperty]];
	if (lastName == nil) [self setLastName:[me valueForProperty:kABLastNameProperty]];
	if (company == nil) [self setCompany:[me valueForProperty:kABOrganizationProperty]];

	ABMultiValue *addresses = [me valueForProperty:kABAddressProperty];
	id address = nil;

	for (NSUInteger i = 0; i < [addresses count]; i++) {
		if ([[addresses labelAtIndex:i] isEqual:label]) {
			address = [addresses valueAtIndex:i];
			break;
		}
	}

	if (address == nil) {
		address = [addresses valueForIdentifier:[addresses primaryIdentifier]];
	}

	if (address) {
		[self setAddress1:[address valueForKey:kABAddressStreetKey]];
		[self setAddress2:nil];
		[self setCity:[address valueForKey:kABAddressCityKey]];
		[self setState:[address valueForKey:kABAddressStateKey]];
		[self setZipcode:[address valueForKey:kABAddressZIPKey]];
		[self setCountryCode:[[address valueForKey:kABAddressCountryCodeKey] uppercaseString]];
	}

	ABMultiValue *emails = [me valueForProperty:kABEmailProperty];
	for (NSUInteger i = 0; i < [emails count]; i++) {
		if ([[emails labelAtIndex:i] isEqual:label]) {
			[self setEmail:[emails valueAtIndex:i]];
			break;
		}
	}

	if (email == nil) {
		[self setEmail:[emails valueForIdentifier:[emails primaryIdentifier]]];
	}
}

- (void)fillUsingAddressBook
{
	ABPerson *me = [[ABAddressBook sharedAddressBook] me];

	ABMultiValue *addresses = [me valueForProperty:kABAddressProperty];
	NSString *defaultLabel = [addresses labelAtIndex:[addresses indexForIdentifier:[addresses primaryIdentifier]]];

	[self fillUsingAddressBookAddressWithLabel:defaultLabel];
}

#pragma mark -
#pragma mark Accessors

- (NSString *)firstName { return firstName; }
- (void)setFirstName:(NSString *)value { if (firstName != value) { [firstName release]; firstName = [value copy]; } }

- (NSString *)lastName { return lastName; }
- (void)setLastName:(NSString *)value { if (lastName != value) { [lastName release]; lastName = [value copy]; } }

- (NSString *)company { return company; }
- (void)setCompany:(NSString *)value { if (company != value) { [company release]; company = [value copy]; } }

- (NSString *)address1 { return address1; }
- (void)setAddress1:(NSString *)value { if (address1 != value) { [address1 release]; address1 = [value copy]; } }

- (NSString *)address2 { return address2; }
- (void)setAddress2:(NSString *)value { if (address2 != value) { [address2 release]; address2 = [value copy]; } }

- (NSString *)city { return city; }
- (void)setCity:(NSString *)value { if (city != value) { [city release]; city = [value copy]; } }

- (NSString *)state { return state; }
- (void)setState:(NSString *)value { if (state != value) { [state release]; state = [value copy]; } }

- (NSString *)zipcode { return zipcode; }
- (void)setZipcode:(NSString *)value { if (zipcode != value) { [zipcode release]; zipcode = [value copy]; } }

- (NSString *)countryCode { return countryCode; }
- (void)setCountryCode:(NSString *)value { if (countryCode != value) { [countryCode release]; countryCode = [value copy]; } }

- (NSString *)email { return email; }
- (void)setEmail:(NSString *)value { if (email != value) { [email release]; email = [value copy]; } }

#pragma mark -
#pragma mark Validation

- (BOOL)validateFirstName:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)validateLastName:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)validateAddress1:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)validateCity:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)validateState:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)validateZipcode:(id *)value error:(NSError **)outError
{
	if (outError) *outError = nil;
	return [[*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)validateEmail:(id *)value error:(NSError **)outError
{
	// Very basic validation of an email address
	// Passes validation when value is a string, at least 5 letters long, and has a '@' and a '.'
	if (outError) *outError = nil;
	if ([*value isKindOfClass:[NSString class]] == NO) return NO;
	NSString *string = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	BOOL isEmail = (([string length] >= 5) &&
					([string rangeOfString:@"@"].location != NSNotFound) &&
					([string rangeOfString:@"."].location != NSNotFound));
	if (isEmail) {
		return YES;
	}
	else {
		if (outError)
			*outError = [NSError errorWithDomain:@"PotionStorefrontErrorDomain"	code:0 // whatever, it's never used anyway
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												  NSLocalizedString(@"Invalid email address", nil),
												  NSLocalizedDescriptionKey,
												  NSLocalizedString(@"Please make sure you typed in your email address correctly.", nil),
												  NSLocalizedRecoverySuggestionErrorKey,
												  nil]];
		return NO;
	}
}

@end
