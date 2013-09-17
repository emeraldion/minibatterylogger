//
//  ChartViewPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "ChartViewPreferencePane.h"


@implementation ChartViewPreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super initWithIdentifier:theIdentifier
								   label:theLabel
								category:theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"chartprefs"]];
	}
	return self;
}

- (NSColor *)colorForKey:(NSString *)key
{
	NSUserDefaults *defaults;
	NSData *colorAsData;
	
	defaults = [NSUserDefaults standardUserDefaults];
	colorAsData = [defaults objectForKey:key];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

#pragma mark === Accessors ===

- (BOOL)shouldDrawBubbles
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLChartShouldDrawBubblesKey] boolValue];
}

- (BOOL)drawAmperageGraph
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLChartDrawAmperageGraphKey] boolValue];
}

- (BOOL)drawVoltageGraph
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLChartDrawVoltageGraphKey] boolValue];
}

- (NSColor *)backgroundColor
{
	return [self colorForKey:MBLChartBackgroundColorKey];
}

- (NSColor *)gridColor
{
	return [self colorForKey:MBLChartGridColorKey];
}

- (NSColor *)pluggedColor
{
	return [self colorForKey:MBLChartPluggedColorKey];
}

- (NSColor *)unpluggedColor
{
	return [self colorForKey:MBLChartUnpluggedColorKey];
}

- (NSColor *)amperageColor
{
	return [self colorForKey:MBLChartAmperageColorKey];
}

- (NSColor *)voltageColor
{
	return [self colorForKey:MBLChartVoltageColorKey];
}

- (NSColor *)chargingColor
{
	return [self colorForKey:MBLChartChargingColorKey];
}

- (void)changeColor:(id)sender forKey:(NSString *)key notification:(NSString *)notif
{
	NSColor *color = [sender color];
	NSData *colorAsData;
	colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults] setObject:colorAsData 
											  forKey:key];
	[[NSNotificationCenter defaultCenter] postNotificationName:notif
														object:self];
}

- (IBAction)changeBackgroundColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartBackgroundColorKey
		 notification:MBLChartBackgroundColorChangedNotification];
}

- (IBAction)changeGridColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartGridColorKey
		 notification:MBLChartGridColorChangedNotification];
}

- (IBAction)changePluggedColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartPluggedColorKey
		 notification:MBLChartPluggedColorChangedNotification];
}

- (IBAction)changeUnpluggedColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartUnpluggedColorKey
		 notification:MBLChartUnpluggedColorChangedNotification];
}

- (IBAction)changeAmperageColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartAmperageColorKey
		 notification:MBLChartAmperageColorChangedNotification];
}

- (IBAction)changeVoltageColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartVoltageColorKey
		 notification:MBLChartVoltageColorChangedNotification];
}

- (IBAction)changeChargingColor:(id)sender
{
	[self changeColor:sender
			   forKey:MBLChartChargingColorKey
		 notification:MBLChartChargingColorChangedNotification];
}

- (IBAction)changeDrawBubbles:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLChartShouldDrawBubblesKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLChartShouldDrawBubblesChangedNotification
														object:self];
}

- (IBAction)changeDrawAmperageGraph:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLChartDrawAmperageGraphKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLChartDrawAmperageGraphChangedNotification
														object:self];
}

- (IBAction)changeDrawVoltageGraph:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLChartDrawVoltageGraphKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLChartDrawVoltageGraphChangedNotification
														object:self];
}

- (void)mainViewDidLoad
{
	[backgroundColorWell setColor:[self backgroundColor]];
	[gridColorWell setColor:[self gridColor]];
	[pluggedColorWell setColor:[self pluggedColor]];
	[unpluggedColorWell setColor:[self unpluggedColor]];
	[chargingColorWell setColor:[self chargingColor]];
	[amperageColorWell setColor:[self amperageColor]];
	[voltageColorWell setColor:[self voltageColor]];

	[drawBubbles setState:[self shouldDrawBubbles]];
	[drawAmperageGraph setState:[self drawAmperageGraph]];
	[drawVoltageGraph setState:[self drawVoltageGraph]];
}

@end
