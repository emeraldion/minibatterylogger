//
//  MBLBatteryManagersTableView.m
//  MiniBatteryLogger
//
//  Created by delphine on 16-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//
//	Based on code by KB (Kyle Brett?)
//  http://www.cocoadev.com/index.pl?MailStyleGradientSelection
//
//

#import "MBLBatteryManagersTableView.h"
#import "NSBezierPath+MBLUtils.h"

// We override (and may call) an undocumented private NSTableView method,
// so we need to declare that here
@interface NSObject (NSTableViewPrivateMethods)
- (id)_highlightColorForCell:(NSCell *)cell;
@end

@interface MBLBatteryManagersTableView (Private)
- (NSString *)_tfKeyForColumn:(int)columnIndex row:(int)rowIndex;
@end

@implementation MBLBatteryManagersTableView

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	/*
	if (!usesGradientSelection)
	{
		[super highlightSelectionInClipRect:clipRect];
		return;
	}
	 */
	
	NSColor *topLineColor, *bottomLineColor, *gradientStartColor, *gradientEndColor;
	
	// Color will depend on whether or not we are the first responder
	NSResponder *firstResponder = [[self window] firstResponder];
	if ( (![firstResponder isKindOfClass:[NSView class]]) ||
		 //(![(NSView *)firstResponder isDescendantOf:self]) ||
		 (![[self window] isKeyWindow]) ||
		 ([self usesDisabledGradientSelectionOnly]) )
	{
		topLineColor = [NSColor colorWithDeviceRed:(127.0/255.0) green:(126.0/255.0) blue:(126.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:(102.0/255.0) green:(102.0/255.0) blue:(102.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:(151.0/255.0) green:(151.0/255.0) blue:(151.0/255.0) alpha:1.0];
		gradientEndColor = bottomLineColor;
	}
	else
	{
		topLineColor = [NSColor colorWithDeviceRed:(0.0/255.0) green:(121.0/255.0) blue:(233.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:(0.0/255.0) green:(86.0/255.0) blue:(224.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:(57.0/255.0) green:(153.0/255.0) blue:(243.0/255.0) alpha:1.0];
		gradientEndColor = bottomLineColor;
	}
	
	NSIndexSet *selRows = [self selectedRowIndexes];
	int rowIndex = [selRows firstIndex];
	int endOfCurrentRunRowIndex, newRowIndex;
	NSRect highlightRect;
	
	while (rowIndex != NSNotFound)
	{
		if ([self selectionGradientIsContiguous])
		{
			newRowIndex = rowIndex;
			do {
				endOfCurrentRunRowIndex = newRowIndex;
				newRowIndex = [selRows indexGreaterThanIndex:endOfCurrentRunRowIndex];
			} while (newRowIndex == endOfCurrentRunRowIndex + 1);
			
			highlightRect = NSUnionRect([self rectOfRow:rowIndex],[self rectOfRow:endOfCurrentRunRowIndex]);
		}
		else
		{
			newRowIndex = [selRows indexGreaterThanIndex:rowIndex];
			highlightRect = [self rectOfRow:rowIndex];
		}
		
		if ([self hasBreakBetweenGradientSelectedRows])
			highlightRect.size.height -= 1.0;
		
		[topLineColor set];
		NSRectFill(highlightRect);
		
		highlightRect.origin.y += 1.0;
		highlightRect.size.height-=1.0;
		[bottomLineColor set];
		NSRectFill(highlightRect);
		
		highlightRect.size.height -= 1.0;
		
		[[NSBezierPath bezierPathWithRect:highlightRect] linearGradientFillWithStartColor:gradientStartColor
																				 endColor:gradientEndColor];
		
		rowIndex = newRowIndex;
	}
}

- (id)_highlightColorForCell:(NSCell *)cell
{
	if (!usesGradientSelection)
	{
		return [super _highlightColorForCell:cell];
	}
	return nil;
}

- (void)selectRow:(int)row byExtendingSelection:(BOOL)extend
{
	[super selectRow:row byExtendingSelection:extend];
	
	// If we are using a contiguous gradient, we need to force a redraw of more than
	// just the current row - all selected rows will need redrawing
	if ([self usesGradientSelection]&&[self selectionGradientIsContiguous])
		[self setNeedsDisplay:YES];
}

- (void)selectRowIndexes:(NSIndexSet *)rowIndexes byExtendingSelection:(BOOL)extend
{
	[super selectRowIndexes:rowIndexes byExtendingSelection:extend];
	
	// If we are using a contiguous gradient, we need to force a redraw of more than
	// just the current row - all selected rows will need redrawing
	if ([self usesGradientSelection]&&[self selectionGradientIsContiguous])
		[self setNeedsDisplay:YES];
}

- (void)deselectRow:(int)row;
{
	[super deselectRow:row];
	
	// If we are using a contiguous gradient, we need to force a redraw of more than
	// just the current row in case multiple are selected, as selected rows will need redrawing
	if ([self usesGradientSelection]&&[self selectionGradientIsContiguous])
		[self setNeedsDisplay:YES];
}

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns
								   event:(NSEvent*)dragEvent offset:(NSPointPointer)dragImageOffset
{
	// We need to save the dragged row indexes so that the delegate can choose how to colour the
	// text depending on whether it is being used for a drag image or not (eg. selected row may
	// have white text, but we still want to colour it black when drawing the drag image)
	draggedRows = dragRows;
	
	NSImage *image = [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns
												  event:dragEvent offset:dragImageOffset];
	
	draggedRows = nil;
	return image;
}

- (NSIndexSet *)draggedRows
{
	return draggedRows;
}

- (void)setUsesGradientSelection:(BOOL)flag
{
	usesGradientSelection = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)usesGradientSelection
{
	return usesGradientSelection;
}

- (void)setSelectionGradientIsContiguous:(BOOL)flag
{
	selectionGradientIsContiguous = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)selectionGradientIsContiguous
{
	return selectionGradientIsContiguous;
}

- (void)setUsesDisabledGradientSelectionOnly:(BOOL)flag
{
	usesDisabledGradientSelectionOnly = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)usesDisabledGradientSelectionOnly
{
	return usesDisabledGradientSelectionOnly;
}

- (void)setHasBreakBetweenGradientSelectedRows:(BOOL)flag
{
	hasBreakBetweenGradientSelectedRows = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)hasBreakBetweenGradientSelectedRows
{
	return hasBreakBetweenGradientSelectedRows;
}

- (void) textDidEndEditing: (NSNotification *) notification
{
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
	
    NSNumber *textMovement;
    textMovement = [userInfo objectForKey: @"NSTextMovement"];
	
    int movementCode;
    movementCode = [textMovement intValue];
	
    // see if this a 'pressed-return' instance
	
    if (movementCode == NSReturnTextMovement) {
        // hijack the notification and pass a different textMovement
        // value
		
        textMovement = [NSNumber numberWithInt: NSIllegalTextMovement];
		
        NSDictionary *newUserInfo;
        newUserInfo = [NSDictionary dictionaryWithObject: textMovement
												  forKey: @"NSTextMovement"];
		
        notification = [NSNotification notificationWithName:
			[notification name]
													 object: [notification object]
												   userInfo: newUserInfo];
    }
	
    [super textDidEndEditing: notification];
	
} // textDidEndEditing

/*
- ( void ) keyDown: ( NSEvent * ) event {
	id obj = [self delegate];
	unichar firstChar = [[event characters] characterAtIndex: 0];
	
	// if the user pressed delete and the delegate supports deleteKeyPressed
	if ( ( firstChar == NSDeleteFunctionKey ||
		   firstChar == NSDeleteCharFunctionKey ||
		   firstChar == NSDeleteCharacter) &&
		 [obj respondsToSelector: @selector( deleteKeyPressed:onRow: )] ) {
		id < GDTableViewDeleteKey > delegate = ( id < GDTableViewDeleteKey > ) obj;
		[delegate deleteKeyPressed: self onRow: [self selectedRowIndexes]];
	}
	
	[super keyDown:event];
}
*/

/*
- (void) drawRow: (int) rowIndex clipRect: (NSRect) clipRect
{
	NSColor *theColor;
	
	//if ([[self window] firstResponder] == self && [[self selectedRowIndexes] containsIndex:rowIndex] && ([self editedRow] != rowIndex))
	if ([[self window] firstResponder] == self && [[self selectedRowIndexes] containsIndex:rowIndex] && ([self editedRow] != rowIndex))
		theColor = [NSColor whiteColor];
	else
		theColor = [NSColor blackColor];
				
	NSEnumerator *enu = [[self tableColumns] objectEnumerator];
	NSTableColumn *col;
	
	while (col = [enu nextObject])
		if ([[col dataCell] respondsToSelector:@selector(setTextColor:)])
			[(id)[col dataCell] setTextColor:theColor];
	
	[super drawRow:rowIndex clipRect:clipRect];
}
*/
		
@end
