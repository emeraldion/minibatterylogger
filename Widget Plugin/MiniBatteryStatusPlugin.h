//
//  MiniBatteryStatusPlugin.h
//  MiniBatteryStatus
//
//  Created by delphine on 7-03-2006.
//  Copyright 2006 Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <Growl/Growl.h>
#import "PowerDefines.h"
#import "BatteryManager.h"
#import "LocalBatteryManager.h"
#import "DemoBatteryManager.h"

/*!
 @class MiniBatteryStatusPlugin
 @abstract Widget Plugin for MiniBatteryStatus.
*/
@interface MiniBatteryStatusPlugin : NSObject <GrowlApplicationBridgeDelegate> {
	
	WebView *webView;
	NSDictionary *growlDictionary;
	NSMutableArray *batteryManagers;
	BatteryManager *batteryManager;
}

- (id)initWithWebView:(WebView *)aWebView;
- (void)setWebView:(WebView *)aWebView;

/*!
 @method charge
 @abstract Returns the charge amount of the battery currently being monitored.
 */
- (int)charge;

/*!
 @method capacity
 @abstract Returns the capacity of the battery currently being monitored.
 */
- (int)capacity;

/*!
 @method maxCapacity
 @abstract Returns the maximum capacity of the battery currently being monitored.
 */
- (int)maxCapacity;

/*!
 @method designCapacity
 @abstract Returns the design capacity of the battery currently being monitored.
 */
- (int)designCapacity;

/*!
 @method amperage
 @abstract Returns the value of amperage of the battery currently being monitored.
 */
- (int)amperage;

/*!
 @method voltage
 @abstract Returns the value of voltage of the battery currently being monitored.
 */
- (int)voltage;

/*!
 @method cycleCount
 @abstract Returns the number of cycles of the battery currently being monitored.
 */
- (int)cycleCount;

/*!
 @method isInstalled
 @abstract Returns <tt>YES</tt> when the battery currently being monitored is
 physically installed in the computer.
 */
- (BOOL)isInstalled;

/*!
 @method isPlugged
 @abstract Returns <tt>YES</tt> when the battery currently being monitored is plugged
 to an external power source.
 */
- (BOOL)isPlugged;

/*!
 @method isCharging
 @abstract Returns <tt>YES</tt> when the battery currently being monitored is charging.
 */
- (BOOL)isCharging;

/*!
 @method timeToEmpty
 @abstract Returns the time until the battery currently being monitored is depleted.
 */
- (NSTimeInterval)timeToEmpty;

/*!
 @method timeToFull
 @abstract Returns the time until the battery currently being monitored is fully charged.
 */
- (NSTimeInterval)timeToFull;

/*!
 @method machineType
 @abstract Returns a hardware code that represents the machine.
 */
- (NSString *)machineType;

/*!
 @method serviceUID
 @abstract Returns a unique identifier for the battery.
 */
- (NSString *)serviceUID;

/*!
 @method deviceName
 @abstract Returns the name of the battery hardware device.
 */
- (NSString *)deviceName;

/*!
 @method manufacturer
 @abstract Returns the name of the manufacturer of the battery.
 */
- (NSString *)manufacturer;

/*!
 @method manufactureDate
 @abstract Returns the date when the battery was manufactured.
 */
- (NSString *)manufactureDate;

/*!
 @method enterDemoMode
 @abstract Asks the plugin to switch to Demo mode.
 */
- (void)enterDemoMode;

/*!
 @method exitDemoMode
 @abstract Asks the plugin to exit from Demo mode.
 */
- (void)exitDemoMode;

- (void)windowScriptObjectAvailable:(WebScriptObject*)wso;
+ (NSString *)webScriptNameForSelector:(SEL)aSel;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSel;
+ (BOOL)isKeyExcludedFromWebScript:(const char*)key;

- (void)batteryPropertiesChanged:(NSNotification *)notif;
	
/* GrowlApplicationBridgeDelegate methods */

- (NSDictionary *) registrationDictionaryForGrowl;

- (void)notifyBatteryLowWithTitle:(NSString *)title details:(NSString *)details;
- (void)notifyBatteryFullWithTitle:(NSString *)title details:(NSString *)details;

@end
