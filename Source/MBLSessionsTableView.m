//
//  MBLSessionsTableView.m
//  MiniBatteryLogger
//
//  Created by delphine on 25-01-2007.
//  Copyright 2006 Claudio Procida. All rights reserved.
//


#import "MBLSessionsTableView.h"

#define DRAG_TO_TRASH_SOUND_PATH @"/System/Library/Components/CoreAudio.component/Contents/Resources/SystemSounds/dock/drag to trash.aif"

NSString *MBLTableViewMouseExitedNotification = @"MBLTableViewMouseExited";

@implementation MBLSessionsTableView

- (id)initWithFrame:(NSRect)frame
{
	NSLog(@"initWithFrame:%@", NSStringFromRect(frame));
	if (self = [super initWithFrame:frame])
	{
		[self addTrackingRect:frame
						owner:self
					 userData:NULL
				 assumeInside:YES];
	}
	return self;
}

- (IBAction)copy:(id)sender
{
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	
	// Apply changes
	[sessionsController commitEditing];
	NSArray *arr = (NSArray *)[sessionsController arrangedObjects];
	int sel = [sessionsController selectionIndex];
	
	// Get CSV stream
	NSString *CSVString = [[[arr objectAtIndex:sel] events] CSVString];
	
	// Declare pasteboard types
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	
	// Put data into pasteboard
	[pboard setString:CSVString forType:NSStringPboardType];
}

- (int)draggedRow
{
	return draggedRow;
}
- (void)setDraggedRow:(int)row
{
	if (row >= 0)
	{
		draggedRow = row;
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLTableViewMouseExitedNotification
														object:self];
	//NSLog(@"Posting notification: %@", MBLTableViewMouseExitedNotification);
	[super mouseExited:theEvent];
}

@end

@implementation MBLSessionsTableView (NSDraggingSource)

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
#pragma unused (isLocal)
	return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationDelete)
	{
		if ([sessionsController canRemoveArrangedObjectAtIndex:draggedRow])
		{
			[sessionsController removeObjectAtArrangedObjectIndex:draggedRow];
			NSSound *trashSound = nil;
			NSFileManager *manager = [NSFileManager defaultManager];
			if ([manager fileExistsAtPath:DRAG_TO_TRASH_SOUND_PATH])
			{
				trashSound = [[NSSound alloc] initWithContentsOfFile:DRAG_TO_TRASH_SOUND_PATH
														 byReference:YES];
			}
			[trashSound play];
			[trashSound release];
		}
		else
		{
			NSBeep();
		}
	}
}

@end

@implementation MBLSessionsTableView (NSNibAwaking)

- (void)awakeFromNib
{
	[self addTrackingRect:[self frame]
					owner:self
				 userData:NULL
			 assumeInside:YES];	
}

@end