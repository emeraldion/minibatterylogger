//
//  MBLEvent.m
//  MiniBatteryLogger
//
//  Created by delphine on 7-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "MBLEvent.h"

NSString *MBLEventType = @"MBLEventType";

@implementation MBLEvent

- (id)init
{
	if (self = [super init])
	{
		date = [[NSCalendarDate alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[date release];
	[super dealloc];
}

- (NSString *)type
{
	return MBLEventType;
}

- (NSCalendarDate *)date
{
	return date;
}

- (void)setDate:(NSCalendarDate *)d
{
	[d retain];
	[date release];
	date = d;
}

// @protocol MBLEvent (NSCoding)

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		[self setDate:[coder decodeObjectForKey:@"date"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:date forKey:@"date"];
}

@end

@implementation MBLEvent (CSVExporting)

+ (NSString *)CSVHeader
{
	return [self CSVHeaderUsingSeparator:@","];
}

- (NSString *)CSVLine
{
	return [self CSVLineUsingSeparator:@","];
}

+ (NSString *)CSVHeaderMSExcel
{
	return [self CSVHeaderUsingSeparator:@";"];
}

- (NSString *)CSVLineMSExcel
{
	return [self CSVLineUsingSeparator:@";"];
}

+ (NSString *)CSVHeaderUsingSeparator:(NSString *)sep;
{
	return [NSString stringWithFormat:@"\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"%@\"\n",
		NSLocalizedString(@"Date", @"Date"),
		sep,
		NSLocalizedString(@"Type", @"Type"),
		sep,
		NSLocalizedString(@"Charge", @"Charge"),
		sep,
		NSLocalizedString(@"Voltage", @"Voltage"),
		sep,
		NSLocalizedString(@"Amperage", @"Amperage"),
		sep,
		NSLocalizedString(@"Capacity", @"Capacity"),
		sep,
		NSLocalizedString(@"Max Capacity", @"Max Capacity"),
		sep,
		NSLocalizedString(@"Original Capacity", @"Original Capacity"),
		sep,
		NSLocalizedString(@"Cycle Count", @"Cycle Count"),
		sep,
		NSLocalizedString(@"Plugged", @"Plugged"),
		sep,
		NSLocalizedString(@"Charging", @"Charging")];
}

- (NSString *)CSVLineUsingSeparator:(NSString *)sep
{
	return [NSString stringWithFormat:@"\"%@\"%@\"%@\"%@%@%@%@%@%@%@%@%@\n",
		[self date],
		sep,
		[self type],
		sep,
		sep,
		sep,
		sep,
		sep,
		sep,
		sep,
		sep,
		sep];
}

@end
