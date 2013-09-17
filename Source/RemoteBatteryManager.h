//
//  RemoteBatteryManager.h
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryManager.h"

extern NSString *MBLProbeIntervalKey;
extern NSString *MBLStartMonitoringAtLaunchKey;

extern NSString *MBLBatteryManagerAuthorizationRequiredNotification;
extern NSString *MBLBatteryManagerRemoteConnectionErrorNotification;
extern NSString *MBLProbeIntervalChangedNotification;

/*!
 @class RemoteBatteryManager
 @abstract Objects of class <tt>RemoteBatteryManager</tt> manage batteries that
 are on remote computers, running the battery data sharing service.
 */
@interface RemoteBatteryManager : BatteryManager {

	NSString *_address;
	int _port;
	NSTimer *_pollTimer;
	NSMutableData *_dataBuffer;
}

/*!
 @method initWithRemoteAddress:port:index:
 @abstract Initializes the receiver with a network address, port and battery index.
 @discussion This method initializes a <tt>RemoteBatteryManager</tt> object
 creating a direct connection to a battery data sharing service known its
 address, port and battery index.
 @param address The address of the service, usually a hostname or IP address.
 @param port The port on which the sharing daemon is listening.
 @param index The position of the battery.
 @result The receiver.
 */
- (id)initWithRemoteAddress:(NSString *)address port:(int)port index:(int)index;

/*!
 @method initWithRemoteAddress:index:
 @abstract Initializes the receiver with a network address and battery index.
 @discussion This method initializes a <tt>RemoteBatteryManager</tt> object
 creating a direct connection to a battery data sharing service on the default
 listening port, known its address and battery index.
 @param address The address of the service, usually a hostname or IP address.
 @param index The position of the battery.
 @result The receiver.
 */
- (id)initWithRemoteAddress:(NSString *)address index:(int)index;

/*!
 @method setAddress:
 @abstract Sets the receiver's address.
 @param address The address of the receiver.
 */
- (void)setAddress:(NSString *)address;

/*!
 @method address
 @abstract Returns the receiver's address.
 @result The address of the receiver.
 */
- (NSString *)address;

/*!
 @method setPort:
 @abstract Sets the receiver's port.
 @param port The port of the receiver.
 */
- (void)setPort:(int)port;

/*!
 @method port
 @abstract Returns the receiver's port.
 @result The port of the receiver.
 */
- (int)port;

@end
