//
//  NSFileManager+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 19-11-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "NSFileManager+MBLUtils.h"


@implementation NSFileManager (MBLUtils)

- (BOOL)emptyDirectoryAtPath:(NSString *)path
{
	BOOL ret = YES;
	NSArray *files = [self directoryContentsAtPath:path];
	int i;
	for (i = 0; i < [files count]; i++)
	{
		ret &= [self removeFileAtPath:[path stringByAppendingPathComponent:[files objectAtIndex:i]]
							  handler:nil];
	}
	return ret;
}

@end
