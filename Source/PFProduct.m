//
//  PFProduct.m
//  PotionStorefront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import "PFProduct.h"
#import "PotionStorefront.h"

#import "NSInvocationAdditions.h"
#import <JSON/JSON.h>

@implementation PFProduct

@synthesize currencyCode;
@synthesize checked;

//- (id)copyWithZone:(NSZone *)zone
//{
//	PFProduct *copy = [[PFProduct alloc] init];
//	[copy setIdentifierNumber:identifierNumber];
//	[copy setPrice:price];
//	[copy setName:name];
//	[copy setByline:byline];
//	[copy setIconImage:iconImage];
//	[copy setLicenseKey:licenseKey];
//	[copy setQuantity:quantity];
//	[copy
//	return copy;
//}

- (id)init {
	[self setQuantity:[NSNumber numberWithInteger:1]];
	return self;
}

- (void)dealloc {
	[identifierNumber release]; identifierNumber = nil;
	[currencyCode release]; currencyCode = nil;
	[price release]; price = nil;
	[name release]; name = nil;
	[byline release]; byline = nil;
	[iconImage release]; iconImage = nil;
	[licenseKey release]; licenseKey = nil;
	[quantity release]; quantity = nil;
	[radioGroupName release]; radioGroupName = nil;

	[super dealloc];
}

// Helper error constructor used in fetchedProductsFromURL:error:
static NSError *ErrorWithObject(id object) {
	NSString *message = nil;
	if ([object isKindOfClass:[NSError class]])
		message = [NSString stringWithFormat:NSLocalizedString(@"Please make sure that you're connected to the Internet. (Error: %@)", nil), [(NSError *)object localizedDescription]];
	else
		message = [object description];

	return [NSError errorWithDomain:@"PotionStorefrontErrorDomain"	code:2 // whatever, it's never used anyway
						   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									 NSLocalizedString(@"Could not get pricing information through the Internet", nil), NSLocalizedDescriptionKey,
									 message, NSLocalizedRecoverySuggestionErrorKey,
									 nil]];
}

+ (void)beginFetchingProductsFromURL:(NSURL *)aURL delegate:(id)delegate {
	if ([NSThread currentThread] == [NSThread mainThread]) {
		NSInvocation *invocation = [NSInvocation invocationWithTarget:self selector:@selector(beginFetchingProductsFromURL:delegate:)];
		[invocation setArgument:&aURL atIndex:2];
		[invocation setArgument:&delegate atIndex:3];
		[NSThread detachNewThreadSelector:@selector(invoke) toTarget:invocation withObject:nil];
		return;
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Retain the delegate during the call
	[delegate retain];

	NSError *error = nil;
	NSMutableArray *products = nil;

	@try {
		if (aURL == nil) {
			NSLog(@"ERROR -- Cannot get products without a URL");
		}
		else {
			NSArray *array = [NSArray arrayWithContentsOfURL:aURL];
			if (array == nil) {
				error = ErrorWithObject(@"Please make sure that you are connected to the Internet or try again later.");
			}
			else {
				products = [NSMutableArray arrayWithCapacity:[array count]];
				for (NSDictionary *dict in array) {
					[products addObject:[PFProduct productWithDictionary:dict]];
				}
			}
		}
	}
	@catch (NSException *e) {
		NSLog(@"ERROR -- Exception while getting products: %@", e);
		error = ErrorWithObject([NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [e description]]);
	}

	if ([delegate respondsToSelector:@selector(didFinishFetchingProducts:error:)]) {
		NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate selector:@selector(didFinishFetchingProducts:error:)];
		[invocation setArgument:&products atIndex:2];
		[invocation setArgument:&error atIndex:3];
		[invocation invokeOnMainThreadWaitUntilDone:YES];
	}

	[delegate release];

	[pool drain];
}

+ (PFProduct *)productWithDictionary:(NSDictionary *)dictionary {
	PFProduct *p = [[[PFProduct alloc] init] autorelease];
	[p setIdentifierNumber:[dictionary objectForKey:@"id"]];
	[p setName:[dictionary objectForKey:@"name"]];
	[p setByline:[dictionary objectForKey:@"byline"]];
	[p setPrice:[dictionary objectForKey:@"price"]];

	// Check for a image path first to see if we can load it from the bundle
	NSString *iconImagePath = [dictionary objectForKey:@"iconImagePath"];
	if (iconImagePath) {
		iconImagePath = [[NSBundle mainBundle] pathForResource:iconImagePath ofType:nil];
		if (iconImagePath) {
			[p setIconImage:[[[NSImage alloc] initWithContentsOfFile:iconImagePath] autorelease]];
		}
	}

	// Load from the net if you can't get the image through the path
	if ([p iconImage] == nil) {
		NSString *URLString = [dictionary objectForKey:@"iconImageURL"];
		if (URLString) {
			NSURL *iconImageURL = [NSURL URLWithString:URLString];
			if (iconImageURL)
				[p setIconImage:[[[NSImage alloc] initWithContentsOfURL:iconImageURL] autorelease]];
		}
	}

	// Use the default application icon if there's still no icon at this point
	if ([p iconImage] == nil) {
		[p setIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
	}

	[p setRadioGroupName:[dictionary objectForKey:@"radioGroupName"]];

	[p setChecked:[[dictionary objectForKey:@"checked"] boolValue]];
	return p;
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)children { return nil; }

- (NSNumber *)identifierNumber { return identifierNumber; }
- (void)setIdentifierNumber:(NSNumber *)value { if (identifierNumber != value) { [identifierNumber release]; identifierNumber = [value copy]; } }

- (NSNumber *)price { return price; }
- (void)setPrice:(NSNumber *)value { if (price != value) { [price release]; price = [value copy]; } }

+ (NSSet *)keyPathsForValuesAffectingPriceString {
	return [NSSet setWithObjects:@"price", @"currencyCode", nil];
}

- (NSString *)priceString {
	return [NSString stringWithFormat:@"%@%.2lf", [PFOrder currencySymbolForCode:[self currencyCode]], [[self price] floatValue]];
}

- (NSString *)name { return name; }
- (void)setName:(NSString *)value { if (name != value) { [name release]; name = [value copy]; } }

- (NSString *)byline { return byline; }
- (void)setByline:(NSString *)value { if (byline != value) { [byline release]; byline = [value copy]; } }

- (NSImage *)iconImage { return iconImage; }
- (void)setIconImage:(NSImage *)value { if (iconImage != value) { [iconImage release]; iconImage = [value retain]; } }

- (NSString *)licenseKey { return licenseKey; }
- (void)setLicenseKey:(NSString *)value { if (licenseKey != value) { [licenseKey release]; licenseKey = [value copy]; } }

- (NSNumber *)quantity { return quantity; }
- (void)setQuantity:(NSNumber *)value { if (quantity != value) { [quantity release]; quantity = [value copy]; } }

- (NSString *)radioGroupName { return radioGroupName; }
- (void)setRadioGroupName:(NSString *)value { if (radioGroupName != value) { [radioGroupName release]; radioGroupName = [value copy]; } }

@end
