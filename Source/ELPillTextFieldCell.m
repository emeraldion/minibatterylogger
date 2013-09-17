//
//  ELPillTextFieldCell.m
//  ELPillTextField
//
//  Created by delphine on 25-03-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import "ELPillTextFieldCell.h"

@implementation ELPillTextFieldCell

- (id)initTextCell:(NSString *)str
{
	//NSLog(@"initTextCell:%@", str);
	if (self = [super initTextCell:str])
	{
		[self setLineBreakMode:NSLineBreakByTruncatingTail];
	}	
    return self;
}

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

- (void)setObjectValue:(id)objectValue
{
	//NSLog(@"setObjectValue:%@", objectValue);
	if ([objectValue isKindOfClass:[NSString class]]) {
        [super setObjectValue:objectValue];
    }
}

- (id)objectValue
{
    return _title;
}

- (NSRect)_frameForTitle:(NSRect)cellFrame
{
	const float radius = cellFrame.size.height / 2;

	cellFrame.origin.x += radius;
	cellFrame.size.width -= 2 * radius;

	/*
	NSLog(@"_frameForTitle:(%f,%f,%f,%f)",
		  cellFrame.origin.x,
		  cellFrame.origin.y,
		  cellFrame.size.width,
		  cellFrame.size.height);
	*/
    return cellFrame;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
	/*
	NSLog(@"drawWithFrame:(%f,%f,%f,%f)inView:%@",
		  cellFrame.origin.x,
		  cellFrame.origin.y,
		  cellFrame.size.width,
		  cellFrame.size.height,
		  view);
	 */
    // draw background
	
	NSRect pillRect = cellFrame;
	NSBezierPath *pill;
	
	[view lockFocus]; {
		/*
		[[[[self controlView] superview] backgroundColor] set];
		NSRectFill(cellFrame);
		 */
		if (YES || [self drawsBackground])
		{
			pill = [NSBezierPath bezierPathWithRoundedRect:pillRect
											  cornerRadius:pillRect.size.height / 2];
			//NSLog(@"backgroundColor:%@", [[self controlView] backgroundColor]);
			[[[self controlView] backgroundColor] set];
			[pill fill];
		}

		if ([self isBordered])
		{
			pillRect.origin.x += 0.5;
			pillRect.origin.y += 0.5;
			pillRect.size.width -= 1.0;
			pillRect.size.height -= 1.0;
			
			pill = [NSBezierPath bezierPathWithRoundedRect:pillRect
											  cornerRadius:pillRect.size.height / 2];
			[pill setLineWidth:1.0];
			[[[self controlView] borderColor] set];
			//[[NSColor blackColor] set];
			[pill stroke];
		}

	} [view unlockFocus];
	
    // draw title
    //[super drawWithFrame:[self _frameForTitle:cellFrame] inView:view];
	[self _drawTitleWithFrame:[self _frameForTitle:cellFrame]];
}

- (NSSize)optimalSize
{
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[[self controlView] font],
		NSFontAttributeName,
		[self textColor],
		NSForegroundColorAttributeName,
		nil];
	
	NSSize size = [[self controlView] bounds].size;
	size.width = [[self stringValue] sizeWithAttributes:attrs].width + size.height;
	
	return size;
}

- (void)_drawTitleWithFrame:(NSRect)titleFrame
{
	//NSLog(@"%@", [[self controlView] font]);
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[[self controlView] font],
		NSFontAttributeName,
		[self textColor],
		NSForegroundColorAttributeName,
		nil];
	
	NSSize textSize = [[self stringValue] sizeWithAttributes:attrs];

	//NSLog(@"Rect: %f, %f", titleFrame.size.width, titleFrame.size.height);
	//NSLog(@"Size: %f, %f", textSize.width, textSize.height);
	
	NSPoint atPoint = NSMakePoint(titleFrame.origin.x + (titleFrame.size.width - textSize.width) / 2.0,
								  titleFrame.origin.y + (titleFrame.size.height - textSize.height) / 2.0);

	//NSLog(@"Point: %f, %f", atPoint.x, atPoint.y);

	[[self stringValue] drawAtPoint:atPoint
					 withAttributes:attrs];
		
}

- (void)setStringValue:(NSString *)str
{
	[str retain];
	[_title release];
	_title = str;

	[super setStringValue:str];
}

- (void)editWithFrame:(NSRect)frame inView:(NSView *)controlView
			   editor:(NSText *)editor
			 delegate:(id)delegate
				event:(NSEvent *)theEvent
{
	if ([controlView isEditable])
	{
		[super editWithFrame:[self _frameForTitle:frame]
					  inView:controlView
					  editor:editor
					delegate:delegate
					   event:theEvent];
	}
}

- (void)selectWithFrame:(NSRect)frame inView:(NSView *)controlView
				 editor:(NSText *)editor
			   delegate:(id)delegate
				  start:(int)selStart
				 length:(int)selLength
{
	if ([controlView isSelectable])
	{
		[super selectWithFrame:[self _frameForTitle:frame]
						inView:controlView
						editor:editor
					  delegate:delegate
						 start:selStart
						length:selLength];
	}
}

- (void)endEditing:(NSText *)textObj
{
    [_title release];
    _title = [[textObj string] retain];
	
	[super endEditing:textObj];
}

@end