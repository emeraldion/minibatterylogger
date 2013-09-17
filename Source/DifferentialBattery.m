//
//  DifferentialBattery.m
//  MiniBatteryLogger
//
//  Created by delphine on 30-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "DifferentialBattery.h"

@interface DifferentialBattery (Private)

+ (NSColor *)colorForQuantity:(int)quantity;

@end

@implementation DifferentialBattery

- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}

+ (DifferentialBattery *)battery
{
	return [[[self alloc] init] autorelease];
}

#pragma mark === Overridden superclass methods ===

// These methods have to be overridden to allow negative values

- (void)setCharge:(int)chr
{
	charge = chr;
}

- (void)setCycleCount:(int)cycles
{
	cycleCount = cycles;
}

- (void)setVoltage:(int)volts
{
	voltage = volts;
}

- (void)setCapacity:(int)cap
{
	capacity = cap;
}

- (void)setMaxCapacity:(int)cap
{
	maxCapacity = cap;
}

- (void)setAbsoluteMaxCapacity:(int)cap
{
	absoluteMaxCapacity = cap;
}

#pragma mark === Accessors ===

- (NSColor *)colorForVoltage
{
	return [[self class] colorForQuantity:voltage];
}

- (NSColor *)colorForMaxCapacity
{
	return [[self class] colorForQuantity:maxCapacity];
}

- (NSColor *)colorForAbsoluteMaxCapacity
{
	return [[self class] colorForQuantity:absoluteMaxCapacity];
}

- (NSColor *)colorForCycleCount
{
	// We pass -cycleCount, as the less the better
	return [[self class] colorForQuantity:-cycleCount];
}

#pragma mark === Private methods ===

+ (NSColor *)colorForQuantity:(int)quantity
{
	return (quantity ?
			(quantity > 0 ?
			 [NSColor colorWithDeviceRed:0.0
								   green:192/255.0
									blue:0.0
								   alpha:1.0] :
			 [NSColor colorWithDeviceRed:192/255.0
								   green:0.0
									blue:0.0
								   alpha:1.0]) :
			[NSColor blackColor]);
}

@end

@implementation Battery (DifferentialExtensions)

- (DifferentialBattery *)differentialBattery:(Battery *)other
{
	DifferentialBattery *diff = [DifferentialBattery battery];

	[diff setCharge:[self charge] - [other charge]];
	[diff setCycleCount:[self cycleCount] - [other cycleCount]];
	[diff setVoltage:[self voltage] - [other voltage]];
	[diff setAmperage:[self amperage] - [other amperage]];
	[diff setCapacity:[self capacity] - [other capacity]];
	[diff setMaxCapacity:[self maxCapacity] - [other maxCapacity]];
	[diff setAbsoluteMaxCapacity:[self absoluteMaxCapacity] - [other absoluteMaxCapacity]];
	
	return diff;
}

@end