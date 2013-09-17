//
//  DesktopBatteryController.m
//  MiniBatteryLogger
//
//  Created by delphine on 18-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "DesktopBatteryController.h"
#import "NSImage+MBLUtils.h"

@class AppController;

@implementation DesktopBatteryController

- (id)initWithController:(NSObjectController *)controller
{
	if (self = [super initWithWindowNibName:@"DesktopBattery"])
	{
		[self setBatteryController:controller];
	}
	return self;
}

- (void)dealloc
{
	[self setBatteryController:nil];
	[super dealloc];
}

- (void)setBatteryController:(NSObjectController *)controller
{
	[controller retain];
	[_controller release];
	_controller = controller;
}

- (IBAction)showWindow:(id)sender
{
	// Do not request key status
	[[self window] orderFront:sender];
}

- (void)windowDidLoad
{
	//NSLog(@"windowDidLoad");
	
	//[captionText setCell:[[[ShadowedTextFieldCell alloc] initTextCell:[captionText stringValue]] autorelease]];
	
	[batteryImage bind:@"battery"
			  toObject:_controller
		   withKeyPath:@"selection.self"
			   options:nil];
	
}

@end

@implementation DesktopBatteryWindow

- (id)initWithContentRect:(NSRect)contentRect
				styleMask:(unsigned int)style
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)flag
{

	
	NSRect cRect = NSMakeRect(contentRect.origin.x,
							  contentRect.origin.y,
							  128.0,
							  128.0);
	if (self = [super initWithContentRect:cRect
								styleMask:NSBorderlessWindowMask
								  backing:bufferingType
									defer:flag])
	{
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setHasShadow:NO];
		[self setLevel:kCGDesktopIconWindowLevel];
		[self setAcceptsMouseMovedEvents:YES];
	}
	return self;
}

// Per default, finestre senza bordo non possono diventare key window o main window
- (BOOL)canBecomeKeyWindow
{
	//NSLog(@"canBecomeKeyWindow");
	return YES;
}

- (BOOL)canBecomeMainWindow
{
	//NSLog(@"canBecomeMainWindow");
	return YES;
}

@end

@implementation DesktopBatteryContentView

+ (void)initialize
{
	[self exposeBinding:@"battery"];
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
	[_battery release];
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

/*
- (BOOL)isOpaque
{
	return NO;
}

*/
- (BOOL) acceptsFirstResponder
{
	//NSLog(@"acceptsFirstResponder");
    return YES;
}

- (void)setBattery:(Battery *)batt
{
//	NSLog(@"setBattery:%@", batt);
	[self stopObservingBattery:_battery];
	
	[batt retain];
	[_battery release];
	_battery = batt;
	
	[self startObservingBattery:_battery];
}

- (Battery *)battery
{
	return _battery;
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
		[[AppController sharedController] showWindow:nil];
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

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	//NSLog(@"bind:toObject:withKeyPath:options:%@", observable);
	[super bind:binding
	   toObject:observable
	withKeyPath:keyPath
		options:options];
	// Update now
	[self setImage:[NSImage dockIconForBattery:[observable content]]];
}

- (void)startObservingBattery:(Battery *)batt
{
	[batt addObserver:self
		   forKeyPath:@"charge"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"plugged"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"charging"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	// Update now
	[self setImage:[NSImage dockIconForBattery:batt]];
}

- (void)stopObservingBattery:(Battery *)batt
{
	[batt removeObserver:self
			  forKeyPath:@"charge"];
	[batt removeObserver:self
			  forKeyPath:@"plugged"];
	[batt removeObserver:self
			  forKeyPath:@"charging"];
}

/**
 *	This method will be called when one of the observed keypaths
 *	of the battery is changed
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	//NSLog(@"observeValueForKeyPath:ofObject:change:context:%@", keyPath);
	// Request a redraw on observed property change
	[self setImage:[NSImage dockIconForBattery:_battery]];
}

@end

@implementation ShadowedTextFieldCell

- (id)initTextCell:(NSString *)str
{
	if (self = [super initTextCell:str])
	{
		[self setTextColor:[NSColor highlightColor]];
		[self setAlignment:NSCenterTextAlignment];
		[self setFont:[NSFont fontWithName:@"Lucida Grande Bold"
									  size:14.0]];
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow setShadowColor:[NSColor blackColor]];
	[shadow setShadowBlurRadius:2.0];

	[shadow set];
	
	[super drawWithFrame:cellFrame inView:view];
	
	[shadow release];
}

@end