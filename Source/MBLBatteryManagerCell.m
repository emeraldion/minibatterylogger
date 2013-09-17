//
//  MBLBatteryManagerCell.m
//  MiniBatteryLogger
//
//  Created by delphine on 16-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLBatteryManagerCell.h"

NSDictionary *_MBLBatteryManagerCellFontAttrs;
NSDictionary *_MBLBatteryManagerCellHighlightedFontAttrs;

@implementation MBLBatteryManagerCell

+ (void)initialize
{
	_MBLBatteryManagerCellFontAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSFont fontWithName:@"Lucida Grande" size:10.0], NSFontAttributeName,
		[NSColor disabledControlTextColor], NSForegroundColorAttributeName,
		nil];
	_MBLBatteryManagerCellHighlightedFontAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSFont fontWithName:@"Lucida Grande" size:10.0], NSFontAttributeName,
		[NSColor highlightColor], NSForegroundColorAttributeName,
		nil];
}

- (id)init
{
    self = [super initTextCell:@""];
    if (self == nil)
        return nil;
	
    [self setEditable:NO];
	// Test for a Tiger only API
	if ([self respondsToSelector:@selector(setLineBreakMode:)])
	{
		[self setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	[self setFont:[NSFont fontWithName:@"Lucida Grande" size:12.0]];
	
    return self;
}

- (void)dealloc
{
    //[_title release];
	//[_details release];
	
    [super dealloc];
}

- (void)_setTitle:(NSString *)title
{
	//[title retain];
	//[_title release];
	_title = title;
}

- (void)_setDetails:(NSString *)details
{
	//[details retain];
	//[_details release];
	_details = details;
}

- (void)setObjectValue:(id)objectValue
{
	//NSLog(@"setObjectValue:%@", objectValue);
    if ([objectValue isKindOfClass:[NSArray class]]
        && [objectValue count] == 2) {
		
        [self _setTitle:[objectValue objectAtIndex:0]];
        [self _setDetails:[objectValue objectAtIndex:1]];
		
		[self setStringValue:_title];
    }
    else if ([objectValue isKindOfClass:[NSString class]]) {
        [super setObjectValue:objectValue];
    }
}

- (id)objectValue
{
	//NSLog(@"objectValue");
    return [NSArray arrayWithObjects:_title, _details, nil];
}

- (NSRect)_frameForTitle:(NSRect)cellFrame
{
    if (_details != [NSNull null]) {
		cellFrame.size.height /= 2.0;
		cellFrame.origin.y += cellFrame.size.height / 2.0 - 4.0;
    }
    return cellFrame;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
    // draw details
    if (_details != [NSNull null]) {
		NSPoint pt = NSMakePoint(cellFrame.origin.x + 2.0,
								 cellFrame.origin.y + cellFrame.size.height / 2.0 + 1.0);
		[_details drawAtPoint:pt
			   withAttributes:[self isHighlighted] ?
				_MBLBatteryManagerCellHighlightedFontAttrs :
			_MBLBatteryManagerCellFontAttrs];
    }
	
    // draw title
    [super drawWithFrame:[self _frameForTitle:cellFrame] inView:view];
}

- (void)editWithFrame:(NSRect)frame inView:(NSView *)controlView
			   editor:(NSText *)editor
			 delegate:(id)delegate
				event:(NSEvent *)theEvent
{
	[super editWithFrame:[self _frameForTitle:frame]
				  inView:controlView
				  editor:editor
				delegate:delegate
				   event:theEvent];
}

- (void)selectWithFrame:(NSRect)frame inView:(NSView *)controlView
				 editor:(NSText *)editor
			   delegate:(id)delegate
				  start:(int)selStart
				 length:(int)selLength
{
	[super selectWithFrame:[self _frameForTitle:frame]
					inView:controlView
					editor:editor
				  delegate:delegate
					 start:selStart
					length:selLength];
}

- (void)endEditing:(NSText *)textObj
{
    [self _setTitle:[textObj string]];
	
	[super endEditing:textObj];
}

@end