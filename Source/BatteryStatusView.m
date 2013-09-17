//
//  BatteryStatusView.m
//  MiniBatteryLogger
//
//  Created by delphine on 5-05-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatteryStatusView.h"
#import "NSImage+MBLUtils.h"
#import "NSBezierPath+MBLUtils.h"

NSDictionary *_BatteryStatusViewFontAttrs;

@interface BatteryStatusView (Private)

- (void)startObservingBattery:(Battery *)batt;
- (void)stopObservingBattery:(Battery *)batt;

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context;
- (void)copyBatteryToPasteboard:(NSPasteboard *)pb;

@end

@implementation BatteryStatusView

+ (void)initialize
{
	_BatteryStatusViewFontAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSFont fontWithName:@"Lucida Grande"
						size:24.0],
		NSFontAttributeName,
		[NSColor whiteColor],
		NSForegroundColorAttributeName,
		nil];
	// Expose binding
	[self exposeBinding:@"battery"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc
{
	[_battery release];
	[super dealloc];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)drawRect:(NSRect)rect {
	
	int charge = [_battery charge];
	
	NSRect bounds = [self bounds];
	
	int bz_x = 5;
	int bz_y = 10;
	int off_x = (bounds.size.width - 122) / 2;
	
	int c_x = bounds.size.width / 2 + bounds.origin.x;
	int c_y = bounds.size.height / 2 + bounds.origin.y;
	
    // Drawing code here.
	[NSGraphicsContext saveGraphicsState]; {
		// Fill background
		[[NSColor colorWithDeviceWhite:0.4
								 alpha:1.0] set];
		NSRectFill(bounds);
		
		if ([_battery isInstalled])
		{
			
			// Draw charge bar
			NSRect chargebarRect;

			chargebarRect.origin.x = bz_x + off_x + 6.0;
			chargebarRect.origin.y = bz_y + 6.0;
			
			chargebarRect.size.width = (int)(charge * 95 / 100);
			chargebarRect.size.height = 33;

			NSBezierPath *chargebar = [NSBezierPath bezierPathWithRoundedRect:chargebarRect
																 cornerRadius:3.0];
			[[NSColor colorForCharge:charge] set];
			[chargebar fill];
			
			// Draw charge
			NSString *chargeStr = [NSString stringWithFormat:@"%d%%", charge];
			NSSize chargeStrSize = [chargeStr sizeWithAttributes:_BatteryStatusViewFontAttrs];
			[chargeStr drawAtPoint:NSMakePoint(c_x - 2.5 - 0.5 * chargeStrSize.width,
											   c_y - 0.5 * chargeStrSize.height)
					withAttributes:_BatteryStatusViewFontAttrs];
		}

		// Draw white bezel
		NSImage *bezel = [NSImage imageNamed:@"batterystatus-bezel"];
		NSRect bezelRect;
		bezelRect.origin = NSZeroPoint;
		bezelRect.size = [bezel size];
		[bezel drawAtPoint:NSMakePoint(bz_x + off_x,
									   bz_y)
				  fromRect:bezelRect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
		
		if (_battery != nil &&
			![_battery isInstalled])
		{
			// Draw a red bar
			NSBezierPath *redline = [NSBezierPath bezierPath];
			[redline moveToPoint:NSMakePoint(32.0 + off_x - bz_x, 7.0)];
			[redline lineToPoint:NSMakePoint(96.0 + off_x - bz_x, 56.0)];
			[redline setLineWidth:6.0];
			[redline setLineCapStyle:NSSquareLineCapStyle];
			[[NSColor redColor] set];
			[redline stroke];
		}		
		
	} [NSGraphicsContext restoreGraphicsState];
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding
	   toObject:observable
	withKeyPath:keyPath
		options:options];
	// Request an immediate redraw
	[self setNeedsDisplay:YES];
}

#pragma mark === Actions ===

- (IBAction)copy:(id)sender
{
	[self copyBatteryToPasteboard:[NSPasteboard generalPasteboard]];
}

#pragma mark === Setters / Getters ===

- (void)setBattery:(Battery *)batt
{
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

@end


@implementation BatteryStatusView (Private)

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
	[self setNeedsDisplay:YES];
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
	// Request a redraw on observed property change
	[self setNeedsDisplay:YES];
}

- (void)copyBatteryToPasteboard:(NSPasteboard *)pb
{
	// Put the battery description to the pasteboard
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pb setString:[_battery description] forType:NSStringPboardType];	
}

@end

