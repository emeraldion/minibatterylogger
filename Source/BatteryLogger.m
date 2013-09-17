//
//  BatteryLogger.m
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "BatteryLogger.h"

static NSString *BatteryLoggerFolderName =	@"~/Library/Logs/MiniBatteryLogger";
static NSString *BatteryLoggerFileName =	@"MiniBatteryLogger.log";

static int BatteryLoggerRotateMaxFileSize = (2 << 20);

@implementation BatteryLogger

- (id)init
{
	//NSLog(@"init");
	if (self = [super init])
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSString *folderPath = [[self class] logFolderPath];
		if (![fileManager fileExistsAtPath:folderPath])
		{
			[fileManager createDirectoryAtPath:folderPath
									attributes:nil];
		}
		
		NSString *logFilePath = [[self class] logPath];
		if (![fileManager fileExistsAtPath:logFilePath])
		{
			[fileManager createFileAtPath:logFilePath
								 contents:nil
							   attributes:nil];
		}

		logFile = [[NSFileHandle fileHandleForUpdatingAtPath:logFilePath] retain];
	}
	return self;
}

- (void)dealloc
{
	[logFile release];
	[super dealloc];
}

- (void)clearLog
{
}

+ (void)initialize
{
	//NSLog(@"initialize");
	NSFileManager *fileManager = [NSFileManager defaultManager];

	/*
	NSLog(@"%d", [fileManager fileExistsAtPath:[self logPath]]);
	NSLog(@"%@", [fileManager fileAttributesAtPath:[self logPath]
									  traverseLink:NO]);
	NSLog(@"%@", [[fileManager fileAttributesAtPath:[self logPath]
									   traverseLink:NO] objectForKey:NSFileSize]);
	*/
	if ([fileManager fileExistsAtPath:[self logPath]] &&
		[[[fileManager fileAttributesAtPath:[self logPath]
							   traverseLink:NO] objectForKey:NSFileSize] intValue] > BatteryLoggerRotateMaxFileSize)
	{
		[self rotateLogs];
	}
}

+ (NSString *)logFolderPath
{
	return [BatteryLoggerFolderName stringByExpandingTildeInPath];
}

+ (NSString *)logPath
{
	return [[BatteryLoggerFolderName stringByAppendingPathComponent:BatteryLoggerFileName] stringByExpandingTildeInPath];
}

+ (void)rotateLogs
{
	int zipped = 1;
	int i;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Scan logs directory in search of already zipped logs
	NSArray *contents = [fileManager directoryContentsAtPath:[self logFolderPath]];
	for (i = 0; i < [contents count]; i++)
	{
		NSString *path = [contents objectAtIndex:i];
		if ([path rangeOfString:@".gz"].location == [path length] - 3)
		{
			zipped++;
		}
	}

	// Launch NSTask with gzip command to compress current log file
	NSTask *rotateTask = [[NSTask alloc] init];
	[rotateTask setLaunchPath:@"/usr/bin/gzip"];
	[rotateTask setArguments:[NSArray arrayWithObjects:[[BatteryLoggerFolderName stringByAppendingPathComponent:BatteryLoggerFileName] stringByExpandingTildeInPath],
		nil]];
	[rotateTask launch];
	
	// Synchronous call
	[rotateTask waitUntilExit];

	// Rename just created archive with numbered extension
	[fileManager movePath:[[self logPath] stringByAppendingPathExtension:@"gz"]
				   toPath:[[self logPath] stringByAppendingPathExtension:[NSString stringWithFormat:@"%d.gz", zipped]]
				  handler:NULL];
}

- (void)logEvent:(BatteryEvent *)event
{
	[self logText:[event description]];
}

- (void)logText:(NSString *)txt
{
	[logFile seekToEndOfFile];
	[logFile writeData:[[txt stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
