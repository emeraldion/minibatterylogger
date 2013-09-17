//
//  BatteryEvent+ServerAdditions.h
//  MiniBatteryLogger
//
//  Created by delphine on 16-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryEvent.h"
#import "Battery+ServerAdditions.h"

/*!
 @category ServerAdditions
 @abstract Methods that allow battery event generation from the responses of
 a server compliant to the mbl-battd protocol.
 */
@interface BatteryEvent (ServerAdditions)

/*!
 @method batteryEventWithServerResponse:
 @abstract Creates a <tt>BatteryEvent</tt> object from a server response.
 @param response The server response.
 @result An autoreleased <tt>BatteryEvent</tt> object.
 */
+ (id)batteryEventWithServerResponse:(NSString *)response;

/*!
 @method initWithServerResponse:
 @abstract Initializes the receiver with a server response.
 @param response The server response.
 @result The receiver.
 */
- (id)initWithServerResponse:(NSString *)response;

@end
