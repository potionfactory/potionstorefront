//
//  PFProduct.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// In PotionStoreFront this class serves as both a product and a line item

@interface PFProduct : NSObject <NSCopying>
{
	NSNumber *identifierNumber;
	NSNumber *price;
	NSString *name;
	NSImage *iconImage;
	NSString *licenseKey;
	NSNumber *quantity;
	
	// Checked products get placed into the order
	BOOL checked;
}

+ (NSArray *)fetchedProductsFromURL:(NSURL *)URL error:(NSError **)outError;
+ (PFProduct *)productWithDictionaryFromPotionStore:(NSDictionary *)dictionary;

- (NSArray *)children;

@property(assign) BOOL checked;

// Accessors
- (NSNumber *)identifierNumber;
- (void)setIdentifierNumber:(NSNumber *)value;

- (NSNumber *)price;
- (void)setPrice:(NSNumber *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSImage *)iconImage;
- (void)setIconImage:(NSImage *)value;

- (NSString *)licenseKey;
- (void)setLicenseKey:(NSString *)value;

- (NSNumber *)quantity;
- (void)setQuantity:(NSNumber *)value;

@end
