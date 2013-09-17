//
//  MBLLaunchApplicationAction.m
//  MiniBatteryLogger
//
//  Created by delphine on 22-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLLaunchApplicationAction.h"


@implementation MBLLaunchApplicationAction

- (void)setApplication:(NSString *)appName
{
	[_params setObject:appName
				forKey:@"appName"];
}

- (NSString *)application
{
	return [_params objectForKey:@"appName"];
}

- (void)perform
{
	NSLog(@"perform: %@", [self application]);
	[[NSWorkspace sharedWorkspace] launchApplication:[self application]];
}

@end
