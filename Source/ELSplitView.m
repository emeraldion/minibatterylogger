//
//  ELSplitView.m
//  MiniBatteryLogger
//
//  Created by delphine on 08-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "ELSplitView.h"

@implementation ELSplitView

- (void)awakeFromNib
{
	if (![self isVertical])
	{
		grip = [[NSImage imageNamed:@"splitview-grip"] retain];
		[grip setFlipped:YES];
		bar = [[NSImage imageNamed:@"splitview-bar"] retain];
		[bar setFlipped:YES];
	}
}

- (void)dealloc
{
	[grip release];
	[bar release];
	[super dealloc];
}

- (float)dividerThickness
{
	return [self isVertical] ? 1.0 : 9.0;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	//NSLog(@"%f, %f, %f, %f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
	if ([self isVertical])
	{
		/*
		NSRect myFrame = [self frame];
		NSRect leftFrame = [[[self subviews] objectAtIndex:0] frame];
		
		NSRect dividerFrame = NSMakeRect(leftFrame.origin.x + leftFrame.size.width,
										 myFrame.origin.y,
										 [self dividerThickness],
										 myFrame.size.height);
		 */
		[NSGraphicsContext saveGraphicsState]; {
			[[NSColor controlShadowColor] set];
			//NSRectFill(dividerFrame);
			NSRectFill(aRect);
		} [NSGraphicsContext restoreGraphicsState];
	}
	else
	{
		[[NSGraphicsContext currentContext] saveGraphicsState]; {
			// Draw background
			[[NSColor controlShadowColor] set];
			[NSBezierPath fillRect:aRect];
		} [[NSGraphicsContext currentContext] restoreGraphicsState];

		// Draw bar and grip onto the canvas
		NSRect canvasRect = NSMakeRect(0,
									   0,
									   aRect.size.width,
									   aRect.size.height - 1);
		NSRect targetRect = NSMakeRect(aRect.origin.x,
									   aRect.origin.y + 1,
									   aRect.size.width,
									   aRect.size.height - 1);
		
		// Create a canvas
		NSImage *canvas = [[[NSImage alloc] initWithSize:canvasRect.size] autorelease];
		
		NSRect gripRect = canvasRect;
		gripRect.origin.x = (NSMidX(canvasRect) - ([grip size].width/2));
		[canvas lockFocus];
		[bar setSize:canvasRect.size];
		[bar drawInRect:canvasRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
		[grip drawInRect:gripRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
		[canvas unlockFocus];
		
		// Draw canvas to divider bar
		[self lockFocus];
		[canvas drawInRect:targetRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
		[self unlockFocus];
	}	
}
/*
- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent clickCount] == 2)
	{
		NSLog(@"[%@] I'm being double clicked!", self);
		if (![self isVertical])
		{
			NSView *topView = [[self subviews] objectAtIndex:0];
			NSView *bottomView = [[self subviews] objectAtIndex:1];
			
			NSRect topFrame = [topView frame];
			NSRect bottomFrame = [bottomView frame];
			
			bottomFrame.origin.y -= topFrame.size.height;
			
			bottomFrame.size.height += topFrame.size.height;
			topFrame.size.height = 0;
			
			[topView setFrame:topFrame];
			[bottomView setFrame:bottomFrame];
			
			[self drawDividerInRect:NSMakeRect(0, 0, topFrame.size.width, [self dividerThickness])];
		}
	}
}
*/
@end
