//
//  MonitoringSession.m
//  MiniBatteryLogger
//
//  Created by delphine on 5-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "MonitoringSession.h"
#import "LocalBatteryManager.h"

@interface MonitoringSession (Private)

- (void)_update;
- (void)setDuration:(NSTimeInterval)len;

@end

@implementation MonitoringSession

+ (MonitoringSession *)session
{
	return [[[MonitoringSession alloc] init] autorelease];
}

- (id)init
{
	[self initWithEvents:[NSMutableArray array]];
	[self setDate:[NSCalendarDate calendarDate]];
	[self setModified:NO];
	
	return self;
}

- (id)initWithEvents:(NSArray *)arr
{
	if (self = [super init])
	{
		[self setEvents:arr];
		[self _update];
	}
	return self;
}

- (void)dealloc
{
	[events release];
	[comment release];
	[summary release];
	[date release];
	[super dealloc];
}

+ (NSString *)folderPath
{
	return [@"~/Library/Application Support/MiniBatteryLogger" stringByExpandingTildeInPath];
}

+ (NSString *)sessionsPathForIndex:(int)index
{
	return [[[self class] folderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Sessions/%d", index]];
}

+ (NSString *)filePathForIndex:(int)index
{
	return [[self folderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"InternalBattery-%d.savedsessions", index]];
}


+ (NSArray *)loadSessionsForIndex:(int)index
{
	NSString *sessionsPath = [[self class] sessionsPathForIndex:index];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSArray *contents = [fileManager directoryContentsAtPath:sessionsPath];
	if (contents != nil)
	{
		contents = [contents sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		NSMutableArray *sessions = [NSMutableArray arrayWithCapacity:[contents count]];
		NSEnumerator *contentsEnum = [contents reverseObjectEnumerator];
		NSString *filePath;
		int i = 0;
		while (filePath = [contentsEnum nextObject])
		{
			if ([filePath rangeOfString:@".monitoringsession"].length > 0)
			{
				[sessions insertObject:[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionsPath stringByAppendingPathComponent:filePath]]
							   atIndex:i];
				i++;
			}
		}
		return [[sessions copy] autorelease];
	}
	return nil;	
}

+ (NSArray *)loadSessionsPre1_5ForIndex:(int)index;
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] filePathForIndex:index]];
}

+ (void)saveToFilePre1_5Sessions:(NSArray *)sessions forIndex:(int)index
{
	NSString *folderPath = [[self class] folderPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:folderPath] == NO)
	{
		[fileManager createDirectoryAtPath:folderPath
								attributes: nil];
	}
	
	[NSKeyedArchiver archiveRootObject:sessions
								toFile:[[self class] filePathForIndex:index]];
}

+ (void)saveToFileSessions:(NSArray *)sessions forBattery:(NSString *)name atIndex:(int)index
{
	[self saveToFileSessions:sessions forBattery:name atIndex:index removeMissing:NO];
}

+ (void)saveToFileSessions:(NSArray *)sessions forBattery:(NSString *)name atIndex:(int)index removeMissing:(BOOL)remove
{
	NSString *folderPath = [[self class] folderPath];
	NSString *path;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:folderPath] == NO)
	{
		[fileManager createDirectoryAtPath:folderPath
								attributes: nil];
	}
	path = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d", name, index]];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createDirectoryAtPath:path
								attributes: nil];
	}
	path = [path stringByAppendingPathComponent:@"Sessions"];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createDirectoryAtPath:path
								attributes: nil];
	}
	
	/* Save current sessions */
	int i;
	NSMutableArray *sessionFileNames = [NSMutableArray arrayWithCapacity:[sessions count]];
	for (i = 0; i < [sessions count]; i++)
	{
		MonitoringSession *session = [sessions objectAtIndex:i];
		NSString *fileName = [[session date] descriptionWithCalendarFormat:@"%Y-%m-%d_%H%M%S.monitoringsession"];
		//NSLog(@"%@", fileName);
		[sessionFileNames insertObject:fileName
							   atIndex:i];
		NSString *filePath = [path stringByAppendingPathComponent:fileName];
		if ([fileManager fileExistsAtPath:filePath] == NO ||
			[session isModified] ||
			[session isActive])
		{
			//NSLog(@"writing to file: %@", fileName);
			[fileManager createFileAtPath:filePath
								 contents:nil
							   attributes:nil];
			[NSKeyedArchiver archiveRootObject:session
										toFile:filePath];
		}
	}
	if (remove)
	{
		/* Removed no longer used sessions */
		NSArray *savedSessions = [fileManager directoryContentsAtPath:path];
		for (i = 0; i < [savedSessions count]; i++)
		{
			if (![sessionFileNames containsObject:[savedSessions objectAtIndex:i]])
			{
				[fileManager removeFileAtPath:[path stringByAppendingPathComponent:[savedSessions objectAtIndex:i]]
									  handler:nil];
			}
		}
	}
}

+ (void)deleteFromDiskSession:(MonitoringSession *)session forBattery:(NSString *)name atIndex:(int)index
{
	NSString *folderPath = [[self class] folderPath];
	NSString *fileName = [[session date] descriptionWithCalendarFormat:@"%Y-%m-%d_%H%M%S.monitoringsession"];
	NSString *path = [[[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d", name, index]] stringByAppendingPathComponent:@"Sessions"] stringByAppendingPathComponent:fileName];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path])
	{
		[fileManager removeFileAtPath:path
							  handler:nil];
	}
}

+ (NSArray *)loadSessionsForBattery:(NSString *)name atIndex:(int)index
{
	if (name != nil &&
			index > -1)
	{
		NSString *sessionsPath = [[[self folderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d", name, index]] stringByAppendingPathComponent:@"Sessions"];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSArray *contents = [fileManager directoryContentsAtPath:sessionsPath];
		if (contents != nil)
		{
			contents = [contents sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSMutableArray *sessions = [NSMutableArray arrayWithCapacity:[contents count]];
			NSEnumerator *contentsEnum = [contents reverseObjectEnumerator];
			NSString *filePath;
			int i = 0;
			while (filePath = [contentsEnum nextObject])
			{
				if ([filePath rangeOfString:@".monitoringsession"].length > 0)
				{
					MonitoringSession *session = [NSKeyedUnarchiver unarchiveObjectWithFile:[sessionsPath stringByAppendingPathComponent:filePath]];
					
					if (session != nil)
					{
						[sessions insertObject:session
									   atIndex:i];
						i++;
					}
					else
					{
						NSLog(@"*** Got a nil session: %@", session);
					}
				}
			}
			return [[sessions copy] autorelease];
		}
	}
	return nil;	
}

+ (void)saveToFileSessions:(NSArray *)sessions forIndex:(int)index
{
	NSString *folderPath = [[self class] folderPath];
	NSString *path;

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:folderPath] == NO)
	{
		[fileManager createDirectoryAtPath:folderPath
								attributes: nil];
	}
	path = [folderPath stringByAppendingPathComponent:@"Sessions"];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createDirectoryAtPath:path
								attributes: nil];
	}
	path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", index]];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createDirectoryAtPath:path
								attributes: nil];
	}

	/* Save current sessions */
	int i;
	NSMutableArray *sessionFileNames = [NSMutableArray arrayWithCapacity:[sessions count]];
	for (i = 0; i < [sessions count]; i++)
	{
		MonitoringSession *session = [sessions objectAtIndex:i];
		NSString *fileName = [[session date] descriptionWithCalendarFormat:@"%Y-%m-%d_%H%M%S.monitoringsession"];
		[sessionFileNames insertObject:fileName
							   atIndex:i];
		NSString *filePath = [path stringByAppendingPathComponent:fileName];
		if ([fileManager fileExistsAtPath:filePath] == NO ||
			[session isModified] ||
			[session isActive])
		{
			[fileManager createFileAtPath:filePath
								 contents:nil
							   attributes:nil];
			[NSKeyedArchiver archiveRootObject:session
										toFile:filePath];
		}
	}
	/* Removed no longer used sessions */
	NSArray *savedSessions = [fileManager directoryContentsAtPath:path];
	for (i = 0; i < [savedSessions count]; i++)
	{
		if (![sessionFileNames containsObject:[savedSessions objectAtIndex:i]])
		{
			[fileManager removeFileAtPath:[path stringByAppendingPathComponent:[savedSessions objectAtIndex:i]]
								  handler:nil];
		}
	}
}

+ (void)saveToFileSession:(MonitoringSession *)session forIndex:(int)index
{
	NSString *folderPath = [[self class] folderPath];
	NSString *path;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:folderPath] == NO)
	{
		[fileManager createDirectoryAtPath:folderPath
								attributes: nil];
	}
	path = [folderPath stringByAppendingPathComponent:@"Sessions"];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createDirectoryAtPath:path
								attributes: nil];
	}
	path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", index]];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		[fileManager createDirectoryAtPath:path
								attributes: nil];
	}
	
	NSString *filePath = [path stringByAppendingPathComponent:[[session date] descriptionWithCalendarFormat:@"%Y-%m-%d_%H%M%S.monitoringsession"]];
	if ([fileManager fileExistsAtPath:filePath] == NO ||
		[session isModified] ||
		[session isActive])
	{
		[fileManager createFileAtPath:filePath
							 contents:nil
						   attributes:nil];
		[NSKeyedArchiver archiveRootObject:session
									toFile:filePath];
	}
}

+ (BOOL)existPre1_5Sessions
{
	BOOL exist = NO;	
	int i;
	for (i = 0; i < [LocalBatteryManager installedBatteries]; i++)
	{
		exist |= ([NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] filePathForIndex:i]] != nil);
	}
	return exist;
}

+ (BOOL)existPre1_7Sessions
{
	BOOL exist = NO;	
	int i;
	for (i = 0; i < [LocalBatteryManager installedBatteries]; i++)
	{
		exist |= ([self loadSessionsForIndex:i] != nil);
	}
	return exist;
}

#pragma mark === Accessors ===

- (BOOL)isActive
{
	return active;
}
- (void)setActive:(BOOL)flag
{
	active = flag;
}

- (BOOL)isModified
{
	return modified;
}
- (void)setModified:(BOOL)flag
{
	modified = flag;
}

- (NSString *)comment
{
	return comment;
}
- (void)setComment:(NSString *)str
{
	[str retain];
	[comment release];
	comment = str;

	// Mark as modified
	[self setModified:YES];
}

- (NSCalendarDate *)date
{
	return date;
}
- (void)setDate:(NSCalendarDate *)d
{
	[d retain];
	[date release];
	date = d;
}

- (NSTimeInterval)duration
{
	return duration;
}

- (NSArray *)events
{
	return events;
}
- (void)setEvents:(NSArray *)arr
{
	[events autorelease];
	events = [arr mutableCopy];
}

- (NSString *)summary
{
	return summary;
}
- (void)setSummary:(NSString *)str
{
	[str retain];
	[summary release];
	summary = str;
}

- (NSImage *)statusImage
{
	return [NSImage imageNamed:(active ? @"active" : @"inactive")];
}

- (void)addEvent:(MBLEvent *)event
{
	[events addObject:event];
	[self setModified:YES];
	[self _update];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		[self setEvents:[coder decodeObjectForKey:@"events"]];
		[self setComment:[coder decodeObjectForKey:@"comment"]];
		// Saved sessions are inactive by definition
		[self setActive:NO];
		[self setModified:NO];
		
		[self _update];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:events forKey:@"events"];
	[coder encodeObject:comment forKey:@"comment"];
}

@end

@implementation MonitoringSession (Private)

- (void)_update
{
	// Nothing to do if empty
	if ([events count] < 1)
	{
		return;
	}
	MBLEvent *firstEvent, *lastEvent;
	firstEvent = [events objectAtIndex:0];
	lastEvent = [events objectAtIndex:([events count] - 1)];
	
	[self setDuration:[[lastEvent date] timeIntervalSinceDate:[firstEvent date]]];
	[self setDate:[firstEvent date]];
	[self setSummary:[NSString stringWithFormat:NSLocalizedString(@"Session started %@ at %@, monitoring for %@ h", @"Session started %@ at %@, monitoring for %@ h"),
		[date descriptionWithCalendarFormat:@"%a, %e %B %Y"],
		[date descriptionWithCalendarFormat:@"%H:%M:%S"],
		[[NSValueTransformer valueTransformerForName:@"SecondsToMinutesCompactTransformer"] transformedValue:[NSNumber numberWithInt:duration]]]];
	
}

- (void)setDuration:(NSTimeInterval)len
{
	// We are using an instance variable for performance reasons.
	duration = len;
}

@end
