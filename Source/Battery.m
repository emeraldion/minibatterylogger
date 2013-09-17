//
//  Battery.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "Battery.h"
#import "PowerDefines.h"
#import <IOKit/IOKitLib.h>
#import "NSData+MBLUtils.h"
#import "CPSystemInformation.h"

@interface Battery (Private)

- (void)setPeakAmperage:(int)amperage;
- (void)startBatteryTimer;
- (void)stopBatteryTimer;

@end

@implementation Battery

+ (Battery *)battery
{
	return [[[Battery alloc] init] autorelease];
}

- (id)init
{
	return [self initWithCharge:0
						voltage:0
					   amperage:0
					 cycleCount:0
						plugged:NO
					   charging:NO];
}

- (id)initWithCharge:(int)cap
			   voltage:(int)volt
			  amperage:(int)amp
			cycleCount:(int)cycles
			   plugged:(BOOL)plug
			  charging:(BOOL)charg
{
	if (self = [super init])
	{
		[self setCharge:cap];
		[self setVoltage:volt];
		[self setAmperage:amp];
		[self setCycleCount:cycles];
		[self setPlugged:plug];
		[self setCharging:charg];
		[self setPeakAmperage:amp];
		[self setTimeOnBattery:0];
		[self setActive:YES];
		[self setInstalled:YES];
		if (!plug)
		{
			[self startBatteryTimer];
		}
	}
	return self;
}

- (void)dealloc
{
	[self stopBatteryTimer];

	[manufacturer release];
	[deviceName release];
	[serial release];
	[manufactureDate release];
	
	[super dealloc];
}

+ (void)initialize
{
}

- (int)index
{
	return index;
}

- (void)setIndex:(int)idx
{
	if (idx > -1)
	{
		index = idx;
	}
}

- (int)capacity
{
	return capacity;
}
- (void)setCapacity:(int)cap
{
	if (cap > 0)
	{
		capacity = cap;
	}
	else
	{
		capacity = 0;
	}
}

- (int)charge
{
	return charge;
}
- (void)setCharge:(int)chr
{
	if (0 <= chr)
	{
		if (chr <= 100)
		{
			charge = chr;
		}
		else
		{
			charge = 100;
		}
	}
	else
	{
		charge = 0;
	}
}

- (int)maxCapacity
{
	return maxCapacity;
}
- (void)setMaxCapacity:(int)maxCap
{
	maxCapacity = maxCap;
}

- (int)absoluteMaxCapacity
{
	return absoluteMaxCapacity;
}

- (void)setAbsoluteMaxCapacity:(int)cap
{
	if (cap > 0)
	{
		absoluteMaxCapacity = cap;
	}
}

- (int)amperage
{
	return amperage;
}
- (void)setAmperage:(int)amp
{
	// Amperage can be negative (depleting) or positive (charging)
	amperage = amp;
	
	// If current value is in absolute greater than current peak
	// value, update the peak value
	if (abs(amp) > abs(peakAmperage))
	{
		[self setPeakAmperage:amp];
	}
}

- (int)peakAmperage
{
	return peakAmperage;
}

- (int)voltage
{
	return voltage;
}
- (void)setVoltage:(int)volts
{
	if (volts >= 0)
	{
		voltage = volts;
	}
	else
	{
		voltage = 0;
	}
}

- (int)cycleCount
{
	return cycleCount;
}
- (void)setCycleCount:(int)cycles
{
	if (cycles > 0)
	{
		cycleCount = cycles;
	}
	else
	{
		cycleCount = 0;
	}
}

- (BOOL)isInstalled
{
	return installed;
}

- (void)setInstalled:(BOOL)inst
{
	installed = inst;
}

- (BOOL)isCharging
{
	return charging;
}

- (void)setCharging:(BOOL)charg
{
	// If was not plugged, update isPlugged too
	if (!plugged && charg)
	{
		[self setPlugged:YES];
	}
	charging = charg;
}

- (BOOL)isPlugged
{
	return plugged;
}

- (void)setPlugged:(BOOL)plug
{
	// When changing power source, start or stop on battery timer
	if (active && (plugged ^ plug))
	{
		if (plug)
		{
			// Invalidate timer when switching to AC power
			[self stopBatteryTimer];
		}
		else
		{
			// Schedule timer when switching to battery power
			[self startBatteryTimer];
		}
	}
	plugged = plug;
}

- (BOOL)isActive
{
	return active;
}

- (void)setActive:(BOOL)act
{
	if (active ^ act)
	{
		if (act && !plugged)
		{
			[self startBatteryTimer];
		}
		else
		{
			[self stopBatteryTimer];
		}
	}
	active = act;
}

- (NSString *)description
{
	return [NSString stringWithFormat:NSLocalizedString(@"Charge: %d%%, voltage: %dmV, amperage: %dmA (peak: %dmA), plugged: %@, charging: %@, cycle count: %d", @"Charge: %d%%, voltage: %dmV, amperage: %dmA (peak: %dmA), plugged: %@, charging: %@, cycle count: %d"),
		charge,
		voltage,
		amperage,
		peakAmperage,
				  plugged ? NSLocalizedString(@"yes", @"yes") : NSLocalizedString(@"no", @"no"),
				 charging ? NSLocalizedString(@"yes", @"yes") : NSLocalizedString(@"no", @"no"),
		cycleCount];
}

- (NSTimeInterval)timeToFullCharge
{
	return timeToFullCharge;
}

- (void)setTimeToFullCharge:(NSTimeInterval)time
{
	if (((int)time) >= -1)
	{
		timeToFullCharge = time;
	}
}

- (NSTimeInterval)timeToEmpty
{
	return timeToEmpty;
}

- (void)setTimeToEmpty:(NSTimeInterval)time
{
	if (((int)time) >= -1)
	{
		timeToEmpty = time;
	}
}

- (NSTimeInterval)timeOnBattery
{
	return timeOnBattery;
}
- (void)setTimeOnBattery:(NSTimeInterval)time
{
	if (((int)time) >= -1)
	{
		timeOnBattery = time;
	}
}

- (void)incrementTimeOnBattery
{
	[self setTimeOnBattery: timeOnBattery + 60.0];
}

- (void)resetTimeOnBattery
{
	[self stopBatteryTimer];
	[self setTimeOnBattery:0.0];
	if (!plugged)
		[self startBatteryTimer];
}

- (int)designCapacity
{
	return [self absoluteMaxCapacity];
}

- (void)setDesignCapacity:(int)cap
{
	[self setAbsoluteMaxCapacity:cap];
}

- (NSString *)manufacturer
{
	return manufacturer;
}
- (void)setManufacturer:(NSString *)name
{
	[name retain];
	[manufacturer release];
	manufacturer = name;
}

- (NSString *)deviceName
{
	return deviceName;
}
- (void)setDeviceName:(NSString *)name
{
	[name retain];
	[deviceName release];
	deviceName = name;
}

- (NSString *)serial
{
	return serial;
}

- (void)setSerial:(NSString *)ser
{
	[ser retain];
	[serial release];
	serial = ser;
}	

- (NSCalendarDate *)manufactureDate
{
	return manufactureDate;
}

- (void)setManufactureDate:(NSCalendarDate *)date
{
	[date retain];
	[manufactureDate release];
	manufactureDate = date;
}

- (NSString *)uniqueID
{
	if (manufacturer != nil &&
		manufactureDate != nil &&
		deviceName != nil &&
		serial != nil)
	{
		return [[[NSString stringWithFormat:@"%@%@%@%@",
			manufacturer,
			manufactureDate,
			deviceName,
			serial] dataUsingEncoding:NSUTF8StringEncoding] md5HashAsString];
	}
	return [CPSystemInformation systemUniqueID];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		index = [coder decodeIntForKey:@"index"];
		charge = [coder decodeIntForKey:@"charge"];
		amperage = [coder decodeIntForKey:@"amperage"];
		peakAmperage = [coder decodeIntForKey:@"peakAmperage"];
		voltage = [coder decodeIntForKey:@"voltage"];
		cycleCount = [coder decodeIntForKey:@"cycleCount"];
		capacity = [coder decodeIntForKey:@"capacity"];
		maxCapacity = [coder decodeIntForKey:@"maxCapacity"];
		absoluteMaxCapacity = [coder decodeIntForKey:@"absoluteMaxCapacity"];
		charging = [coder decodeBoolForKey:@"charging"];
		plugged = [coder decodeBoolForKey:@"plugged"];
		installed = [coder decodeBoolForKey:@"installed"];
		active = [coder decodeBoolForKey:@"active"];
		timeToFullCharge = [coder decodeIntForKey:@"timeToFullCharge"];
		timeToEmpty = [coder decodeIntForKey:@"timeToEmpty"];
		timeOnBattery = [coder decodeIntForKey:@"timeOnBattery"];
		deviceName = [[coder decodeObjectForKey:@"deviceName"] retain];
		manufacturer = [[coder decodeObjectForKey:@"manufacturer"] retain];
		manufactureDate = [[coder decodeObjectForKey:@"manufactureDate"] retain];
		serial = [[coder decodeObjectForKey:@"serial"] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:index forKey:@"index"];
	[coder encodeInt:charge forKey:@"charge"];
	[coder encodeInt:amperage forKey:@"amperage"];
	[coder encodeInt:peakAmperage forKey:@"peakAmperage"];
	[coder encodeInt:voltage forKey:@"voltage"];
	[coder encodeInt:cycleCount forKey:@"cycleCount"];
	[coder encodeInt:capacity forKey:@"capacity"];
	[coder encodeInt:maxCapacity forKey:@"maxCapacity"];
	[coder encodeInt:absoluteMaxCapacity forKey:@"absoluteMaxCapacity"];
	[coder encodeBool:charging forKey:@"charging"];
	[coder encodeBool:plugged forKey:@"plugged"];
	[coder encodeBool:installed forKey:@"installed"];
	[coder encodeBool:NO forKey:@"active"];
	[coder encodeInt:timeToEmpty forKey:@"timeToEmpty"];
	[coder encodeInt:timeToFullCharge forKey:@"timeToFullCharge"];
	[coder encodeInt:timeOnBattery forKey:@"timeOnBattery"];
	[coder encodeObject:deviceName forKey:@"deviceName"];
	[coder encodeObject:manufacturer forKey:@"manufacturer"];
	[coder encodeObject:manufactureDate forKey:@"manufactureDate"];
	[coder encodeObject:serial forKey:@"serial"];
}	

@end

@implementation Battery (Private)

- (void)startBatteryTimer
{
	if (![onBatteryTimer isValid])
	{
		onBatteryTimer = [NSTimer scheduledTimerWithTimeInterval:60
														  target:self
														selector:@selector(incrementTimeOnBattery)
														userInfo:nil
														 repeats:YES];			
	}	
}
- (void)stopBatteryTimer
{
	if ([onBatteryTimer isValid])
	{
		[onBatteryTimer invalidate];
		onBatteryTimer = nil;
	}	
}

- (void)setPeakAmperage:(int)amp
{
	peakAmperage = amp;
}

@end
