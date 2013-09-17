//
//  ELMenuButton.m
//  MiniBatteryLogger
//
//  Created by delphine on 28-11-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "ELMenuButton.h"


@implementation ELMenuButton

- (id)init
{
	if (self = [super init])
	{
		[self setFocusRingType:NSFocusRingTypeNone];
	}
	return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	// Shows the contextual menu on left mouse click
	
	[self setState:NSOnState];
	[self highlight:YES];
	
	if ([self menu])
	{
		[NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
	}
	
	[self setState:NSOffState];
	[self highlight:NO];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	// Don't show contextual menu on right click
	return nil;
}

@end

@implementation ELMenuButton (NSNibAwaking)

- (void)awakeFromNib
{
	[self setFocusRingType:NSFocusRingTypeNone];
}

@end