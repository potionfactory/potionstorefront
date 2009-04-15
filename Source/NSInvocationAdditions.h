//
//  NSInvocationAdditions.h
//  Tangerine
//
//  Created by Andy Kim on 6/17/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSInvocation (PF_NSInvocationAdditions)
+ (id)invocationWithTarget:(id)target selector:(SEL)selector;
- (void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;
@end
