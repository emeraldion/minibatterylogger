//
//  StatusLedValueTransformer.m
//  MiniBatteryLogger
//
//  Created by delphine on 18-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "StatusLedValueTransformer.h"


@implementation StatusLedValueTransformer

- (id)init
{
	return [self initWithMode:MBLStatusLedGoodBadMode];
}

- (id)initWithMode:(int)mode
{
	if (self = [super init])
	{
		[self setMode:mode];
	}
	return self;
}

- (int)mode
{
	return _mode;
}

- (void)setMode:(int)mode
{
	_mode = mode;
}

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

// by default returns value
- (id)transformedValue:(id)value
{
	BOOL status = [value intValue];
	if (_mode == MBLStatusLedGoodBadMode)
	{
		switch (status)
		{
			case NSOnState:
				return [NSImage imageNamed:@"dimple_green"];
			case NSOffState:
			default:
				return [NSImage imageNamed:@"dimple_red"];
		}
	}
	else
	{
		switch (status)
		{
			case NSOnState:
				return [NSImage imageNamed:@"dimple_yellow"];
			case NSOffState:
			default:
				return [NSImage imageNamed:@"dimple_grey"];
		}
	}
}

@end
