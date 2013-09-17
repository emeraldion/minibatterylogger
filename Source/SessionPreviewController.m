//
//  SessionPreviewController.m
//  MiniBatteryLogger
//
//  Created by delphine on 11-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "SessionPreviewController.h"

@implementation SessionPreviewWindow

- (id)initWithContentRect:(NSRect)contentRect
				styleMask:(unsigned int)style
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)flag
{
	
	opacity = 1.0;
	NSRect cRect = NSMakeRect(contentRect.origin.x,
							  contentRect.origin.y,
							  200.0,
							  150.0);
	if (self = [super initWithContentRect:cRect
								styleMask:NSBorderlessWindowMask
								  backing:bufferingType
									defer:flag])
	{
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setHasShadow:NO];
		[self setLevel:NSFloatingWindowLevel];
		[self setAcceptsMouseMovedEvents:YES];
	}
	return self;
}

// Per default, finestre senza bordo non possono diventare key window o main window
- (BOOL)canBecomeKeyWindow
{
	//NSLog(@"canBecomeKeyWindow");
	return NO;
}

- (BOOL)canBecomeMainWindow
{
	//NSLog(@"canBecomeMainWindow");
	return NO;
}

- (void)setOpacity:(float)opac
{
	//NSLog(@"setOpacity:%f", opac);
	opacity = opac;
	[self setAlphaValue:opacity];
}

- (float)opacity
{
	return opacity;
}

- (IBAction)fadeOut:(id)sender
{
	if (opacity <= 0)
	{
		//[self orderOut:sender];
	}
	else
	{
		opacity -= 0.15;
		[self setAlphaValue:opacity];
		[self performSelector:@selector(fadeOut:)
				   withObject:nil
				   afterDelay:0.1];
	}
}

@end

@implementation SessionPreviewController

- (id)init
{
	if (self = [super initWithWindowNibName:@"SessionPreview"])
	{
		dismissing = NO;
	}
	return self;
}

- (void)setSession:(MonitoringSession *)session
{
	// Bind the chart view events to the current selection of sessionsController's events
	[chartView bind:@"events"
		   toObject:session
		withKeyPath:@"events"
			options:nil];	
}

- (void)setSessionsController:(NSArrayController *)controller
{
	sessionsController = controller;

	// Bind the chart view events to the current selection of sessionsController's events
	[chartView bind:@"events"
		   toObject:sessionsController
		withKeyPath:@"selection.events"
			options:nil];	
}

- (void)dealloc
{
	[super dealloc];
}

- (IBAction)dismissWindow:(id)sender
{
	//NSLog(@"dismissWindow:");
	if (dismissing)
		return;
	//NSLog(@"dismissing...");
	dismissing = YES;
	[[self window] performSelector:@selector(fadeOut:)
						withObject:nil
						afterDelay:1.0];	
}

- (IBAction)showWindow:(id)sender
{
	//NSLog(@"showWindow:");
	[NSObject cancelPreviousPerformRequestsWithTarget:[self window]
											 selector:@selector(fadeOut:)
											   object:nil];
	dismissing = NO;
	[(SessionPreviewWindow *)[self window] setOpacity:1.0];
	[super showWindow:sender];
}

- (void)windowDidLoad
{
	// Bind the chart view events to the current selection of sessionsController's events
	[chartView bind:@"events"
		   toObject:sessionsController
		withKeyPath:@"selection.events"
			options:nil];	
}

@end


@implementation SessionPreviewContentView

+ (void)initialize
{
}

- (id)initWithFrame:(NSRect)bounds
{
	//NSLog(@"initWithFrame:%@", NSStringFromRect(bounds));
	if (self = [super initWithFrame:bounds])
	{
		[[self window] setAcceptsMouseMovedEvents:YES];
	}
	return self;	
}

- (void)dealloc
{
	[super dealloc];
}

- (void)drawRect:(NSRect)bounds
{
	//NSLog(@"drawRect:%@", NSStringFromRect(bounds));
	[[NSColor clearColor] set];
	NSRectFill(bounds);
	[super drawRect:bounds];
}

- (BOOL) isFlipped
{
	//NSLog(@"isFlipped");
    return NO;
}

- (BOOL) acceptsFirstResponder
{
	//NSLog(@"acceptsFirstResponder");
    return YES;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	//NSLog(@"mouseDragged:%@", theEvent);
	
	NSPoint newPoint = [NSEvent mouseLocation];
	NSRect windowFrame = [[self window] frame];
	NSSize szMovement;
	
	if (!positionInitialized)
	{
		mostRecentPoint = newPoint;
		theScreen = [[NSScreen mainScreen] frame];
		theScreen.origin.y -= 22;
		positionInitialized = YES;
	}
	
	szMovement.width = (int)newPoint.x - mostRecentPoint.x;
	szMovement.height = (int)newPoint.y - mostRecentPoint.y;
	mostRecentPoint = newPoint;
	
	windowFrame.origin = NSMakePoint(windowFrame.origin.x + szMovement.width,
									 windowFrame.origin.y + szMovement.height);
	
	if (NSMaxY(windowFrame) > NSMaxY(theScreen))
	{
		windowFrame.origin.y -= NSMaxY(windowFrame) - NSMaxY(theScreen);
	}
	
	[[self window] setFrame:windowFrame display:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent clickCount] == 2)
	{

	}
	else
	{
		//NSLog(@"mouseDown:%@", theEvent);
		mostRecentPoint = [NSEvent mouseLocation];
	}
	//[super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	//NSLog(@"mouseUp:%@", theEvent);
    positionInitialized = NO;
	//[super mouseUp:theEvent];
}

@end