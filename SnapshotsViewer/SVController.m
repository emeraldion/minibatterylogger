//
//  SVController.m
//  MiniBatteryLogger
//
//  Created by delphine on 13-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "SVController.h"
#import "BatterySnapshots.h"

@implementation SVController

- (IBAction)open:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"batterysnapshots"]];
	if (NSOKButton == [openPanel runModal])
	{
		BatterySnapshots *snapshots = [NSKeyedUnarchiver unarchiveObjectWithFile:[openPanel filename]];
		[snapshotsController setContent:[snapshots shots]];
	}
}

@end
