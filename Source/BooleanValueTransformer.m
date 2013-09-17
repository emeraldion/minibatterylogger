//
//  BooleanValueTransformer.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "BooleanValueTransformer.h"


@implementation BooleanValueTransformer

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

// by default returns value
- (id)transformedValue:(id)value
{
	int flag = [value boolValue];
	return flag ? NSLocalizedString(@"Yes", @"Yes") :
		NSLocalizedString(@"No", @"No");
}

@end
