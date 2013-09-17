//
//  BatterySnapshot.m
//  MiniBatteryLogger
//
//  Created by delphine on 13-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "BatterySnapshot.h"


@implementation BatterySnapshot

- (id)initWithBattery:(Battery *)batt date:(NSCalendarDate *)aDate;
{
	if (self = [super init])
	{
		[self setBattery:batt];
		[self setDate:aDate];
	}
	return self;	
}

- (id)initWithBattery:(Battery *)batt
{
	return [self initWithBattery:batt date:[NSCalendarDate calendarDate]];
}

- (id)init
{
	return [self initWithBattery:[Battery battery]];
}

+ (id)snapshot
{
	return [[[BatterySnapshot alloc] init] autorelease];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		[self setBattery:[coder decodeObjectForKey:@"battery"]];
		[self setDate:[coder decodeObjectForKey:@"date"]];
		[self setComment:[coder decodeObjectForKey:@"comment"]];
	}
	return self;
}

- (void)dealloc
{
	[date release];
	[battery release];
	[comment release];
	[super dealloc];	
}

- (BOOL)isEqual:(id)anObj
{
	return [anObj isKindOfClass:[self class]] &&
	[[anObj date] isEqual:date] &&
	[[anObj comment] isEqual:comment] &&
	([[anObj battery] maxCapacity] == [battery maxCapacity]);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:battery forKey:@"battery"];
	[coder encodeObject:date forKey:@"date"];
	[coder encodeObject:comment forKey:@"comment"];
}

- (void)setDate:(NSCalendarDate *)d
{
	[d retain];
	[date release];
	date = d;
}

- (NSCalendarDate *)date
{
	return date;
}

- (void)setBattery:(Battery *)b
{
	[b retain];
	[battery release];
	battery = b;
}

- (Battery *)battery
{
	return battery;
}

- (void)setComment:(NSString *)c
{
	[c retain];
	[comment release];
	comment = c;
}

- (NSString *)comment
{
	return comment;
}

- (NSComparisonResult)compareSnapshot:(BatterySnapshot *)other mode:(int)mode
{
	int left, right;
	switch (mode)
	{
		case MBLSnapshotDateAscending:
			left = [[self date] timeIntervalSinceReferenceDate];
			right = [[other date] timeIntervalSinceReferenceDate];
			break;
		case MBLSnapshotDateDescending:
			left = [[other date] timeIntervalSinceReferenceDate];
			right = [[self date] timeIntervalSinceReferenceDate];
			break;
		case MBLSnapshotMaxCapacityAscending:
			left = [[self battery] maxCapacity];
			right = [[other battery] maxCapacity];
			break;
		case MBLSnapshotMaxCapacityDescending:
			left = [[other battery] maxCapacity];
			right = [[self battery] maxCapacity];
			break;
		case MBLSnapshotCycleCountAscending:
			left = [[self battery] cycleCount];
			right = [[other battery] cycleCount];
			break;
		case MBLSnapshotCycleCountDescending:
			left = [[other battery] cycleCount];
			right = [[self battery] cycleCount];
			break;
	}
	
	return (left == right ? NSOrderedSame : (left < right ? NSOrderedAscending : NSOrderedDescending));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Battery: %@\nDate: %@", [self battery], [self date]];
}

#pragma mark === Comparison methods ===

- (NSComparisonResult)compareSnapshotCycleCountAscending:(BatterySnapshot *)other
{
	return [self compareSnapshot:other mode:MBLSnapshotCycleCountAscending];
}

- (NSComparisonResult)compareSnapshotCycleCountDescending:(BatterySnapshot *)other
{
	return [self compareSnapshot:other mode:MBLSnapshotCycleCountDescending];
}

- (NSComparisonResult)compareSnapshotMaxCapacityAscending:(BatterySnapshot *)other
{
	return [self compareSnapshot:other mode:MBLSnapshotMaxCapacityAscending];
}

- (NSComparisonResult)compareSnapshotMaxCapacityDescending:(BatterySnapshot *)other
{
	return [self compareSnapshot:other mode:MBLSnapshotMaxCapacityDescending];
}

- (NSComparisonResult)compareSnapshotDateAscending:(BatterySnapshot *)other
{
	return [self compareSnapshot:other mode:MBLSnapshotDateAscending];
}

- (NSComparisonResult)compareSnapshotDateDescending:(BatterySnapshot *)other
{
	return [self compareSnapshot:other mode:MBLSnapshotDateDescending];
}


@end
