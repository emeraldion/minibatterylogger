//
//  BatterySnapshot.h
//  MiniBatteryLogger
//
//  Created by delphine on 13-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"

enum {
    MBLSnapshotMaxCapacityAscending = 1,
    MBLSnapshotMaxCapacityDescending = 2,
    MBLSnapshotCycleCountAscending = 4,
    MBLSnapshotCycleCountDescending = 8,
    MBLSnapshotDateAscending = 16,
    MBLSnapshotDateDescending = 32	
};

/*!
 @class BatterySnapshot
 @abstract Class representing a snapshot of a battery's parameters at a given time in history.
 @discussion BatterySnapshot objects are composed by an immutable battery, which is the object of the snapshot,
 a timestamp and an optional comment string.
 */
@interface BatterySnapshot : NSObject <NSCoding> {

	NSCalendarDate *date;
	Battery *battery;
	NSString *comment;
}

/*!
 @method initWithBattery:date:
 @abstract Initializes the receiver with a battery content and a timestamp.
 @param batt The battery for which you want to create a snapshot.
 @param date A date to use as a timestamp for the snapshot.
 @result This method returns the receiver.
 */
- (id)initWithBattery:(Battery *)batt date:(NSCalendarDate *)date;

/*!
 @method initWithBattery:
 @abstract Initializes the receiver with a battery content.
 @param batt The battery for which you want to create a snapshot.
 @result This method returns the receiver.
 */
- (id)initWithBattery:(Battery *)batt;

/*!
 @method snapshot
 @abstract Factory method that returns an autoreleased BatterySnapshot object.
 @result An autoreleased BatterySnapshot object.
 */
+ (id)snapshot;

/*!
 @method setDate:
 @abstract Sets the timestamp of the receiver.
 @param date A date to use as a timestamp for the snapshot.
 */
- (void)setDate:(NSCalendarDate *)date;

/*!
 @method date
 @abstract Returns the timestamp of the receiver.
 @result The timestamp of the receiver.
 */
- (NSCalendarDate *)date;

/*!
 @method setBattery:
 @abstract Sets the battery of the receiver.
 @param batt The battery for which you want to create a snapshot.
 */
- (void)setBattery:(Battery *)batt;

/*!
 @method battery
 @abstract Returns the battery of the receiver.
 @result The battery of the receiver.
 */
- (Battery *)battery;

/*!
 @method setComment:
 @abstract Sets a comment to describe the receiver.
 @discussion Comments are used to describe the snapshot in lists, graphics etc.
 @param comment A comment to describe the receiver.
 */
- (void)setComment:(NSString *)comment;

/*!
 @method comment
 @abstract Returns a comment for the receiver.
 @result A comment for the receiver.
 */
- (NSString *)comment;

/* This is the mother of all comparison methods */
- (NSComparisonResult)compareSnapshot:(BatterySnapshot *)other mode:(int)mode;

/* Convenience comparison methods */
- (NSComparisonResult)compareSnapshotCycleCountAscending:(BatterySnapshot *)other;
- (NSComparisonResult)compareSnapshotCycleCountDescending:(BatterySnapshot *)other;
- (NSComparisonResult)compareSnapshotMaxCapacityAscending:(BatterySnapshot *)other;
- (NSComparisonResult)compareSnapshotMaxCapacityDescending:(BatterySnapshot *)other;
- (NSComparisonResult)compareSnapshotDateAscending:(BatterySnapshot *)other;
- (NSComparisonResult)compareSnapshotDateDescending:(BatterySnapshot *)other;

@end
