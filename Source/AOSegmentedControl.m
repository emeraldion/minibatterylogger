//
//  AOSegmentedCell.m
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "AOSegmentedControl.h"

@implementation AOSegmentedControl

- (void)awakeFromNib
{
	// 26 is the height of normal-sized segmented control:
	[self setFrameSize:NSMakeSize([self frame].size.width, 26)];
}

- (NSCell *)cell
{
	NSSegmentedCell *cell = [super cell];
	// Test for Panther compatibility
	if ([cell respondsToSelector:@selector(setSegmentStyle:)])
	{
		[cell setSegmentStyle:NSSegmentedCellMetalStyle];
	}
	else if ([cell respondsToSelector:@selector(_setSegmentedCellStyle:)])
	{
		[cell _setSegmentedCellStyle:NSSegmentedCellMetalStyle];
	}
	return cell;
}

@end
