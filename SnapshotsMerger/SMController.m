//
//  SMController.m
//  MiniBatteryLogger
//
//  Created by delphine on 28-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "SMController.h"

@implementation SMController

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
	BatterySnapshots *snapshots1 = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/delphine/Desktop/snapshots1.batterysnapshots"];
	BatterySnapshots *snapshots2 = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/delphine/Desktop/snapshots2.batterysnapshots"];
	
	NSMutableArray *merged = [[[snapshots1 shots] arrayByAddingObjectsFromArray:[snapshots2 shots]] mutableCopy];
	[merged removeDuplicates];
	
	BatterySnapshots *mergedSnapshots = [[BatterySnapshots alloc] init];
	[mergedSnapshots setShots:merged];
	
	[NSKeyedArchiver archiveRootObject:mergedSnapshots
								toFile:@"/Users/delphine/Desktop/snapshots_merged.batterysnapshots"];
	[mergedSnapshots release];
	[merged release];
}

@end
