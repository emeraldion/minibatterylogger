//
//  MBLWearTableView.m
//  MiniBatteryLogger
//
//  Created by delphine on 26-01-2007.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "MBLWearTableView.h"


@implementation MBLWearTableView

@end

@implementation MBLWearTableView (NSNibAwaking)

/* This table MUST remember column ordering */
- (void)awakeFromNib
{
	[self setAutosaveTableColumns:NO];
	[self setAutosaveTableColumns:YES];
}

@end