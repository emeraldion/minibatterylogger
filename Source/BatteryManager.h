//
//  BatteryManager.h
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PowerDefines.h"
#import "Battery.h"

// Pattern to identify internal battery
#define BATTERY_PATTERN @"State:/IOKit/PowerSources/InternalBattery-%d"

extern NSString *MBLBatteryPropertiesChangedNotification;
extern NSString *MBLBatteryManagerPropertiesChangedNotification;

/*!
 @class BatteryManager
 @abstract Objects of class <tt>BatteryManager</tt> are responsible of managing a <tt>Battery</tt>
 object, updating it in response to power events and expose monitoring functionality to clients.
 @discussion The <tt>BatteryManager</tt> class is the base, somewhat abstract class of all battery
 manager classes, which provide specialized behavior in response to different kinds of event sources.
 */
@interface BatteryManager : NSObject {

	Battery *_battery;
	BOOL _monitoring;
	BOOL _logging;
	NSMutableArray *_events;
	NSMutableArray *_sessions;
	NSString *_machineType;
	NSString *_serviceUID;

	int _index;
}

/*!
 @method setBattery:
 @abstract Sets the battery of the receiver.
 @param batt A battery.
 */
- (void)setBattery:(Battery *)batt;

/*!
 @method battery
 @abstract Returns the battery of the receiver.
 @result The battery of the receiver.
 */
- (Battery *)battery;

/*!
 @method setEvents:
 @abstract Sets the events of the receiver.
 @param arr An array of events.
 */
- (void)setEvents:(NSArray *)arr;

/*!
 @method events
 @abstract Returns the events buffer of the receiver.
 @result The events buffer of the receiver.
 */
- (NSArray *)events;

/*!
 @method setSessions:
 @abstract Sets the sessions of the receiver.
 @param sessions An array of sessions.
 */
- (void)setSessions:(NSArray *)sessions;

/*!
 @method appendSessions:
 @abstract Appends <tt>sessions</tt> to the sessions of the receiver.
 @param sessions An array of sessions.
 */
- (void)appendSessions:(NSArray *)sessions;

/*!
 @method sessions
 @abstract Returns the sessions buffer of the receiver.
 @result The sessions buffer of the receiver.
 */
- (NSArray *)sessions;

/*!
 @method isMonitoring
 @abstract Returns <tt>YES</tt> if the receiver is actively monitoring its event source, <tt>NO</tt> otherwise.
 @result <tt>YES</tt> if the receiver is actively monitoring its event source, <tt>NO</tt> otherwise.
 */
- (BOOL)isMonitoring;

/*!
 @method setMonitoring:
 @abstract Sets whether the receiver should actively monitor its event source.
 @param yorn <tt>YES</tt> if the receiver should actively monitor its event source, <tt>NO</tt> otherwise.
 */
- (void)setMonitoring:(BOOL)yorn;

/*!
 @method isLogging
 @abstract Returns <tt>YES</tt> if the receiver is logging events, <tt>NO</tt> otherwise.
 @result <tt>YES</tt> if the receiver is logging events, <tt>NO</tt> otherwise.
 */
- (BOOL)isLogging;

/*!
 @method setLogging:
 @abstract Sets whether the receiver should log events.
 @param yorn <tt>YES</tt> if the receiver should log events, <tt>NO</tt> otherwise.
 */
- (void)setLogging:(BOOL)log;

- (void)probeBattery;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)flushEvents;

- (id)name;
- (NSImage *)icon;

- (NSString *)machineType;
- (void)setMachineType:(NSString *)type;

- (NSString *)serviceUID;
- (void)setServiceUID:(NSString *)uid;

- (int)index;
- (void)setIndex:(int)idx;

- (void)startNewSession;

@end
