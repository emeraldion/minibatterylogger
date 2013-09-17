//
//  MBLLaunchApplicationActionTest.m
//  MiniBatteryLogger
//
//  Created by delphine on 22-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLLaunchApplicationActionTest.h"


@implementation MBLLaunchApplicationActionTest

- (void)testPerformAction
{
	MBLLaunchApplicationAction *action = [[MBLLaunchApplicationAction alloc] init];
	[action setApplication:@"TextEdit"];
	[action perform];
	usleep(2000);
	STAssertApplicationLaunched(@"TextEdit", @"Application was not launched");
	STAssertApplicationLaunched(@"Xcode", @"Why isn't Xcode running?");
	
}

@end
