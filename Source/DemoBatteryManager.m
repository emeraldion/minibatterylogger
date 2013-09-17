//
//  DemoBatteryManager.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-05-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "DemoBatteryManager.h"
#import "BatteryEvent.h"
#import "CPSystemInformation.h"

extern const NSString *kMBLChargeKey;
extern const NSString *kMBLCycleCountKey;
extern const NSString *kMBLCapacityKey;
extern const NSString *kMBLMaxCapacityKey;
extern const NSString *kMBLDesignCapacityKey;
extern const NSString *kMBLAbsoluteMaxCapacityKey;
extern const NSString *kMBLAmperageKey;
extern const NSString *kMBLVoltageKey;
extern const NSString *kMBLPowerSourceStateKey;
extern const NSString *kMBLPowerSourceACValue;
extern const NSString *kMBLPowerSourceBatteryValue;
extern const NSString *kMBLIsPresentKey;
extern const NSString *kMBLChargingKey;
extern const NSString *kMBLTimeToEmptyKey;
extern const NSString *kMBLTimeToFullKey;
extern const NSString *kMBLFlagsKey;

@interface DemoBatteryManager (Private)

- (void)_createDemoEvent;
- (void)_consumeBatteryEvent:(BatteryEvent *)evt;
- (void)_startDemoTimer;
- (void)_stopDemoTimer;
- (void)_handleNotification:(NSNotification *)notif;

@end

@implementation DemoBatteryManager

- (id)init
{
	if (self = [super init])
	{
		_interval = 2.0;
		_descent = YES;
		_charge = 100;
		[self setIndex:0];
		[self setMachineType:[[CPSystemInformation machineType] substringFromIndex:1]];
		[self setServiceUID:@"Demo Battery"];
		
		[_battery setManufacturer:@"Emeraldion Lodge"];
		[_battery setDeviceName:@"Demo-01"];
		[_battery setSerial:@"DEMO0001"];
		[_battery setManufactureDate:[NSCalendarDate date]];
		
		[self _createDemoEvent];
	}
	return self;
}

- (id)name
{
	return [NSArray arrayWithObjects:NSLocalizedString(@"Demo Battery", @"Demo Battery"), _machineType, nil];
}

- (void)setInterval:(NSTimeInterval)interval
{
	_interval = interval;
}
- (NSTimeInterval)interval
{
	return _interval;
}

- (void)startMonitoring
{
	if (_monitoring)
		return;

	[self _startDemoTimer];

	[self setMonitoring:YES];
}

- (void)stopMonitoring
{
	if (!_monitoring)
		return;
	
	[self _stopDemoTimer];
	
	[self setMonitoring:NO];
}

@end

@implementation DemoBatteryManager (Private)

- (void)_startDemoTimer
{
	if ([_demoTimer isValid])
		return;
	
	_demoTimer = [[NSTimer scheduledTimerWithTimeInterval:_interval
												  target:self
												selector:@selector(_createDemoEvent)
												userInfo:nil
												 repeats:YES] retain];
}

- (void)_stopDemoTimer
{
	if (![_demoTimer isValid])
		return;
	
	[_demoTimer invalidate];
	_demoTimer = nil;
}

- (void)_createDemoEvent
{
	// Create a dummy property set...
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:_charge], kMBLChargeKey,
		[NSNumber numberWithInt:(int)(_charge * 44.0)], kMBLCapacityKey,
		[NSNumber numberWithInt:4400], kMBLMaxCapacityKey,
		[NSNumber numberWithInt:4400], kMBLAbsoluteMaxCapacityKey,
		[NSNumber numberWithBool:YES], kMBLIsPresentKey,
		[NSNumber numberWithInt:1000], kMBLAmperageKey,
		[NSNumber numberWithInt:12000], kMBLVoltageKey,
		[NSNumber numberWithBool:!_descent], kMBLChargingKey,
		(_descent ? kMBLPowerSourceBatteryValue : kMBLPowerSourceACValue), kMBLPowerSourceStateKey,
		[NSNumber numberWithInt:150], kMBLCycleCountKey,
		[NSNumber numberWithInt:(100 - _charge) / 10], kMBLTimeToEmptyKey,
		[NSNumber numberWithInt:-1], kMBLTimeToFullKey,
		nil];

	//NSLog(@"dict:%@", dict);
	
	// ...create an event...
	BatteryEvent *event = [BatteryEvent batteryEventWithDetails:dict
														  index:-1
														   time:[NSCalendarDate calendarDate]];
	
	// ...and consume it
	[self _consumeBatteryEvent:event];
	
	_charge = _descent ? (_charge - 1) : (_charge + 1);
	
	if (_charge < 0)
	{
		_descent = NO;
		_charge = 1;
	}
	else if (_charge > 100)
	{
		_descent = YES;
		_charge = 100;
		[self stopMonitoring];
	}
}

- (void)_consumeBatteryEvent:(BatteryEvent *)evt
{
	[super _consumeBatteryEvent:evt];
	
	[_battery setCharge:[evt charge]];
	[_battery setInstalled:[evt isInstalled]];
	[_battery setPlugged:[evt isPlugged]];
	[_battery setCharging:[evt isCharging]];
	[_battery setCapacity:[evt capacity]];
	[_battery setMaxCapacity:[evt maxCapacity]];
	[_battery setAbsoluteMaxCapacity:[evt absoluteMaxCapacity]];
	[_battery setAmperage:[evt amperage]];
	[_battery setCycleCount:[evt cycleCount]];
	[_battery setVoltage:[evt voltage]];
	[_battery setTimeToEmpty:[evt timeToEmpty]];
	[_battery setTimeToFullCharge:[evt timeToFullCharge]];
	
	//NSLog(@"_battery:%@", _battery);
	
	// Wrap event in a notification
	NSNotification *notif = [NSNotification notificationWithName:MBLBatteryPropertiesChangedNotification
														  object:self
														userInfo:(void *)evt];
	// Post the notification to the default center
	[[NSNotificationCenter defaultCenter] postNotification:notif];	
}

- (void)_handleNotification:(NSNotification *)notif
{
#pragma unused (notif)
}

@end