//
//  BatteryStatusView.h
//  MiniBatteryLogger
//
//  Created by delphine on 5-05-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"

/*!
 @class BatteryStatusView
 @abstract View class for representing the status of a battery.
 */
@interface BatteryStatusView : NSView {

	/*!
	 @var _battery
	 @abstract The battery model that this object represents.
	 */
	Battery *_battery;
}

/*!
 @method setBattery:
 @abstract Sets the battery model of the receiver.
 @param batt The battery model.
 */
- (void)setBattery:(Battery *)batt;

/*!
 @method battery
 @abstract Returns the battery model of the receiver.
 @result The battery model of the receiver.
 */
- (Battery *)battery;

/*!
 @method copy:
 @abstract Copies the receiver to the Pasteboard.
 @param sender The sender of the action.
 */
- (IBAction)copy:(id)sender;

@end
