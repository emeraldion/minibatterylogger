//
//  NSImage+MBLUtils.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryEvent.h"
#import "Battery.h"

/*!
 @category NSImage (MBLUtils)
 @abstract NSImage additions for MiniBatteryLogger
 */
@interface NSImage (MBLUtils)

/*!
 @method imageForBattery:
 @abstract Returns a Dock icon for the given battery.
 @param battery The battery to be represented as an icon.
 @deprecated This method is deprecated in version 1.8.2. Use <tt>dockIconForBattery:</tt> instead.
 */
+ (NSImage *)imageForBattery:(Battery *)battery;

/*!
 @method imageForBatteryEvent:
 @abstract Returns a Dock icon for the given battery event.
 @param event The battery event to be represented as an icon.
 @deprecated This method is deprecated in version 1.8.2. Use <tt>dockIconForBatteryEvent:</tt> instead.
 */
+ (NSImage *)imageForBatteryEvent:(BatteryEvent *)event;

/*!
 @method imageForCharge:plugged:charging:
 @abstract Returns a Dock icon for the given battery properties.
 @param charge The amount of charge of the battery.
 @param plugged <tt>YES</tt> if the image should represent a plugged battery.
 @param charging <tt>YES</tt> if the image should represent a charging battery.
 @deprecated This method is deprecated in version 1.8.2. Use <tt>dockIconForCharge:plugged:charging:</tt> instead.
 */
+ (NSImage *)imageForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging;

/*!
 @method dockIconForBattery:
 @abstract Returns a Dock icon for the given battery.
 @param battery The battery to be represented as an icon.
 */
+ (NSImage *)dockIconForBattery:(Battery *)battery;

/*!
 @method dockIconForBatteryEvent:
 @abstract Returns a Dock icon for the given battery.
 @param battery The battery to be represented as an icon.
 */
+ (NSImage *)dockIconForBatteryEvent:(BatteryEvent *)event;

/*!
 @method dockIconForCharge:plugged:charging:
 @abstract Returns a Dock icon for the given battery properties.
 @param charge The amount of charge of the battery.
 @param plugged <tt>YES</tt> if the image should represent a plugged battery.
 @param charging <tt>YES</tt> if the image should represent a charging battery.
 */
+ (NSImage *)dockIconForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging;

/*!
 @method dockIconForCharge:plugged:charging:
 @abstract Returns a Dock icon for the given battery properties.
 @param charge The amount of charge of the battery.
 @param plugged <tt>YES</tt> if the image should represent a plugged battery.
 @param charging <tt>YES</tt> if the image should represent a charging battery.
 @param installed <tt>YES</tt> if the image should represent an installed battery.
 @note This method was added in 1.8.3 (build 87)
 */
+ (NSImage *)dockIconForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging installed:(BOOL)installed;

/*!
 @method statusImageForCharge:plugged:charging:highlighted:
 @abstract Returns a status menu icon for the given battery properties.
 @param charge The amount of charge of the battery.
 @param plugged <tt>YES</tt> if the image should represent a plugged battery.
 @param charging <tt>YES</tt> if the image should represent a charging battery.
 @param highlighted <tt>YES</tt> if the image should be drawn into an highligthed menu item.
 */
+ (NSImage *)statusImageForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging highlighted:(BOOL)highlight;

/*!
 @method statusImageForCharge:plugged:charging:highlighted:
 @abstract Returns a status menu icon for the given battery properties.
 @param charge The amount of charge of the battery.
 @param plugged <tt>YES</tt> if the image should represent a plugged battery.
 @param charging <tt>YES</tt> if the image should represent a charging battery.
 @param installed <tt>YES</tt> if the image should represent a battery that is physically installed on the computer.
 @param highlighted <tt>YES</tt> if the image should be drawn into an highligthed menu item.
 */
+ (NSImage *)statusImageForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging installed:(BOOL)installed highlighted:(BOOL)highlight;

/*!
 @method statusImageForBattery:highlighted:
 @abstract Returns a status menu icon for the given battery.
 @param battery The battery.
 @param highlighted <tt>YES</tt> if the image should be drawn into an highligthed menu item.
 */
+ (NSImage *)statusImageForBattery:(Battery *)batt highlighted:(BOOL)highlight;

@end


@interface NSColor (MBLUtils)

+ (NSColor *)colorForCharge:(int)charge;

@end
