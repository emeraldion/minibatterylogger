//
//  RemoteConnectionController.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "RemoteConnectionController.h"
#include <netdb.h>

extern int h_errno;

static NSString *RCFavoritesPlistPath = nil;

@implementation RemoteConnectionController

+ (void)initialize
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
        RCFavoritesPlistPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/MiniBatteryLogger/remote_favorites.plist"] retain];
    }
}

+ (NSArray *)startupConnectionAddresses
{
	NSArray *faves = [NSArray arrayWithContentsOfFile:RCFavoritesPlistPath];
	NSEnumerator *faveEnum = [faves objectEnumerator];
	NSMutableArray *startup = [NSMutableArray array];
	NSDictionary *dict = nil;
	while (dict = (NSDictionary *)[faveEnum nextObject])
	{
		if ([[dict objectForKey:@"connectAtStartup"] boolValue])
		{
			[startup addObject:dict];
		}
	}
	return [[startup copy] autorelease];
}

- (id)init
{
	if (self = [super initWithWindowNibName:@"RemoteConnection"])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updateRemoteAddress:)
													 name:NSTableViewSelectionDidChangeNotification
												   object:favoritesList];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(saveFavorites:)
													 name:NSApplicationWillTerminateNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowDidLoad
{	
	NSMutableArray *favorites;
	if ((favorites = [self loadFavorites]) != nil)
	{
		[favoritesController setContent:favorites];
	}
	[favoritesList setTarget:self];
	[favoritesList setDoubleAction:@selector(connectToSelection:)];
	// Disable column sorting
	[favoritesList setSortDescriptors:nil];
}

- (NSMutableArray *)loadFavorites
{
	NSArray *faves = nil;
	faves = [NSArray arrayWithContentsOfFile:RCFavoritesPlistPath];
	return [[faves mutableCopy] autorelease];
}

- (void)saveFavorites:(NSNotification *)notif
{
	NSArray *faves = [favoritesController content];
	BOOL success = [faves writeToFile:RCFavoritesPlistPath
						   atomically:YES];
}

- (IBAction)addToFavorites:(id)sender
{
	NSString *address = [remoteAddressField stringValue];
	NSString *err_title;
	if ([address length] < 1 ||
		gethostbyname([address UTF8String]) == NULL)
	{
		switch (h_errno)
		{
			case HOST_NOT_FOUND:
			case NO_RECOVERY:
			case NO_DATA:
			case TRY_AGAIN:
				err_title = [NSString stringWithUTF8String:hstrerror(h_errno)];
				break;
			default:
				err_title = NSLocalizedString(@"Invalid address", @"Invalid address");
		}
		
		NSRunAlertPanel(err_title,
						NSLocalizedString(@"Please enter a valid hostname or IP address.", @"Please enter a valid hostname or IP address."),
						NSLocalizedString(@"OK", @"OK"),
						nil,
						nil);
		return;
	}
	[favoritesController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:address,
		@"address",
		[NSNumber numberWithBool:NO],
		@"connectAtStartup",
		nil]];
	[self saveFavorites:nil];
}

- (IBAction)connectToSelection:(id)sender
{
	if ([favoritesList selectedRow] == -1)
	{
		return;
	}
	[self connect:sender];
}

- (IBAction)connect:(id)sender
{
	if ([owner respondsToSelector:@selector(connectToAddress:)])
	{
		[owner connectToAddress:[remoteAddressField stringValue]];
	}
	[[self window] orderOut:sender];
}

- (IBAction)enterPassword:(id)sender
{
}

- (IBAction)dismissPasswordRequest:(id)sender
{
}

- (void)setOwner:(id)own
{
	owner = own;
}

- (void)requestPasswordFor:(NSString *)name
{
	[authorizationLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"The remote battery “%@” requires a password", @"The remote battery “%@” requires a password"), name]];

	[authorizationSheet makeKeyAndOrderFront:nil];
}

- (void)updateRemoteAddress:(NSNotification *)notif
{
	if ([[notif name] isEqual:NSTableViewSelectionDidChangeNotification])
	{
		NSArray *selectedObjects = [favoritesController selectedObjects];
		if (selectedObjects != nil &&
			[selectedObjects count] > 0)
		{
			[remoteAddressField setStringValue:[[selectedObjects objectAtIndex:0] objectForKey:@"address"]];
		}
		[self saveFavorites:nil];
	}			
}


@end
