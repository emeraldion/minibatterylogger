//
//  LocalBatteryManager.h
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryManager.h"

extern NSString *MBLProbeIntervalKey;
extern NSString *MBLStartMonitoringAtLaunchKey;

extern NSString *MBLProbeIntervalChangedNotification;

@interface LocalBatteryManager : BatteryManager <NSCopying> {

	SCDynamicStoreRef _dynamicStore;
	NSTimer *_pollTimer;
	NSString *_computerName;
}

+ (int)installedBatteries;

- (id)initWithIndex:(int)index;

- (void)setComputerName:(NSString *)name;
- (NSString *)computerName;

@end
