//
//  AboutController.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "AboutController.h"

static NSString *MBLBuildNumber = @"MBLBuildNumber";
static NSString *MBLHumanReadableCopyrightKey = @"NSHumanReadableCopyright";

@implementation AboutController

- (id)init
{
	if (self = [super initWithWindowNibName:@"About"])
	{
	}
	return self;
}

- (void)windowDidLoad
{
	[appName setStringValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]];
	[appVersion setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Version %@ (%@)", @"Version %@ (%@)"),
		[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey],
		[[NSBundle mainBundle] objectForInfoDictionaryKey:MBLBuildNumber]]];
	[copyright setStringValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:MBLHumanReadableCopyrightKey]];	
}

@end
