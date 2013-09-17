//
//  Battery.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class Battery
 @abstract Model class for a battery.
 @discussion A Battery object models a physical battery. It has a charge between 0 and 100%,
 a capacity (current, maximum and absolute maximum or factory default), an amperage value,
 can be plugged or charging, has a time to full charge, a time to empty and a time on battery.
 */
@interface Battery : NSObject <NSCoding> {

	/*!
	 @var index
	 @abstract A numeric index the battery.
	 */
	int index;
	
	/*!
	 @var charge
	 @abstract The value of the charge of the battery.
	 @discussion Charge is an integer number in the range 0 - 100.
	 */
	int charge;

	/*!
	 @var amperage
	 @abstract The value of the amperage of the battery.
	 @discussion Amperage is the measure of the current flowing in the
	 battery. Can be either positive, meaning that the battery is being charged
	 by the current, or negative, meaning that the current is flowing from the battery,
	 which is depleting.
	 */
	int amperage;

	/*!
	 @var peakAmperage
	 @abstract The value of the peak amperage of the battery.
	 */
	int peakAmperage;

	/*!
	 @var voltage
	 @abstract The value of the voltage of the battery.
	 */
	int voltage;
	
	/*!
	 @var cycleCount
	 @abstract The value of the cycle count of the battery.
	 */
	int cycleCount;
	
	/*!
	 @var capacity
	 @abstract The value of the capacity of the battery.
	 @discussion The capacity is the quantity of energy that the battery is
	 currently holding, expressed in milliAmpere hour (mAh).
	 */
	int capacity;

	/*!
	 @var maxCapacity
	 @abstract The value of the maximum capacity of the battery.
	 @discussion The maximum capacity is the maximum quantity of energy that
	 the battery can hold, expressed in milliAmpere hour (mAh).
	 */
	int maxCapacity;
	
	/*!
	 @var absoluteMaxCapacity
	 @abstract The value of the absolute maximum capacity of the battery.
	 @discussion The absolute maximum capacity is the quantity of energy that
	 the battery has been designed to hold, expressed in milliAmpere hour (mAh).
	 */
	int absoluteMaxCapacity;
	
	/*!
	 @var installed
	 @abstract Tells if the battery is currently installed.
	 */
	BOOL installed;

	/*!
	 @var charging
	 @abstract Tells if the battery is currently charging.
	 */
	BOOL charging;

	/*!
	 @var plugged
	 @abstract Tells if the battery is currently plugged to an external power source.
	 */
	BOOL plugged;
	
	/*!
	 @var active
	 @abstract Tells if the battery is currently active.
	 */
	BOOL active;
	
	/*!
	 @var timeToFullCharge
	 @abstract The provisional time required in order to fully charge the battery.
	 */
	NSTimeInterval timeToFullCharge;

	/*!
	 @var timeToEmpty
	 @abstract The provisional time until the battery charge reaches zero.
	 */
	NSTimeInterval timeToEmpty;

	/*!
	 @var timeOnBattery
	 @abstract A time counter measuring the time elapsed on battery power.
	 */
	NSTimeInterval timeOnBattery;

	/*!
	 @var manufacturer
	 @abstract The name of the manufacturer of the battery.
	 */
	NSString *manufacturer;

	/*!
	 @var deviceName
	 @abstract The name of the hardware device of the battery.
	 */
	NSString *deviceName;

	/*!
	 @var serial
	 @abstract The serial number of the battery.
	 */
	NSString *serial;

	/*!
	 @var manufactureDate
	 @abstract The date of manufacture of the battery.
	 */
	NSCalendarDate *manufactureDate;

	/*!
	 @var onBatteryTimer
	 @abstract A timer used to measure the time elapsed on battery.
	 */
	NSTimer *onBatteryTimer;
}

/*!
 @method battery
 @abstract Returns an autoreleased Battery object.
 @result An autoreleased Battery object.
 */
+ (Battery *)battery;

/*!
 @method initWithCharge:voltage:amperage:cycleCount:plugged:charging:
 @abstract Initializes a Battery object with the given specs.
 @param charge The amount of charge.
 @param voltage The value of voltage.
 @param amperage The value of amperage.
 @param cycleCount The number of full cycles.
 @param plugged Whether the battery is plugged to an external power source.
 @param charging Whether the battery is charging.
 @result The Battery object.
 */
- (id)initWithCharge:(int)charge
			   voltage:(int)voltage
			  amperage:(int)amperage
			cycleCount:(int)cycles
			   plugged:(BOOL)plugged
			  charging:(BOOL)charging;

#pragma mark === Accessors ===

/*!
 @method index
 @abstract Returns the index of the battery.
 @result The index of the battery.
*/
- (int)index;

/*!
 @method setIndex:
 @abstract Sets the index of the battery.
 @param idx The index of the battery.
*/
- (void)setIndex:(int)idx;

/*!
 @method charge
 @abstract Returns the charge of the battery.
 @discussion The charge of the battery is an integer value between 0 and 100. For more
 elaborate calculations, it is recommended that you use the ratio between <tt>capacity</tt>
 and <tt>maxCapacity</tt>.
 @result The charge of the battery.
*/
- (int)charge;

/*!
 @method setCharge:
 @abstract Sets the charge of the battery.
 @param charge The charge of the battery.
*/
- (void)setCharge:(int)charge;

/*!
 @method capacity
 @abstract Returns the current capacity of the battery.
 @discussion The capacity of a battery is the amount of stored charge, expressed in milli Ampere per hour (mAh).
 @result The current capacity of the battery.
*/
- (int)capacity;

/*!
 @method setCapacity:
 @abstract Sets the capacity of the battery.
 @param capacity The capacity of the battery.
*/
- (void)setCapacity:(int)capacity;

/*!
 @method maxCapacity
 @abstract Returns the maximum capacity of the battery.
 @discussion The maximum capacity of a battery is the maximum amount of storable charge, expressed in milli Ampere per hour (mAh).
 @result The maximum capacity of the battery.
*/
- (int)maxCapacity;

/*!
 @method setMaxCapacity:
 @abstract Sets the maximum capacity of the battery.
 @param maxCapacity The maximum capacity of the battery.
*/
- (void)setMaxCapacity:(int)maxCapacity;

/*!
 @method absoluteMaxCapacity
 @abstract Returns the factory default capacity of the battery.
 @discussion The factory default capacity of a battery is the maximum amount of storable charge according to the manufacturer,
 expressed in milli Ampere per hour (mAh).
 @result The factory default capacity of the battery.
 @deprecated This method is deprecated from 1.8.2. Use <tt>designCapacity</tt> instead.
*/
- (int)absoluteMaxCapacity;

/*!
 @method setAbsoluteMaxCapacity:
 @abstract Sets the factory default capacity of the battery.
 @param absMaxCapacity The factory default capacity of the battery.
 @deprecated This method is deprecated from 1.8.2. Use <tt>setDesignCapacity:</tt> instead.
*/
- (void)setAbsoluteMaxCapacity:(int)absMaxCapacity;

/*!
 @method amperage
 @abstract Returns the amperage of the battery.
 @discussion The amperage of a battery is the amount of electric current flowing to (when charging),
 and from (when on battery power) the battery, expressed in milli Ampere (mA). The amperage is
 respectively positive or negative.
 @result The amperage of the battery.
*/
- (int)amperage;

/*!
 @method setAmperage:
 @abstract Sets the amperage of the battery.
 @param amperage The amperage of the battery.
*/
- (void)setAmperage:(int)amperage;

/*!
 @method peakAmperage
 @abstract Returns the peak amperage of the battery.
 @discussion The peak amperage of a battery is the maximum of electric current flowing through
 the battery, in absolute value, expressed in milli Ampere (mA). The peak amperage can be
 either positive or negative. This value is internally set.
 @result The peak amperage of the battery.
*/
- (int)peakAmperage;

/*!
 @method voltage
 @abstract Returns the voltage of the battery.
 @discussion The voltage of a battery is the value of electric potential between the electrodes of the battery,
 expressed in milli Volts (mV). The voltage is always a positive integer value.
 @result The voltage of the battery.
*/
- (int)voltage;

/*!
 @method setVoltage:
 @abstract Sets the voltage of the battery.
 @param voltage The voltage of the battery.
*/
- (void)setVoltage:(int)voltage;

/*!
 @method cycleCount
 @abstract Returns the number of full cycles performed by the battery.
 @discussion A battery performs a charge cycle when completely depleted, then recharged. Batteries often keep an
 internal counter of charge cycles to track the wear. Cycle count is always a positive (or null) integer.
 @result The cycle count of the battery.
*/
- (int)cycleCount;

/*!
 @method setCycleCount:
 @abstract Sets the cycle count of the battery.
 @param cycles The cycle count of the battery.
*/
- (void)setCycleCount:(int)cycles;

/*!
 @method isInstalled
 @abstract Returns <tt>YES</tt> if the battery is physically installed in the computer.
 @discussion Although it is not a good idea, Mac laptops can run without a battery installed, provided
 that you are plugged to a (reliable) external power source.
 @result <tt>YES</tt> if the battery is physically installed in the computer.
 */
- (BOOL)isInstalled;

/*!
 @method setInstalled:
 @abstract Sets whether the battery is physically installed in the computer.
 @param installed Whether the battery is physically installed in the computer.
 */
- (void)setInstalled:(BOOL)installed;

/*!
 @method isCharging
 @abstract Returns <tt>YES</tt> if the battery is currently recharging.
 @discussion Mac laptops usually show that a battery is charging with a nice amber light around the power chord jack.
 @result <tt>YES</tt> if the battery is currently recharging.
*/
- (BOOL)isCharging;

/*!
 @method setCharging:
 @abstract Sets whether the battery is charging.
 @param charging Whether the battery is charging.
*/
- (void)setCharging:(BOOL)charging;

/*!
 @method isPlugged
 @abstract Returns <tt>YES</tt> if the laptop is connected to an external power source (AC power).
 @discussion Mac laptops usually show that they are plugged with a nice green light around the power chord jack.
 @result <tt>YES</tt> if the laptop is currently plugged.
*/
- (BOOL)isPlugged;

/*!
 @method setPlugged:
 @abstract Sets whether the laptop is plugged.
 @param plugged Whether the laptop is plugged.
*/
- (void)setPlugged:(BOOL)plugged;

/*!
 @method isActive
 @abstract Returns <tt>YES</tt> if the battery is currently being used.
 @discussion The active state determines whether the battery object is just an abstract model or a real, beating li-ion accumulator.
 Setting the active state to <tt>YES</tt> enables some advanced features like the battery timer.
 @result <tt>YES</tt> if the battery is active.
*/
- (BOOL)isActive;

/*!
 @method setActive:
 @abstract Sets whether the battery is active.
 @param active Whether the battery is active.
*/
- (void)setActive:(BOOL)active;

/*!
 @method timeToFullCharge
 @abstract Returns the estimated number of seconds to full charge, or -1 if the battery is not charging.
 @result The estimated number of seconds to full charge, or -1 if the battery is not charging.
*/
- (NSTimeInterval)timeToFullCharge;

/*!
 @method setTimeToFullCharge:
 @abstract Sets the time to full charge of the battery.
 @param time The time to full charge of the battery.
*/
- (void)setTimeToFullCharge:(NSTimeInterval)time;

/*!
 @method timeToEmpty
 @abstract Returns the estimated number of seconds to full depletion, or -1 if the battery is not being drained.
 @result The estimated number of seconds to full depletion, or -1 if the battery is not being drained.
*/
- (NSTimeInterval)timeToEmpty;

/*!
 @method setTimeToEmpty:
 @abstract Sets the time to exhaustion of the battery.
 @param time The time to exhaustion of the battery.
*/
- (void)setTimeToEmpty:(NSTimeInterval)time;

/*!
 @method timeOnBattery
 @abstract Returns the number of seconds elapsed on battery power.
 @discussion The current implementation actually increments the counter every minute, so the value returned
 is actually the number of minutes elapsed on battery power.
 @result The number of seconds elapsed on battery power.
*/
- (NSTimeInterval)timeOnBattery;

/*!
 @method setTimeOnBattery:
 @abstract Sets the amount of time elapsed on battery power.
 @param time The amount of time elapsed on battery power.
*/
- (void)setTimeOnBattery:(NSTimeInterval)time;

/*!
 @method incrementTimeOnBattery
 @abstract Increments the amount of time elapsed on battery.
 @discussion This method increments the battery timer by 60 seconds. It is meant to be called by a timer
 that is started when the power source is set to battery (i.e., when setting <tt>plugged</tt> to <tt>NO</tt>).
*/
- (void)incrementTimeOnBattery;

/*!
 @method resetTimeOnBattery
 @abstract Resets the amount of time elapsed on battery.
 @discussion This method sets the battery timer to zero.
 */
- (void)resetTimeOnBattery;

/*!
 @method designCapacity
 @abstract Returns the factory default capacity of the battery.
 @discussion The factory default capacity of a battery is the maximum amount of storable charge according to the manufacturer,
 expressed in milli Ampere per hour (mAh).
 @result The factory default capacity of the battery.
 */
- (int)designCapacity;

/*!
 @method setDesignCapacity:
 @abstract Sets the factory default capacity of the battery.
 @param designCapacity The factory default capacity of the battery.
 */
- (void)setDesignCapacity:(int)designCapacity;

/*!
 @method manufacturer
 @abstract Returns the name of the manufacturer of the battery.
 @discussion The manufacturer is the name of the company which produces the battery device.
 @result The name of the manufacturer of the battery.
 */
- (NSString *)manufacturer;

/*!
 @method setManufacturer:
 @abstract Sets the name of the manufacturer of the battery.
 @param manufacturer The name of the manufacturer of the battery.
 */
- (void)setManufacturer:(NSString *)manufacturer;

/*!
 @method deviceName
 @abstract Returns the device name of the battery.
 @discussion The device name is the name of the model of the battery.
 @result The device name of the battery.
 */
- (NSString *)deviceName;

/*!
 @method setDeviceName:
 @abstract Sets the device name of the battery.
 @param deviceName The device name of the battery.
 */
- (void)setDeviceName:(NSString *)deviceName;

/*!
 @method serial
 @abstract Returns the serial identifier of the receiver.
 @result The serial identifier of the receiver.
 */
- (NSString *)serial;

/*!
 @method setSerial:
 @abstract Sets the serial identifier of the receiver.
 @param serial The serial identifier.
 */
- (void)setSerial:(NSString *)serial;

/*!
 @method manufactureDate
 @abstract Returns the manufacture date of the receiver.
 @result The manufacture date of the receiver.
 */
- (NSCalendarDate *)manufactureDate;

/*!
 @method setManufactureDate:
 @abstract Sets the manufacture date of the receiver.
 @param manufactureDate The manufacture date.
 */
- (void)setManufactureDate:(NSCalendarDate *)manufactureDate;

/*!
 @method uniqueID
 @abstract Returns a unique ID for the battery.
 @discussion The unique ID is a hash of the deviceName, manufacturer, manufactureDate and serial.
 @result The unique ID for the battery.
 */
- (NSString *)uniqueID;

@end
