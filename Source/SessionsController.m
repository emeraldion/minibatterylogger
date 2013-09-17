//
//  SessionsController.m
//  MiniBatteryLogger
//
//  Created by delphine on 6-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "SessionsController.h"


@implementation SessionsController

// Overridden to avoid removal of active sessions
- (BOOL)canRemove
{
	NSMutableArray *arr = [self arrangedObjects];
	int sel = [self selectionIndex];
	if (arr &&
		sel != NSNotFound &&
		[[arr objectAtIndex:sel] isActive])
	{
		return NO;
	}
	else
	{
		return [super canRemove];
	}
}

- (BOOL)canRemoveAll
{
	NSMutableArray *arr = [self arrangedObjects];
	if (arr)
	{
		int i = 0;
		while (i < [arr count])
		{
			if (![[arr objectAtIndex:i] isActive])
			{
				return YES;
			}
			i++;
		}
	}
	return NO;
}

/* This is an extension to the previous method in order to query directly if an item can be removed */
- (BOOL)canRemoveArrangedObjectAtIndex:(int)index
{
	NSMutableArray *arr = [self arrangedObjects];
	if (arr &&
		index != NSNotFound &&
		![[arr objectAtIndex:index] isActive])
	{
		return YES;
	}
	else
	{
		return NO;
	}	
}

/*
- (void)remove:(id)sender
{
	NSLog(@"[%@ remove:%@]", self, sender);
	id selection = [[self selectedObjects] objectAtIndex:0];
	NSLog(@"selection:%@", selection);
	[super remove:sender];
}
*/

@end
