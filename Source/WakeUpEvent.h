//
//  WakeUpEvent.h
//  MiniBatteryLogger
//
//  Created by delphine on 7-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLEvent.h"

extern NSString *MBLWakeUpEventType;

/*!
 @class WakeUpEvent
 @abstract A <tt>MBLEvent</tt> subclass representing the system's wake from sleep mode.
 */
@interface WakeUpEvent : MBLEvent {

}

@end
