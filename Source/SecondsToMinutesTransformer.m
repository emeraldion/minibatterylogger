//
//  SecondsToMinutesTransformer.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "SecondsToMinutesTransformer.h"

@implementation SecondsToMinutesTransformer

- (id)initWithMode:(MBLSecondsToMinutesTransformerMode)aMode
{
	if(self = [super init])
	{
		[self setMode:aMode];
	}
	return self;
}

- (id)init
{
	return [self initWithMode:MBLSecondsToMinutesTransformerNaturalLanguageMode];
}

- (void)setMode:(MBLSecondsToMinutesTransformerMode)aMode
{
	mode = aMode;
}
- (MBLSecondsToMinutesTransformerMode)mode
{
	return mode;
}

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

// by default returns value
- (id)transformedValue:(id)value
{
	NSString *ret = nil;
	int seconds = [value intValue];
	if (mode == MBLSecondsToMinutesTransformerNaturalLanguageMode)
	{
		if (seconds < 0)
		{
			ret = NSLocalizedString(@"Calculating...", @"Calculating...");
		}
		else if (seconds == 0)
		{
			ret = NSLocalizedString(@"Never", @"Never");
		}
		else if (seconds == 3600)
		{
			ret = NSLocalizedString(@"1 hour", @"1 hour");
		}
		else
		{
			ret = [NSString stringWithFormat:NSLocalizedString(@"%d minutes", @"%d minutes"), seconds / 60];
		}
	}
	else if (mode == MBLSecondsToMinutesTransformerInfinityMode)
	{
		if (seconds < 0)
		{
			// Infinity
			ret = [NSString stringWithUTF8String:"\xe2\x88\x9e"];
		}
		else if (seconds > 0)
		{
			int hours = seconds / 3600;
			int minutes = (seconds % 3600) / 60;
			ret = [NSString stringWithFormat:@"%d:%.2d", hours, minutes];
		}
		else // seconds == 0
		{
			// Ellipsis
			ret = [NSString stringWithUTF8String:"\xe2\x80\xa6"];
		}
	}
	else
	{
		if (seconds <= 0)
		{
			ret = @"-:--";
		}
		else
		{
			int hours = seconds / 3600;
			int minutes = (seconds % 3600) / 60;
			ret = [NSString stringWithFormat:@"%d:%.2d", hours, minutes];
		}
	}
	return ret;
}

@end
