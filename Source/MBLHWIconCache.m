//
//  MBLHWIconCache.m
//  MiniBatteryLogger
//
//  Created by delphine on 18-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLHWIconCache.h"

static NSDictionary *_MBLHWIconCacheDictionary;


@implementation MBLHWIconCache

+ (void)initialize
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"hardwareicons" ofType:@"plist"];
	_MBLHWIconCacheDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
}

+ (NSImage *)imageForModel:(NSString *)model
{
	id obj = [_MBLHWIconCacheDictionary objectForKey:model];
	if (obj)
	{
		return [NSImage imageNamed:obj];
	}
	return [NSImage imageNamed:@"unknown"];
}

@end
