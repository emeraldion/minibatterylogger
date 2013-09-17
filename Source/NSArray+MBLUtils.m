//
//  NSArray+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 13-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "NSArray+MBLUtils.h"


@implementation NSArray (MBLUtils)

+ (void)testStatisticsSuite
{
	NSArray *myArr = [NSArray arrayWithObjects:[NSNumber numberWithDouble:5461],
		[NSNumber numberWithDouble:3901],
		[NSNumber numberWithDouble:5043],
		[NSNumber numberWithDouble:5069],
		[NSNumber numberWithDouble:5125],
		[NSNumber numberWithDouble:5017],
		[NSNumber numberWithDouble:5145],
		[NSNumber numberWithDouble:4314],
		[NSNumber numberWithDouble:4698],
		[NSNumber numberWithDouble:5134],
		[NSNumber numberWithDouble:4874],
		[NSNumber numberWithDouble:4961],
		[NSNumber numberWithDouble:4711],
		[NSNumber numberWithDouble:5136],
		[NSNumber numberWithDouble:4638],
		[NSNumber numberWithDouble:5415],
		[NSNumber numberWithDouble:4003],
		[NSNumber numberWithDouble:5155],
		[NSNumber numberWithDouble:4821],
		[NSNumber numberWithDouble:4809],
		[NSNumber numberWithDouble:5025],
		[NSNumber numberWithDouble:4798],
		[NSNumber numberWithDouble:4959],
		[NSNumber numberWithDouble:4881],
		[NSNumber numberWithDouble:5192],
		[NSNumber numberWithDouble:5086],
		[NSNumber numberWithDouble:5048],
		[NSNumber numberWithDouble:5048],
		[NSNumber numberWithDouble:5177],
		[NSNumber numberWithDouble:4958],
		[NSNumber numberWithDouble:4952],
		[NSNumber numberWithDouble:4872],
		[NSNumber numberWithDouble:4668],
		[NSNumber numberWithDouble:5125],
		[NSNumber numberWithDouble:5376],
		[NSNumber numberWithDouble:5291],
		[NSNumber numberWithDouble:4787],
		[NSNumber numberWithDouble:4671],
		[NSNumber numberWithDouble:4863],
		[NSNumber numberWithDouble:4323],
		[NSNumber numberWithDouble:5111],
		[NSNumber numberWithDouble:4201],
		[NSNumber numberWithDouble:4743],
		[NSNumber numberWithDouble:5056],
		[NSNumber numberWithDouble:5238],
		[NSNumber numberWithDouble:4867],
		[NSNumber numberWithDouble:4754],
		[NSNumber numberWithDouble:4868],
		[NSNumber numberWithDouble:5201],
		[NSNumber numberWithDouble:4807],
		[NSNumber numberWithDouble:4981],
		[NSNumber numberWithDouble:4824],
		[NSNumber numberWithDouble:5133],
		[NSNumber numberWithDouble:5152],
		[NSNumber numberWithDouble:5081],
		[NSNumber numberWithDouble:368],
		[NSNumber numberWithDouble:5081],
		[NSNumber numberWithDouble:4987],
		[NSNumber numberWithDouble:5110],
		[NSNumber numberWithDouble:5133],
		[NSNumber numberWithDouble:5181],
		[NSNumber numberWithDouble:4714],
		[NSNumber numberWithDouble:5101],
		[NSNumber numberWithDouble:4828],
		[NSNumber numberWithDouble:4711],
		[NSNumber numberWithDouble:5073],
		nil];
	NSLog(@"%f", [myArr meanValue]);
	NSLog(@"%f", [myArr variance]);
	NSLog(@"%f", [myArr covariance:myArr]);
}

- (double)meanValue
{
	double buf;
	int i, len;

	buf = 0.0;
	len = [self count];
	for (i = 0; i < len; i++)
	{
		buf += [[self objectAtIndex:i] doubleValue];
	}
	return buf / len;
}

- (double)variance
{
	double buf, mean;
	int i, len;
	
	buf = 0.0;
	mean = [self meanValue];
	len = [self count];
	for (i = 0; i < len; i++)
	{
		buf += pow([[self objectAtIndex:i] doubleValue] - mean, 2);
	}
	return buf / len;	
}

- (double)covariance:(NSArray *)other
{
	double buf, xMean, yMean;
	int i, len;
	
	buf = 0.0;
	len = [self count];
	
	// Calculating mean values
	xMean = [self meanValue];
	yMean = [other meanValue];
	if (len != [other count])
	{
		NSLog(@"Error: attempt to calculate covariance on two series of different size");
		return 0.0;
	}
	for (i = 0; i < len; i++)
	{
		buf += ([[self objectAtIndex:i] doubleValue] - xMean) *
		([[other objectAtIndex:i] doubleValue] - yMean);
	}
	return (buf / len);
}

- (NSString *)CSVString
{
	NSString *CSVStr = [MBLEvent CSVHeader];
	int i, len = [self count];
	for (i = 0; i < len; i++)
	{
		CSVStr = [CSVStr stringByAppendingString:[[self objectAtIndex:i] CSVLine]];
	}
	return CSVStr;
}

- (NSString *)CSVStringMSExcel
{
	NSString *CSVStr = [MBLEvent CSVHeaderMSExcel];
	int i, len = [self count];
	for (i = 0; i < len; i++)
	{
		CSVStr = [CSVStr stringByAppendingString:[[self objectAtIndex:i] CSVLineMSExcel]];
	}
	return CSVStr;
}

- (NSArray *)arrayDifference:(NSArray *)other
{
	/**
	 *	This method returns objects from self that are NOT in other
	 */
	
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	int i, n = 0;
	id obj;
	for (i = 0; i < [self count]; i++)
	{
		obj = [self objectAtIndex:i];
		if (![other containsObject:obj])
		{
			[arr insertObject:obj
					  atIndex:n++];
		}
	}
	NSArray *ret = [arr copy];
	[arr release];
	return ret;
}

@end

@implementation NSArray (RemoveDuplicates)

- (NSArray *)arrayByRemovingDuplicates
{
	NSMutableArray *arr = [self mutableCopy];
	[arr removeDuplicates];
	NSArray *unique = [arr copy];
	[arr release];
	return [unique autorelease];
}

@end

@implementation NSMutableArray (RemoveDuplicates)

- (void)removeDuplicates
{
	int pos = 0;
	while (pos < [self count])
	{
		id obj = [self objectAtIndex:pos];
		NSRange rng = NSMakeRange(pos + 1, [self count] - pos - 1);
		[self removeObject:obj inRange:rng];
		pos++;
	}
}

@end
