//
//  PFProduct.m
//  PotionStoreFront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFProduct.h"
#import "PotionStoreFront.h"

#import <JSON/JSON.h>

@implementation PFProduct

@synthesize checked;

- (id)copyWithZone:(NSZone *)zone
{
	PFProduct *copy = [[PFProduct alloc] init];
	[copy setIdentifierNumber:identifierNumber];
	[copy setPrice:price];
	[copy setName:name];
	[copy setIconImage:iconImage];
	[copy setLicenseKey:licenseKey];
	[copy setQuantity:quantity];
	return copy;
}

- (void)dealloc
{
	[identifierNumber release];
	[price release];
	[name release];
	[iconImage release];
	[licenseKey release];
	[quantity release];

	[super dealloc];
}

// Helper error constructor used in fetchedProductsFromURL:
static NSError *ErrorWithObject(id object)
{
	NSString *message = nil;
	if ([object isKindOfClass:[NSError class]])
		message = [NSString stringWithFormat:NSLocalizedString(@"Please make sure that you're connected to the Internet. (Error: %@)", nil), [(NSError *)object localizedDescription]];
	else
		message = [object description];
	
	return [NSError errorWithDomain:@"PotionStoreFrontErrorDomain"	code:2 // whatever, it's never used anyway
						   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									 NSLocalizedString(@"Could not get products", nil), NSLocalizedDescriptionKey,
									 message, NSLocalizedRecoverySuggestionErrorKey,
									 nil]];
}

+ (NSArray *)fetchedProductsFromURL:(NSURL *)URL error:(NSError **)outError
{
//	if ([NSThread currentThread] == [NSThread mainThread]) {
//		[NSThread detachNewThreadSelector:@selector(fetchedProductsFromURL) toTarget:self withObject:URL];
//		return;
//	}

	NSError *error = nil;

	@try {
		if (URL == nil) {
			NSLog(@"ERROR -- Cannot get products without a URL");
			return nil;
		}
		NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:URL];
		NSHTTPURLResponse *response = nil;
		
		[postRequest setHTTPMethod:@"GET"];
		[postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[postRequest setValue:@"PotionStoreFront" forHTTPHeaderField:@"User-Agent"];
		[postRequest setTimeoutInterval:10.0];
		
		NSData *responseData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
		if (error != nil) {
			error = ErrorWithObject(error);
			goto error;
		}

		NSString *responseBody = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
		NSInteger statusCode = [response statusCode];
		
		if (DEBUG_POTION_STORE_FRONT) {
			NSLog(@"URL: %@", URL);
			NSLog(@"STATUS: %ld", statusCode);
			NSLog(@"RESPONSE BODY: %@", responseBody);
		}

		if (statusCode == 200) {
			NSArray *dicts = [responseBody JSONValue];
			NSMutableArray *products = [NSMutableArray arrayWithCapacity:[dicts count]];
			for (NSDictionary *dict in dicts) {
				[products addObject:[PFProduct productWithDictionaryFromPotionStore:dict]];
			}
			if (outError) *outError = nil;
			return products;
		}
		else {
			NSArray *errors = [responseBody JSONValue];
			NSString *errorMessage = [errors componentsJoinedByString:@" "];
			if (errorMessage) {
				error = ErrorWithObject(errorMessage);
			}
			else {
				// It's seriously fucked up if it gets here
				error = ErrorWithObject(@"Failed to parse JSON response from server");
			}
			goto error;
		}
	}
	@catch (NSException *e) {
		NSLog(@"ERROR -- Exception while getting products: %@", e);
		error = ErrorWithObject([NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [e description]]);
		goto error;
	}
	
	if (outError) *outError = nil;
	return nil;
	
error:
	if (outError) *outError = error;
	return nil;
}

+ (PFProduct *)productWithDictionaryFromPotionStore:(NSDictionary *)dictionary
{
	PFProduct *p = [[[PFProduct alloc] init] autorelease];
	[p setIdentifierNumber:[dictionary objectForKey:@"id"]];
	[p setName:[dictionary objectForKey:@"name"]];
	[p setPrice:[dictionary objectForKey:@"price"]];
	NSURL *imageURL = [NSURL URLWithString:[@"http://www.potionfactory.com/" stringByAppendingPathComponent:[dictionary objectForKey:@"image_path"]]];
	[p setIconImage:[[NSImage alloc] initWithContentsOfURL:imageURL]];
	return p;
}
	
#pragma mark -
#pragma mark Accessors

- (NSArray *)children { return nil; }

- (NSNumber *)identifierNumber { return identifierNumber; }
- (void)setIdentifierNumber:(NSNumber *)value { if (identifierNumber != value) { [identifierNumber release]; identifierNumber = [value copy]; } }

- (NSNumber *)price { return price; }
- (void)setPrice:(NSNumber *)value { if (price != value) { [price release]; price = [value copy]; } }

- (NSString *)name { return name; }
- (void)setName:(NSString *)value { if (name != value) { [name release]; name = [value copy]; } }

- (NSImage *)iconImage { return iconImage; }
- (void)setIconImage:(NSImage *)value { if (iconImage != value) { [iconImage release]; iconImage = [value retain]; } }

- (NSString *)licenseKey { return licenseKey; }
- (void)setLicenseKey:(NSString *)value { if (licenseKey != value) { [licenseKey release]; licenseKey = [value copy]; } }

- (NSNumber *)quantity { return quantity; }
- (void)setQuantity:(NSNumber *)value {  if (quantity != value) { [quantity release]; quantity = [value copy]; } }

@end
