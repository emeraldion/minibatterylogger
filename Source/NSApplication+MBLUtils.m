//
//  NSApplication+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 17-08-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "NSApplication+MBLUtils.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation NSApplication (MBLUtils)

- (void)relaunch:(id)sender
{
	NSString *relaunchPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/relaunch.app/Contents/MacOS/relaunch"];
	if (![[NSFileManager defaultManager] isExecutableFileAtPath:relaunchPath]) {
		return;
	}
	[NSTask launchedTaskWithLaunchPath:relaunchPath arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] executablePath], [NSString stringWithFormat:@"%d", getpid()], nil]];
	[[NSApplication sharedApplication] terminate:sender];
}

@end
