//
//  BatteryManager.m
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatteryManager.h"
#import "BatteryEvent.h"
#import "CPSystemInformation.h"
#import "MBLHWIconCache.h"
#import "MonitoringSession.h"

NSString *MBLBatteryPropertiesChangedNotification			= @"BatteryPropertiesChanged";
NSString *MBLBatteryManagerPropertiesChangedNotification	= @"BatteryManagerPropertiesChanged";

@interface BatteryManager (Private)

- (void)_consumeBatteryEvent:(BatteryEvent *)evt;
- (void)_loadSessions;

@end

@implementation BatteryManager

+ (void)initialize
{
}

- (id)init
{
	if (self = [super init])
	{
		_logging = YES;
		[self setMachineType:[CPSystemInformation machineType]];
		[self setBattery:[[Battery alloc] init]];
		[self setEvents:[NSMutableArray array]];
		[self _loadSessions];
	}
	return self;
}

- (void)dealloc
{
	[self stopMonitoring];

	[_events release];
	[_sessions release];
	[_battery release];
	[_machineType release];
	
	[super dealloc];
}

- (BOOL)isMonitoring
{
	//NSLog(@"-[%@ isMonitoring] = %d", [self class], _monitoring);

	return _monitoring;
}

- (void)setMonitoring:(BOOL)yorn
{
	//NSLog(@"-[%@ setMonitoring:%d]", [self class], yorn);
	_monitoring = yorn;
}

- (BOOL)isLogging
{
	return _logging;
}
- (void)setLogging:(BOOL)log
{
	_logging = log;
}

- (id)name
{
	return nil;
}

- (NSImage *)icon
{
	return [MBLHWIconCache imageForModel:_machineType];
}

- (NSString *)machineType
{
	return _machineType;
}

- (void)setMachineType:(NSString *)type
{
	[type retain];
	[_machineType release];
	_machineType = type;
}

- (void)setBattery:(Battery *)batt
{
	[batt retain];
	[_battery release];
	_battery = batt;
}

- (Battery *)battery
{
	return _battery;
}

- (void)probeBattery
{
	// Do nothing; subclassers may want to do their stuff here
}

- (void)setEvents:(NSArray *)arr
{
	[_events autorelease];
	_events = [arr mutableCopy];
}

- (NSArray *)events
{
	return _events;
}

- (void)setSessions:(NSArray *)sessions
{
	[_sessions autorelease];
	_sessions = [sessions mutableCopy];
}

- (void)appendSessions:(NSArray *)sessions
{
	[self setSessions:[_sessions arrayByAddingObjectsFromArray:sessions]];
}

- (NSArray *)sessions
{
	return _sessions;
}

- (NSString *)serviceUID
{
	return _serviceUID;
}

- (void)setServiceUID:(NSString *)uid
{
	//NSLog(@"-[%@ setServiceUID:%@]", [self class], uid);
	[uid retain];
	[_serviceUID release];
	_serviceUID = uid;
}

- (int)index
{
	return _index;
}

- (void)setIndex:(int)idx
{
	//NSLog(@"-[%@ setIndex:%d]", [self class], idx);
	_index = idx;
}

- (void)flushEvents
{
	[self setEvents:[NSMutableArray array]];
}

- (void)startMonitoring
{
	if (_monitoring)
		return;
	_monitoring = YES;
}

- (void)stopMonitoring
{
	if (!_monitoring)
		return;
	_monitoring = NO;
}

- (void)startNewSession
{
	[self stopMonitoring];
	
	MonitoringSession *currentSession = (MonitoringSession *)[_sessions objectAtIndex:0];
	[currentSession setActive:NO];
	
	[self setEvents:[NSMutableArray array]];
	
	MonitoringSession *newSession = [MonitoringSession session];
	[newSession setEvents:_events];
	[newSession setActive:YES];
	
	[_sessions insertObject:newSession atIndex:0];

	// Fill with an event
	[self probeBattery];

	[self startMonitoring];
}

@end

@implementation BatteryManager (Private)

- (void)_consumeBatteryEvent:(BatteryEvent *)evt
{
	if (_logging)
	{
		[(MonitoringSession *)[_sessions objectAtIndex:0] addEvent:evt];
	}
}

- (void)_loadSessions
{
	_sessions = [[NSMutableArray alloc] init];
	
	MonitoringSession *currentSession = [MonitoringSession session];
	[currentSession setEvents:_events];
	[currentSession setActive:YES];
	
	[_sessions addObject:currentSession];
}

@end