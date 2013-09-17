//
//  BatteryEvent.h
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PowerDefines.h"
#import "MBLEvent.h"

extern NSString *MBLBatteryEventType;

/*!
 @const kMBLChargeKey
 @abstract Key to access the battery charge entry in the details dictionary.
 */
extern const NSString *kMBLChargeKey;

/*!
 @const kMBLCycleCountKey
 @abstract Key to access the battery cycle count entry in the details dictionary.
 */
extern const NSString *kMBLCycleCountKey;

/*!
 @const kMBLCapacityKey
 @abstract Key to access the battery capacity entry in the details dictionary.
 */
extern const NSString *kMBLCapacityKey;

/*!
 @const kMBLMaxCapacityKey
 @abstract Key to access the battery maximum capacity entry in the details dictionary.
 */
extern const NSString *kMBLMaxCapacityKey;

/*!
 @const kMBLDesignCapacityKey
 @abstract Key to access the battery design capacity entry in the details dictionary.
 */
extern const NSString *kMBLDesignCapacityKey;

/*!
 @const kMBLAbsoluteMaxCapacityKey
 @abstract Key to access the battery absolute maximum capacity entry in the details dictionary.
 */
extern const NSString *kMBLAbsoluteMaxCapacityKey;

/*!
 @const kMBLAmperageKey
 @abstract Key to access the battery amperage entry in the details dictionary.
 */
extern const NSString *kMBLAmperageKey;

/*!
 @const kMBLVoltageKey
 @abstract Key to access the battery voltage entry in the details dictionary.
 */
extern const NSString *kMBLVoltageKey;

/*!
 @const kMBLIsPresentKey
 @abstract Key to access the battery installed status entry in the details dictionary.
 */
extern const NSString *kMBLIsPresentKey;

/*!
 @const kMBLPowerSourceStateKey
 @abstract Key to access the battery power source status entry in the details dictionary.
 */
extern const NSString *kMBLPowerSourceStateKey;

/*!
 @const kMBLPowerSourceACValue
 @abstract Value for the <tt>kMBLPowerSourceStateKey</tt> key when the battery is plugged
 to an external power source.
 */
extern const NSString *kMBLPowerSourceACValue;

/*!
 @const kMBLPowerSourceBatteryValue
 @abstract Value for the <tt>kMBLPowerSourceStateKey</tt> key when the battery is not plugged
 to an external power source.
 */
extern const NSString *kMBLPowerSourceBatteryValue;

/*!
 @const kMBLChargingKey
 @abstract Key to access the battery charging status entry in the details dictionary.
 */
extern const NSString *kMBLChargingKey;

/*!
 @const kMBLTimeToEmptyKey
 @abstract Key to access the battery time to empty entry in the details dictionary.
 */
extern const NSString *kMBLTimeToEmptyKey;

/*!
 @const kMBLTimeToFullKey
 @abstract Key to access the battery time to full entry in the details dictionary.
 */
extern const NSString *kMBLTimeToFullKey;

/*!
 @const kMBLFlagsKey
 @abstract Key to access the battery status flags entry in the details dictionary.
 */
extern const NSString *kMBLFlagsKey;

/*!
 @class BatteryEvent
 @abstract MBLEvent subclass that models a battery event.
 @discussion Battery events occur when one or more properties of the battery are subject to change,
 e.g. the charge has decreased or the amperage has changed.
 */
@interface BatteryEvent : MBLEvent {

	NSDictionary *details;
	int index;
}

/*!
 @method batteryEventWithDetails:index:time:
 @abstract Returns an autoreleased BatteryEvent object with the given details dictionary,
 for battery located at <tt>index</tt> and issued at <tt>date</tt>.
 @param dict The details dictionary.
 @param index The index of the battery (starting at zero).
 @param date The date when the event occurred.
 @result An autoreleased BatteryEvent object.
 */
+ (id)batteryEventWithDetails:(NSDictionary *)dict index:(int)index time:(NSCalendarDate *)date;

/*!
 @method initWithDetails:index:time:
 @abstract Initializes the receiver with the given details dictionary,
 for battery located at <tt>index</tt> and issued at <tt>date</tt>.
 @param dict The details dictionary.
 @param index The index of the battery (starting at zero).
 @param date The date when the event occurred.
 @result The receiver.
 */
- (id)initWithDetails:(NSDictionary *)dict index:(int)index time:(NSCalendarDate *)date;

/*!
 @method charge
 @abstract Returns the value of charge of the receiver.
 */
- (int)charge;

/*!
 @method amperage
 @abstract Returns the value of amperage of the receiver.
 */
- (int)amperage;

/*!
 @method cycleCount
 @abstract Returns the value of cycle count of the receiver.
 */
- (int)cycleCount;

/*!
 @method voltage
 @abstract Returns the value of voltage of the receiver.
 */
- (int)voltage;

/*!
 @method capacity
 @abstract Returns the value of capacity of the receiver.
 */
- (int)capacity;

/*!
 @method maxCapacity
 @abstract Returns the value of maximum capacity of the receiver.
 */
- (int)maxCapacity;

/*!
 @method absoluteMaxCapacity
 @abstract Returns the value of absolute maximum capacity of the receiver.
 @discussion This method is maintained for compatibility with PPC hardware. On newer
 Intel EFI-based hardware it is meaningless.
 */
- (int)absoluteMaxCapacity;

/*!
 @method designCapacity
 @abstract Returns the value of the design capacity of the receiver.
 @discussion This method is the recommended way to get the design capacity on all systems.
 For old PPC Macs it falls back on the old, deprecated, absoluteMaxCapacity method.
 */
- (int)designCapacity;

/*!
 @method timeToFullCharge
 @abstract Returns the value of time to full charge of the receiver.
 */
- (NSTimeInterval)timeToFullCharge;

/*!
 @method timeToEmpty
 @abstract Returns the value of time to empty of the receiver.
 */
- (NSTimeInterval)timeToEmpty;

/*!
 @method isInstalled
 @abstract Returns <tt>YES</tt> when the battery is installed.
 */
- (BOOL)isInstalled;

/*!
 @method isCharging
 @abstract Returns <tt>YES</tt> when the battery is charging.
 */
- (BOOL)isCharging;

/*!
 @method isPlugged
 @abstract Returns <tt>YES</tt> when the battery is plugged to an external power source.
 */
- (BOOL)isPlugged;

/*!
 @method setDetails:
 @abstract Sets the details dictionary of the event object.
 @param details The details dictionary.
 */
- (void)setDetails:(NSDictionary *)dict;

/*!
 @method details
 @abstract Returns the details dictionary of the event object.
 @result The details dictionary.
 */
- (NSDictionary *)details;

@end
