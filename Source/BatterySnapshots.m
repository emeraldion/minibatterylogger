//
//  BatterySnapshots.m
//  MiniBatteryLogger
//
//  Created by delphine on 13-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "BatterySnapshots.h"


@implementation BatterySnapshots

+ (id)snapshots
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (self = [super init])
	{
		shots = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[shots release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		[self setShots:[coder decodeObjectForKey:@"shots"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:shots forKey:@"shots"];
}


+ (NSString *)folderPath
{
	return [@"~/Library/Application Support/MiniBatteryLogger" stringByExpandingTildeInPath];
}

+ (BOOL)removeSnapshotsForIndex:(int)index
{
	NSString *path = [[self folderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"InternalBattery-%d.batterysnapshots", index]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		return [[NSFileManager defaultManager] removeFileAtPath:path
														handler:NULL];
	}
	return NO;
}

+ (id)snapshotsForIndex:(int)index
{
	NSString *path = [[self folderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"InternalBattery-%d.batterysnapshots", index]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	}
	return nil;
}

+ (id)snapshotsForBattery:(NSString *)name atIndex:(int)index
{
	NSString *path = [[[self folderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d", name, index]] stringByAppendingPathComponent:@"snapshots.batterysnapshots"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	}
	return nil;
}

- (void)saveToFileForBattery:(NSString *)name atIndex:(int)index
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *folderPath = [[self class] folderPath];
	if ([fileManager fileExistsAtPath:folderPath] == NO)
	{
		[fileManager createDirectoryAtPath:folderPath
								attributes: nil];
	}
	
	NSString *path = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d", name, index]];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createFileAtPath:path
							 contents:nil
						   attributes:nil];
	}
	path = [path stringByAppendingPathComponent:@"snapshots.batterysnapshots"];
	
	[NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (int)count
{
	return [shots count];
}

- (void)addShot:(id)shot
{
	[shots addObject:[[BatterySnapshot alloc] initWithBattery:shot]];
}

- (NSMutableArray *)shots
{
	return shots;
}

- (void)setShots:(NSMutableArray *)s
{
	[s retain];
	[shots release];
	shots = s;
}

- (id)shotAtIndex:(int)index
{
	return [shots objectAtIndex:index];
}


@end
