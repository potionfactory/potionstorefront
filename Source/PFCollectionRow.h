//
//  PFCollectionRow.h
//  PotionStoreFront
//
//  Created by Andy Kim on 7/27/08.
//  Copyright 2008 Potion Factory LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCollectionRowView : NSView
{
	NSCollectionViewItem *item;
}

@property(assign) NSCollectionViewItem *item;

@end



@interface PFCollectionViewItem : NSCollectionViewItem
{
}

- (IBAction)toggleItem:(id)sender;

@end


@interface PFClickThroughImageView : NSImageView
{
}
@end
