//
//  DemoBatteryManager.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-05-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryManager.h"

@interface DemoBatteryManager : BatteryManager {
	NSTimer *_demoTimer;
	int _charge;
	BOOL _descent;
	NSTimeInterval _interval;
}

- (void)setInterval:(NSTimeInterval)interval;
- (NSTimeInterval)interval;

@end
