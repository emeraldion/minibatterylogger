//
//  BonjourBatteryManager.h
//  MiniBatteryLogger
//
//  Created by delphine on 31-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Cocoa/Cocoa.h>
#import "BatteryManager.h"

extern NSString *MBLProbeIntervalKey;
extern NSString *MBLStartMonitoringAtLaunchKey;

extern NSString *MBLBatteryManagerAuthorizationRequiredNotification;
extern NSString *MBLProbeIntervalChangedNotification;

/*!
 @class BonjourBatteryManager
 @abstract Objects of class <tt>BonjourBatteryManager</tt> manage batteries that
 are on remote computers, running the battery data sharing service.
*/
@interface BonjourBatteryManager : BatteryManager {
	
    NSInputStream *_inputStream;
	NSNetService *_netService;
    NSOutputStream *_outputStream;
    NSMutableData *_dataBuffer;
	NSTimer *_pollTimer;
}

/*!
 @method initWithService:index:
 @abstract Initializes the receiver with a Bonjour service.
 @discussion This method initializes a <tt>BonjourBatteryManager</tt> object
 with a <tt>NSNetService</tt> instance representing a battery data sharing 
 service found via Bonjour.
 @param srv A <tt>NSNetService</tt> instance representing a battery data sharing 
 service found via Bonjour.
 @param index The position of the battery.
 @result The receiver.
 */
- (id)initWithService:(NSNetService *)srv index:(int)index;

@end

