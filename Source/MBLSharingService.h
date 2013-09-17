//
//  MBLSharingService.h
//  MiniBatteryLogger
//
//  Created by delphine on 21-02-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryServer.h"

@protocol MBLSharingMethods

/* Service control methods */
- (oneway void)start;
- (oneway void)stop;

/* Battery server control methods */
- (oneway out BOOL)batteryServerRunning;
- (oneway void)setBatteryServerPublishes:(oneway in BOOL)yorn;
- (oneway void)startBatteryServer;
- (oneway void)stopBatteryServer;

@end

@interface MBLSharingService : NSObject <MBLSharingMethods> {

	BOOL _shouldKeepRunning;
	id master;
	BatteryServer *batteryserver;
}

+ (NSConnection *)startWorkerThreadMaster:(id)obj;

- (id)initForMaster:(id)theMaster;
- (void)setMaster:(id)theMaster;
- (void)setBatteryServer:(BatteryServer *)srv;

- (void)performSelector:(SEL)selector target:(id)tgt withObject:(id)anObj;

@end
