//
//  NSInvocationAdditions.m
//  Tangerine
//
//  Created by Andy Kim on 6/17/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "NSInvocationAdditions.h"


@implementation NSInvocation (PF_NSInvocationAdditions)
+ (id)invocationWithTarget:(id)target selector:(SEL)selector
{
	if (target == nil || selector == nil) return nil;

	NSMethodSignature *signature = nil;

	signature = [target methodSignatureForSelector:selector];

	if (signature == nil) return nil;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:target];
	[invocation setSelector:selector];
	return invocation;
}

- (void)invokeOnMainThreadWaitUntilDone:(BOOL)wait
{
	[self performSelectorOnMainThread:@selector(invoke)
						   withObject:nil
						waitUntilDone:wait];
}

@end
