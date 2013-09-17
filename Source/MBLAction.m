//
//  MBLAction.m
//  MiniBatteryLogger
//
//  Created by delphine on 22-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLAction.h"


@implementation MBLAction

- (id)init
{
	if (self = [super init])
	{
		_params = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_params release];
	[super dealloc];
}

- (BOOL)isApplicable
{
	return YES;
}

- (void)perform
{
	// does nothing
	;
}

- (BOOL)performIfApplicable
{
	BOOL applicable = [self isApplicable];
	if (applicable)
	{
		[self perform];
	}
	return applicable;
}

- (void)setParams:(NSDictionary *)params
{
	[_params autorelease];
	_params = [params mutableCopy];
}

- (NSDictionary *)params
{
	return _params;
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4

- (void)setPredicate:(NSPredicate *)predicate
{
	[_params setObject:predicate
				forKey:@"predicate"];
}

- (NSPredicate *)predicate
{
	return [_params objectForKey:@"predicate"];
}

#endif

- (id)initWithCoder:(NSCoder *)aCoder
{
	if (self = [super init])
	{
		[self setParams:[aCoder decodeObjectForKey:@"params"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if ([super respondsToSelector:@selector(encodeWithCoder:)])
	{
		[super encodeWithCoder:aCoder];
	}
	[aCoder encodeObject:_params
				  forKey:@"params"];
}

@end
