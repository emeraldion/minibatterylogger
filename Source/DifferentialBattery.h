//
//  DifferentialBattery.h
//  MiniBatteryLogger
//
//  Created by delphine on 30-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"

/*!
 @class DifferentialBattery:
 @abstract A battery subclass representing the difference between two batteries.
 @discussion DifferentialBattery instances are used where a comparison between two batteries is used.
 Properties of DifferentialBattery instances are set to the difference of the respective properties of
 the original batteries.
 */
@interface DifferentialBattery : Battery {

}

/*!
 @method colorForVoltage
 @abstract Returns the color for the voltage of the receiver.
 @discussion This method returns a color appropriate for displaying the differential voltage.
 For example, red color may characterize a negative difference, while green a positive one.
 @result The color for the voltage of the receiver.
 */
- (NSColor *)colorForVoltage;

/*!
 @method colorForMaxCapacity
 @abstract Returns the color for the maximum capacity of the receiver.
 @discussion This method returns a color appropriate for displaying the differential maximum capacity.
 For example, red color may characterize a negative difference, while green a positive one.
 @result The color for the maximum capacity of the receiver.
 */
- (NSColor *)colorForMaxCapacity;

/*!
 @method colorForDesignCapacity
 @abstract Returns the color for the design capacity of the receiver.
 @discussion This method returns a color appropriate for displaying the differential design capacity.
 For example, red color may characterize a negative difference, while green a positive one.
 @result The color for the design capacity of the receiver.
 */
- (NSColor *)colorForDesignCapacity;

/*!
 @method colorForCycleCount
 @abstract Returns the color for the cycle count of the receiver.
 @discussion This method returns a color appropriate for displaying the differential cycle count.
 For example, red color may characterize a negative difference, while green a positive one.
 @result The color for the cycle count of the receiver.
 */
- (NSColor *)colorForCycleCount;

@end

/*!
 @category DifferentialExtensions
 @abstract Additions to Battery class for use with DifferentialBattery.
 */

@interface Battery (DifferentialExtensions)

/*!
 @method differentialBattery:
 @abstract Returns the differential battery obtained by subtracting <tt>other</tt> from the receiver.
 @discussion This method returns a DifferentialBattery instance that represents the difference
 between the receiver and the battery <tt>other</tt>.
 @param other A battery to compare the receiver to.
 @result The differential battery obtained by subtracting <tt>other</tt> from the receiver.
 */
- (DifferentialBattery *)differentialBattery:(Battery *)other;

@end