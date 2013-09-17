//
//  NSImage+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "NSImage+MBLUtils.h"
#import "NSBezierPath+MBLUtils.h"

@implementation NSImage (MBLUtils)

+ (NSImage *)imageForBatteryEvent:(BatteryEvent *)event
{
	return [NSImage imageForCharge:[event charge]
						   plugged:[event isPlugged]
						  charging:[event isCharging]];
}

+ (NSImage *)imageForBattery:(Battery *)battery
{
	return [NSImage imageForCharge:[battery charge]
						   plugged:[battery isPlugged]
						  charging:[battery isCharging]];
}

+ (NSImage *)imageForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging
{
	if (charging)
	{
		return [NSImage imageNamed:@"icon_charging"];
	}
	else if (plugged)
	{
		return [NSImage imageNamed:@"icon_plugged"];
	}
	else
	{
		int index = round(4.0 * charge / 100);
		return [NSImage imageNamed:[NSString stringWithFormat:@"icon_%d", index]];
	}
}

+ (NSImage *)dockIconForBattery:(Battery *)battery
{
	return [self dockIconForCharge:[battery charge]
						   plugged:[battery isPlugged]
						  charging:[battery isCharging]
						 installed:[battery isInstalled]];
}

+ (NSImage *)dockIconForBatteryEvent:(BatteryEvent *)event
{
	return [self dockIconForCharge:[event charge]
						   plugged:[event isPlugged]
						  charging:[event isCharging]
						 installed:[event isInstalled]];
}

+ (NSImage *)dockIconForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging
{
	return [self dockIconForCharge:charge
						   plugged:plugged
						  charging:charging
						 installed:YES];
}

+ (NSImage *)dockIconForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging installed:(BOOL)installed
{
	NSImage *icon = [[NSImage alloc] initWithSize:NSMakeSize(128,128)];
	
	[icon lockFocus];
	{
		NSRect iconRect = NSMakeRect(0, 0, 128, 128);

		NSColor *chargeColor, *backColor, *ringColor;
		
		if (installed)
		{
			chargeColor = [NSColor colorForCharge:charge];
		}
		else
		{
			chargeColor = [NSColor colorWithDeviceHue:215.0/360.0 // blue
										   saturation:1.0
										   brightness:0.72
												alpha:1.0];
		}
		backColor = [NSColor colorWithDeviceHue:[chargeColor hueComponent]
									 saturation:[chargeColor saturationComponent]
									 brightness:[chargeColor brightnessComponent]
										  alpha:[chargeColor alphaComponent] * 0.9];
		ringColor = [NSColor colorWithDeviceHue:[chargeColor hueComponent]
									 saturation:[chargeColor saturationComponent] * 0.8
									 brightness:[chargeColor brightnessComponent] * 0.6
										  alpha:[chargeColor alphaComponent]];
		
		NSRect outerRect = NSMakeRect(22.0,
									  10.0,
									  84.0,
									  116.0);
		
		// Fill the colored rounded rect, then stroke the dark border
		NSBezierPath *back = [NSBezierPath bezierPathWithRoundedRect:outerRect
														cornerRadius:18.0];
		[backColor set];
		[back fill];

		[ringColor set];
		[back setLineWidth:3.0];
		[back stroke];

		if (installed)
		{
			// Draw charge bar
			NSRect chargebarRect = NSMakeRect(43.0,
											  26.0,
											  42.0,
											  8.0 + (charge * 71.0 / 100));
			
			NSBezierPath *chargebar = [NSBezierPath bezierPathWithRoundedRect:chargebarRect
																 cornerRadius:4.0];
			[[NSColor colorWithDeviceWhite:1.0
									 alpha:0.5] set];
			[chargebar fill];
		
			if (charging)
			{
				// Draw the bolt sign
				[[NSImage imageNamed:@"charge-icon"] drawInRect:iconRect
													   fromRect:iconRect
													  operation:NSCompositeSourceOver
													   fraction:1.0];
			}
			else if (plugged)
			{
				// Draw the plug sign
				[[NSImage imageNamed:@"plug-icon"] drawInRect:iconRect
													 fromRect:iconRect
													operation:NSCompositeSourceOver
													 fraction:1.0];
			}
		}		

		// Finally apply glossy overlay
		[[NSImage imageNamed:@"battery-icon"] drawInRect:iconRect
												fromRect:iconRect
											   operation:NSCompositeSourceOver
												fraction:1.0];
		
		if (!installed)
		{
			// Draw a red bar
			NSBezierPath *redline = [NSBezierPath bezierPath];
			[redline moveToPoint:NSMakePoint(35.0, 37.0)];
			[redline lineToPoint:NSMakePoint(93.0, 95.0)];
			[redline setLineWidth:6.0];
			[redline setLineCapStyle:NSSquareLineCapStyle];
			[[NSColor redColor] set];
			[redline stroke];
		}
			
	}
	[icon unlockFocus];
	
	return [icon autorelease];
}

+ (NSImage *)statusImageForBattery:(Battery *)batt highlighted:(BOOL)highlight
{
	return [self statusImageForCharge:[batt charge]
							  plugged:[batt isPlugged]
							 charging:[batt isCharging]
							installed:[batt isInstalled]
						  highlighted:highlight];
}

+ (NSImage *)statusImageForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging highlighted:(BOOL)highlight
{
	return [self statusImageForCharge:charge
							  plugged:plugged
							 charging:charging
							installed:YES
						  highlighted:highlight];
}

+ (NSImage *)statusImageForCharge:(int)charge plugged:(BOOL)plugged charging:(BOOL)charging installed:(BOOL)installed highlighted:(BOOL)highlight;
{
	// First off, choose the appropriate battery bezel graphics
	NSImage *bezel = highlight ?
	[NSImage imageNamed:@"bezel_white"] :
	(plugged ? [NSImage imageNamed:@"bezel_clear"] : [NSImage imageNamed:@"bezel"]);
	
	NSSize sSize = [bezel size];
	
	// Create a canvas to draw everything on
	NSImage *canvas = [[NSImage alloc] initWithSize:sSize];	
	NSImage *buf;
	
	// Lock focus on the canvas
	[canvas lockFocus]; {
		
		// Draw the bezel
		[bezel drawInRect:NSMakeRect(0, 0, sSize.width, sSize.height)
				 fromRect:NSMakeRect(0, 0, sSize.width, sSize.height)
				operation:NSCompositeSourceOver
				 fraction:1.0];
		
		if (installed)
		{

			// Create a colored bar for the amount of charge
			NSImage *chargeImage = [[NSImage alloc] initWithSize:sSize];
			[chargeImage lockFocus];
			{
				[[NSColor colorForCharge:charge] set];
				[[NSGraphicsContext currentContext] saveGraphicsState]; {
					[NSBezierPath clipRect:NSMakeRect(6.0, 2.0, 6.0, 2.0 + (charge / 10.0))];
					[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(6.0, 2.0, 6.0, 12.0)
												cornerRadius:2.0] fill];
				} [[NSGraphicsContext currentContext] restoreGraphicsState];
			}
			[chargeImage unlockFocus];

			// Draw in Over or XOR mode depending on the highlight mode
			[chargeImage drawInRect:NSMakeRect(0, 0, sSize.width, sSize.height)
						   fromRect:NSMakeRect(0, 0, sSize.width, sSize.height)
						  operation:highlight ? NSCompositeXOR : NSCompositeSourceOver
						   fraction:1.0];
			
			[chargeImage release];
		
			if (charging)
			{
				// Add the bolt sign
				buf = highlight ? [NSImage imageNamed:@"charging-white"] : [NSImage imageNamed:@"charging"];
				[buf drawInRect:NSMakeRect(0, 0, sSize.width, sSize.height)
					   fromRect:NSMakeRect(0, 0, sSize.width, sSize.height)
					  operation:NSCompositeSourceOver //NSCompositeSourceAtop
					   fraction:1.0];
			}
			else if (plugged)
			{
				// Add the plug sign
				buf = highlight ? [NSImage imageNamed:@"plugged-white"] : [NSImage imageNamed:@"plugged"];
				[buf drawInRect:NSMakeRect(0, 0, sSize.width, sSize.height)
					   fromRect:NSMakeRect(0, 0, sSize.width, sSize.height)
					  operation:NSCompositeSourceOver //NSCompositeSourceAtop
					   fraction:1.0];
			}
		}
		else
		{
			[[NSGraphicsContext currentContext] saveGraphicsState]; {
				// Draw a red bar
				NSBezierPath *redline = [NSBezierPath bezierPath];
				[redline moveToPoint:NSMakePoint(4.0, 5.0)];
				[redline lineToPoint:NSMakePoint(13.0, 11.0)];
				[redline setLineWidth:2.0];
				[redline setLineCapStyle:NSSquareLineCapStyle];
				[highlight ? [NSColor cyanColor] : [NSColor redColor] set];
				[NSBezierPath clipRect:NSMakeRect(4.0, 1.0, 10.0, 16.0)];
				[redline stroke];
			} [[NSGraphicsContext currentContext] restoreGraphicsState];
		}
		
	} [canvas unlockFocus];
	
	return [canvas autorelease];
}

@end

@implementation NSColor (MBLUtils)

+ (NSColor *)colorForCharge:(int)charge
{
	return [NSColor colorWithDeviceHue:(120 * charge / (100 * 360.0))
							saturation:1.0
							brightness:(0.8 + 0.1 * (100 - charge) * charge / 2500.0)
								 alpha:1.0];
}

@end