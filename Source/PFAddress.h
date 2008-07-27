//
//  PFAddress.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/26/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PFAddress : NSObject <NSCopying>
{
	NSString *firstName;
	NSString *lastName;
	NSString *company;
	NSString *address1;
	NSString *address2;
	NSString *city;
	NSString *state;
	NSString *zipcode;
	NSString *countryCode;
	NSString *email;
}

- (void)fillUsingAddressBookAddressWithLabel:(NSString *)label;
- (void)fillUsingAddressBook;

#pragma mark Accessors

- (NSString *)firstName;
- (void)setFirstName:(NSString *)value;

- (NSString *)lastName;
- (void)setLastName:(NSString *)value;

- (NSString *)company;
- (void)setCompany:(NSString *)value;

- (NSString *)address1;
- (void)setAddress1:(NSString *)value;

- (NSString *)address2;
- (void)setAddress2:(NSString *)value;

- (NSString *)city;
- (void)setCity:(NSString *)value;

- (NSString *)state;
- (void)setState:(NSString *)value;

- (NSString *)zipcode;
- (void)setZipcode:(NSString *)value;

- (NSString *)countryCode;
- (void)setCountryCode:(NSString *)value;

- (NSString *)email;
- (void)setEmail:(NSString *)value;

@end
