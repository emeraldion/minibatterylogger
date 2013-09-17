//
//  WakeUpEvent.m
//  MiniBatteryLogger
//
//  Created by delphine on 7-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "WakeUpEvent.h"

NSString *MBLWakeUpEventType = @"MBLWakeUpEventType";

@implementation WakeUpEvent

- (NSString *)type
{
	return MBLWakeUpEventType;
}

@end
