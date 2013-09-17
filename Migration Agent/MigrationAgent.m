//
//  MigrationAgent.m
//  MiniBatteryLogger
//
//  Created by delphine on 19-11-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "MigrationAgent.h"
#import "LocalBatteryManager.h"

@implementation MigrationAgent

+ (BOOL)hasJobToDo
{
	return (([MonitoringSession loadSessionsForIndex:0] != nil) &&
		([BatterySnapshots snapshotsForIndex:0] != nil)) ||
		(![CPSystemInformation isPowerPC]);
}

- (void) showStatus:(NSString *)status
{
	[statusLabel setStringValue:status];
}

- (void)convertSavedSessions:(id)target
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *systemUID = [CPSystemInformation systemUniqueID];
	
	// Load the old log file
	[self showStatus:@"Loading old log file..."];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/MiniBatteryLogger/InternalBattery-0.log" stringByExpandingTildeInPath]])
	{
		[self showStatus:@"Saving new log file..."];
		[[NSFileManager defaultManager] movePath:[@"~/Library/Application Support/MiniBatteryLogger/InternalBattery-0.log" stringByExpandingTildeInPath]
										  toPath:[@"~/Library/Logs/MiniBatteryLogger/MiniBatteryLogger.log" stringByExpandingTildeInPath]
										 handler:NULL];
	}
		
	int index;
	for (index = 0; index < [LocalBatteryManager installedBatteries]; index++)
	{	
		// Load the old-world saved sessions
		[self showStatus:@"Loading old sessions..."];

		NSArray *savedSessions = [MonitoringSession loadSessionsForIndex:index];
		
		if (savedSessions != nil)
		{
			// Save the new-world files
			[self showStatus:@"Saving new sessions..."];
			[MonitoringSession saveToFileSessions:savedSessions
									   forBattery:systemUID
										  atIndex:index];
		}
		
		// Convert to battery uniqueID
		if (![CPSystemInformation isPowerPC])
		{
			savedSessions = [MonitoringSession loadSessionsForBattery:systemUID
															  atIndex:index];
			if (savedSessions != nil)
			{
				LocalBatteryManager *mgr = [[LocalBatteryManager alloc] initWithIndex:index];
				[MonitoringSession saveToFileSessions:savedSessions
										   forBattery:[mgr serviceUID]
											  atIndex:index];
				[mgr release];
			}
		}

		[self showStatus:@"Loading old snapshots..."];
		BatterySnapshots *shots = [BatterySnapshots snapshotsForIndex:index];

		if (shots != nil)
		{
			[self showStatus:@"Saving new snapshots..."];
			[shots saveToFileForBattery:systemUID 
								atIndex:index];
			
			[self showStatus:@"Deleting old snapshots..."];
			[BatterySnapshots removeSnapshotsForIndex:index];
		}
	}
	
	[progress stopAnimation:nil];
	[self showStatus:@"Done"];
	[NSApp performSelectorOnMainThread:@selector(terminate:)
				withObject:nil
				waitUntilDone:NO];

	[pool release];
}

@end

@implementation MigrationAgent (NSApplicationNotifications)

- (void) applicationDidFinishLaunching:(NSNotification *) notif
{
	[NSApp activateIgnoringOtherApps:YES];
	[progress startAnimation:nil];
	
	[NSThread detachNewThreadSelector:@selector(convertSavedSessions:)
							 toTarget:self
						   withObject:nil];
}

@end