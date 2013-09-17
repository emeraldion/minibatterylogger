//
//  SleepEvent.m
//  MiniBatteryLogger
//
//  Created by delphine on 7-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "SleepEvent.h"

NSString *MBLSleepEventType = @"MBLSleepEventType";

@implementation SleepEvent

- (NSString *)type
{
	return MBLSleepEventType;
}

@end
