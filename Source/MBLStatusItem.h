//
//  MBLStatusItem.h
//  MiniBatteryLogger
//
//  Created by delphine on 16-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"
#import "MBLTypes.h"

extern NSString *MBLDisplayStatusItemKey;
extern NSString *MBLStatusItemModeKey;
extern NSString *MBLStatusItemHideTimeWhenPossibleKey;

/*!
 @class MBLStatusItem
 @abstract Objects of class <tt>MBLStatusItem</tt> represent a status item in the system menubar.
 */
@interface MBLStatusItem : NSObject {
	NSStatusItem *_statusItem;
	Battery *_battery;
	MBLStatusItemMode _mode;
	BOOL _hideTime;
	NSMutableDictionary *_fontAttributes;
}

/*!
 @method setMenu:
 @abstract Sets the menu of the status item.
 @param menu A menu.
 */
- (void)setMenu:(NSMenu *)menu;

/*!
 @method setBattery:
 @abstract Sets the battery represented by the status item.
 @param batt The battery represented by the status item.
 */
- (void)setBattery:(Battery *)batt;

/*!
 @method battery
 @abstract Returns the battery represented by the status item.
 @result The battery represented by the status item.
 */
- (Battery *)battery;

/*!
 @method setVisualizationMode:
 @abstract Sets the visualization mode of the status item.
 @param mode A visualization mode.
 */
- (void)setVisualizationMode:(MBLStatusItemMode)mode;

/*!
 @method visualizationMode
 @abstract Returns the visualization mode of the status item.
 @result The visualization mode of the status item.
 */
- (MBLStatusItemMode)visualizationMode;

/*!
 @method setHidesTimeWhenPossible:
 @abstract Forces the status item to hide time information when possible.
 @param hide Pass <tt>YES</tt> to hide time information when possible.
 */
- (void)setHidesTimeWhenPossible:(BOOL)hide;

/*!
 @method hidesTimeWhenPossible
 @abstract Returns <tt>YES</tt> when the status item hides time information when possible.
 @result <tt>YES</tt> if the status item hides time information when possible.
 */
- (BOOL)hidesTimeWhenPossible;

/*!
 @method activate
 @abstract Attaches the receiver to the system menubar.
 */
- (void)activate;

/*!
 @method remove
 @abstract Detaches the receiver from the system menubar.
 */
- (void)remove;

@end
