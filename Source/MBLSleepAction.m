//
//  MBLSleepAction.m
//  MiniBatteryLogger
//
//  Created by delphine on 22-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLSleepAction.h"

#define MBLSLEEPACTION_APPLESCRIPT @"tell application \"System Events\" to sleep"

@implementation MBLSleepAction

- (BOOL)isApplicable
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
	NSPredicate *predicate = (NSPredicate *)[_params objectForKey:@"predicate"];
	if (predicate != nil)
	{
		return [predicate evaluateWithObject:nil];
	}
#endif
	return NO;
}

- (void)perform
{
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:MBLSLEEPACTION_APPLESCRIPT];
	BOOL success = YES;
	NSDictionary *errorDict;
	success = [script compileAndReturnError:&errorDict];
	if (success)
	{
		NSAppleEventDescriptor *desc;
		desc = [script executeAndReturnError:&errorDict];
	}
}

@end
