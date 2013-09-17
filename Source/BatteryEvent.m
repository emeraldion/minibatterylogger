//
//  BatteryEvent.m
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "BatteryEvent.h"

/**
*	Memo
 *
 *	Flag mask Bit Meaning
 *	---------- --- ---------------------------------------
 *	0x00000001 0 A charger is connected to the computer.
 *	0x00000002 1 The battery is charging.
 *	0x00000004 2 A battery is installed.
 *	0x00000008 3 An UPS, uninteruptable power supply, is installed.
 *	0x00000010 4 The battery at or below the set warning level.
 *	0x00000020 5 The battery depleted (empty).
 *	0x00000040 6 There is no charging capability. (stationary system?)
 *	0x00000080 7 There is a raw "low battery" signal from the electronics inside the battery.
 *
 */
#define PLUGGED_FLAG 0x00000001
#define CHARGING_FLAG 0x00000002
#define INSTALLED_FLAG 0x00000004

NSString *MBLBatteryEventType = @"MBLBatteryEventType";
//NSString *MBLSleepEventType = @"MBLSleepEventType";
//NSString *MBLWakeUpEventType = @"MBLWakeUpEventType";

const NSString *kMBLChargeKey					= (NSString *)CFSTR(kIOPSCurrentCapacityKey);
const NSString *kMBLCycleCountKey				= @"Cycle Count";
const NSString *kMBLCapacityKey					= (NSString *)CFSTR(kIOPMPSCurrentCapacityKey);
const NSString *kMBLMaxCapacityKey				= @"Capacity";
const NSString *kMBLDesignCapacityKey			= (NSString *)CFSTR(kIOPMPSDesignCapacityKey);
const NSString *kMBLAbsoluteMaxCapacityKey		= @"AbsoluteMaxCapacity";
const NSString *kMBLAmperageKey					= @"Amperage";
const NSString *kMBLVoltageKey					= @"Voltage";
const NSString *kMBLIsPresentKey				= (NSString *)CFSTR(kIOPSIsPresentKey);
const NSString *kMBLPowerSourceStateKey			= (NSString *)CFSTR(kIOPSPowerSourceStateKey);
const NSString *kMBLPowerSourceACValue			= (NSString *)CFSTR(kIOPSACPowerValue);
const NSString *kMBLPowerSourceBatteryValue		= (NSString *)CFSTR(kIOPSBatteryPowerValue);
const NSString *kMBLChargingKey					= (NSString *)CFSTR(kIOPSIsChargingKey);
const NSString *kMBLTimeToEmptyKey				= (NSString *)CFSTR(kIOPSTimeToEmptyKey);
const NSString *kMBLTimeToFullKey				= (NSString *)CFSTR(kIOPSTimeToFullChargeKey);
const NSString *kMBLFlagsKey					= @"Flags";


@implementation BatteryEvent

+ (id)batteryEventWithDetails:(NSDictionary *)dict index:(int)idx time:(NSCalendarDate *)date
{
	BatteryEvent *evt = [[BatteryEvent alloc] initWithDetails:dict
														index:idx
														 time:date];
	return [evt autorelease];
}

- (id)initWithDetails:(NSDictionary *)dict index:(int)idx time:(NSCalendarDate *)time
{
	if (self = [super init])
	{
		[self setDetails:dict];
		[self setDate:time];
		index = idx;
	}
	return self;
}

- (void)dealloc
{
	[details release];
	[super dealloc];
}

- (NSString *)type
{
	return MBLBatteryEventType;
}

- (int)charge
{
	if ([details valueForKey:kMBLChargeKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLChargeKey] intValue];
	}
	else
	{
		return floor(100.0 * [(NSNumber *)[details valueForKey:@"Current"] intValue] /
					 [(NSNumber *)[details valueForKey:kMBLMaxCapacityKey] intValue]);
	}		
}

- (int)capacity
{
	if ([details valueForKey:kMBLCapacityKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLCapacityKey] intValue];
	}
	else if ([details valueForKey:@"Current"])
	{
		return [(NSNumber *)[details valueForKey:@"Current"] intValue];
	}
	else
	{
		return -1;
	}
}

- (int)maxCapacity
{
	if ([details valueForKey:kMBLMaxCapacityKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLMaxCapacityKey] intValue];
	}
	else
	{
		return -1;
	}
}

- (int)designCapacity
{
	if ([details valueForKey:kMBLDesignCapacityKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLDesignCapacityKey] intValue];
	}
	else if ([details valueForKey:kMBLAbsoluteMaxCapacityKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLAbsoluteMaxCapacityKey] intValue];
	}
	else
	{
		return -1;
	}
}

- (int)absoluteMaxCapacity
{
	return [self designCapacity];
}	

- (int)amperage
{
	/* Current does not refer to the Amperage!! */
	/*
	if ([details valueForKey:CFSTR(kIOPSCurrentKey)])
	{
		return [(NSNumber *)[details valueForKey:CFSTR(kIOPSCurrentKey)] intValue];
	}
	else*/
	if ([details valueForKey:kMBLAmperageKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLAmperageKey] intValue];
	}
	else
	{
		return -1;
	}
}

- (BOOL)isCharging
{
	if ([details valueForKey:kMBLChargingKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLChargingKey] boolValue];
	}
	else
	{
		return !!([(NSNumber *)[details valueForKey:kMBLFlagsKey] intValue] & CHARGING_FLAG);
	}		
}

- (BOOL)isPlugged
{
	if ([details valueForKey:kMBLPowerSourceStateKey])
	{
		return [(NSString *)[details valueForKey:kMBLPowerSourceStateKey] isEqual:kMBLPowerSourceACValue];
	}
	else
	{
		return !!([(NSNumber *)[details valueForKey:kMBLFlagsKey] intValue] & PLUGGED_FLAG);
	}		
}

- (BOOL)isInstalled
{
	if ([details valueForKey:kMBLIsPresentKey])
	{
		return (BOOL)([(NSNumber *)[details valueForKey:kMBLIsPresentKey] intValue]);
	}
	else	
	{
		return (BOOL)([(NSNumber *)[details valueForKey:kMBLFlagsKey] intValue] & INSTALLED_FLAG);
	}
}

- (int)cycleCount
{
	if ([details valueForKey:kMBLCycleCountKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLCycleCountKey] intValue];
	}
	else
	{
		return -1;
	}
}

- (int)voltage
{
	if ([details valueForKey:kMBLVoltageKey])
	{
		return [(NSNumber *)[details valueForKey:kMBLVoltageKey] intValue];
	}
	else
	{
		return -1;
	}
}

- (void)setDetails:(NSDictionary *)dict
{
	[dict retain];
	[details release];
	details = dict;
}

- (NSDictionary *)details
{
	return details;
}

- (NSTimeInterval)timeToFullCharge
{
	if ([details valueForKey:kMBLTimeToFullKey] != nil)
	{
		int time = [(NSNumber *)[details valueForKey:kMBLTimeToFullKey] intValue];
		// This value is in minutes, so multiply it by 60
		return time < 0 ? time : time * 60;
	}
	else
	{
		return -1;
	}	
}
- (NSTimeInterval)timeToEmpty
{
	if ([details valueForKey:kMBLTimeToEmptyKey] != nil)
	{
		int time = [(NSNumber *)[details valueForKey:kMBLTimeToEmptyKey] intValue];
		// This value is in minutes, so multiply it by 60
		return time < 0 ? time : time * 60;
	}
	else
	{
		return -1;
	}	
}


- (NSCalendarDate *)date
{
	return date;
}

- (NSString *)description
{
	return [NSString stringWithFormat:NSLocalizedString(@"Charge: %d%%, amperage: %d, plugged: %@, charging: %@", @"Charge: %d%%, amperage: %d, plugged: %@, charging: %@"),
		[self charge],
		[self amperage],
		([self isPlugged] ? NSLocalizedString(@"yes", @"yes") : NSLocalizedString(@"no", @"no")),
		([self isCharging] ? NSLocalizedString(@"yes", @"yes") : NSLocalizedString(@"no", @"no"))];
}

- (NSString *)CSVLine
{
	return [self CSVLineUsingSeparator:@","];
}

- (NSString *)CSVLineMSExcel
{
	return [self CSVLineUsingSeparator:@";"];
}

- (NSString *)CSVLineUsingSeparator:(NSString *)sep
{
	return [NSString stringWithFormat:@"\"%@\"%@\"%@\"%@%d%@%d%@%d%@%d%@%d%@%d%@%d%@\"%@\"%@\"%@\"\n",
		[self date],
		sep,
		[self type],
		sep,
		[self charge],
		sep,
		[self voltage],
		sep,
		[self amperage],
		sep,
		[self capacity],
		sep,
		[self maxCapacity],
		sep,
		[self designCapacity],
		sep,
		[self cycleCount],
		sep,
		[self isPlugged] ? NSLocalizedString(@"yes", @"yes") : NSLocalizedString(@"no", @"no"),
		sep,
		[self isCharging] ? NSLocalizedString(@"yes", @"yes") : NSLocalizedString(@"no", @"no")];
}

// @protocol BatteryEvent (NSCoding)

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super initWithCoder:coder])
	{
		[self setDetails:[coder decodeObjectForKey:@"details"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:details forKey:@"details"];
}

@end