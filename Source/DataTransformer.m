//
//  DataTransformer.m
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "DataTransformer.h"


@implementation DataTransformer

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation
{
	return NO;
}

// by default returns value
- (id)transformedValue:(id)value
{
	return [value componentsJoinedByString:@"\n"];
}
	

@end
