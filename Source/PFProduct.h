//
//  PFProduct.h
//  PotionStorefront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// In PotionStorefront this class serves as both a product and a line item

@class PFOrder;

@interface PFProduct : NSObject //<NSCopying> {
	NSNumber *identifierNumber;
	NSString *currencyCode;
	NSNumber *price;
	NSString *name;
	NSString *byline;
	NSImage *iconImage;
	NSString *licenseKey;
	NSNumber *quantity;

	// Checked products get placed into the order
	NSString *radioGroupName;
	BOOL checked;
}

+ (void)beginFetchingProductsFromURL:(NSURL *)URL delegate:(id)object;
+ (PFProduct *)productWithDictionary:(NSDictionary *)dictionary;

- (NSArray *)children;

@property (copy) NSString *currencyCode;
@property (assign) BOOL checked;

// Accessors
- (NSNumber *)identifierNumber;
- (void)setIdentifierNumber:(NSNumber *)value;

- (NSNumber *)price;
- (void)setPrice:(NSNumber *)value;

- (NSString *)priceString;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)byline;
- (void)setByline:(NSString *)value;

- (NSImage *)iconImage;
- (void)setIconImage:(NSImage *)value;

- (NSString *)licenseKey;
- (void)setLicenseKey:(NSString *)value;

- (NSNumber *)quantity;
- (void)setQuantity:(NSNumber *)value;

- (NSString *)radioGroupName;
- (void)setRadioGroupName:(NSString *)value;

@end


@interface NSObject (PFProductDelegate)
- (void)didFinishFetchingProducts:(NSArray *)products error:(NSError *)error;
@end
