//
//  SharedArchive.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "SharedArchive.h"

static NSString *MBLArchiveEntryURLFormat = @"http://burgos.emeraldion.it/mbl/entry/%@";

@implementation SharedArchive

+ (void)archiveEntryForBattery:(NSString *)uid
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:MBLArchiveEntryURLFormat, uid]];
}

@end
