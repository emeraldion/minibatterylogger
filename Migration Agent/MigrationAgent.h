//
//  MigrationAgent.h
//  MiniBatteryLogger
//
//  Created by delphine on 19-11-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MonitoringSession.h"
#import "BatteryEvent.h"
#import "SleepEvent.h"
#import "WakeUpEvent.h"
#import "BatterySnapshots.h"
#import "CPSystemInformation.h"

@interface MigrationAgent : NSObject {

	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *statusLabel;
}

+ (BOOL)hasJobToDo;

- (void)showStatus:(NSString *)status;

- (void)convertSavedSessions:(id)target;

@end