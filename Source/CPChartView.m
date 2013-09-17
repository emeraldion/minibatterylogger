//
//  CPChartView.m
//  MiniBatteryLogger
//
//  Created by delphine on 26-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "CPChartView.h"

#define HPAD 28.0
#define VPAD 28.0

#define GRAPH_LINE_WIDTH 3.0

// Default 1 hour
#define HSCALE_DEFAULT 3600.0

// Max 24 hours
#define HSCALE_MAX 230400.0

// Min 5 minutes
#define HSCALE_MIN 900.0

// Jump is 5 minutes
#define H_OFFSET 900.0

// Default is 2 A
#define MAX_AMPERAGE_DEFAULT 2000

// Default is 16 V
#define MAX_VOLTAGE_DEFAULT 16000

#define VSCALE 100.0

#define GRID_HSPACING 6
#define GRID_VSPACING 10

/* Color keys */
NSString *MBLChartBackgroundColorKey = @"Chart Background Color";
NSString *MBLChartChargingColorKey = @"Chart Charging Color";
NSString *MBLChartPluggedColorKey = @"Chart Plugged Color";
NSString *MBLChartUnpluggedColorKey = @"Chart Unplugged Color";
NSString *MBLChartGridColorKey = @"Chart Grid Color";
NSString *MBLChartAmperageColorKey = @"Chart Amperage Color";
NSString *MBLChartVoltageColorKey = @"Chart Voltage Color";

/* Drawable objects keys */
NSString *MBLChartShouldDrawBubblesKey = @"Draw Bubbles";
NSString *MBLChartShouldDrawSleepKey = @"Draw Sleep";
NSString *MBLChartDrawAmperageGraphKey = @"Draw Amperage Graph";
NSString *MBLChartDrawVoltageGraphKey = @"Draw Voltage Graph";

/* Notifications */
NSString *MBLChartBackgroundColorChangedNotification = @"Chart Background Color Changed";
NSString *MBLChartChargingColorChangedNotification = @"Chart Charging Color Changed";
NSString *MBLChartPluggedColorChangedNotification = @"Chart Plugged Color Changed";
NSString *MBLChartUnpluggedColorChangedNotification = @"Chart Unplugged Color Changed";
NSString *MBLChartGridColorChangedNotification = @"Chart Grid Color Changed";
NSString *MBLChartAmperageColorChangedNotification = @"Chart Amperage Color Changed";
NSString *MBLChartVoltageColorChangedNotification = @"Chart Voltage Color Changed";

NSString *MBLChartShouldDrawBubblesChangedNotification = @"Draw Bubbles Changed";
NSString *MBLChartDrawAmperageGraphChangedNotification = @"Draw Amperage Graph Changed";
NSString *MBLChartDrawVoltageGraphChangedNotification = @"Draw Voltage Graph Changed";

static NSString *MBLFancyScaleColorsKey = @"MBLFancyScaleColors";

@class PreferenceController;

@interface CPChartView (Private)

- (void) handleInspectorScreenChange:(NSNotification *)notif;
- (void) drawImage:(NSImage *)img atPoint:(NSPoint)pt;
- (void) handlePropertyChange:(NSNotification *)note;
- (void) updateChartProperties;
- (void) selectEventMatchingTimeInterval:(NSTimeInterval)interval;
- (void) selectEventAtIndex:(int)index;
- (NSPoint) pointFor:(int)qty date:(NSDate *)date offset:(NSDate *)startDate;
- (void) trackPoint:(NSPoint)pt;
- (void) copyChartToPasteboard:(NSPasteboard *)pb;
- (NSImage *)drawToImage;

@end

@implementation CPChartView

+ (void) initialize
{
	/* Expose binding */
	[self exposeBinding:@"events"];
	
	/* Registering Standard User Defaults */
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:MBLChartUnpluggedColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor colorWithDeviceRed:0.0
																							   green:204/255.0
																								blue:51/255.0
																							   alpha:1.0]] forKey:MBLChartPluggedColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor orangeColor]] forKey:MBLChartChargingColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor lightGrayColor]] forKey:MBLChartGridColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MBLChartBackgroundColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor magentaColor]] forKey:MBLChartAmperageColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]] forKey:MBLChartVoltageColorKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MBLChartShouldDrawBubblesKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MBLChartDrawAmperageGraphKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MBLChartDrawVoltageGraphKey];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:defaultValues];
	[defaults synchronize];	
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		hScale = HSCALE_DEFAULT;
		hOffset = 0;
		maxAmperageValue = MAX_AMPERAGE_DEFAULT;
		maxVoltageValue = MAX_VOLTAGE_DEFAULT;
		selectedEventIndex = MBLNoSelectedEvent;
		selectionTracksLastPoint = NO;
		drawScales = YES;
		hPad = HPAD;
		vPad = VPAD;
		graphLineWidth = GRAPH_LINE_WIDTH;
		
		//events = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartGridColorChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartBackgroundColorChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartUnpluggedColorChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartPluggedColorChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartChargingColorChangedNotification
												   object:nil];		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartAmperageColorChangedNotification
												   object:nil];		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartVoltageColorChangedNotification
												   object:nil];		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartShouldDrawBubblesChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartDrawAmperageGraphChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartDrawVoltageGraphChangedNotification
												   object:nil];
		/*
		// Window observing
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleInspectorScreenChange:)
													 name:NSWindowDidChangeScreenNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleInspectorScreenChange:)
													 name:NSWindowDidBecomeMainNotification
												   object:nil];
*/
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[self setPluggedColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartPluggedColorKey]]];
		[self setUnpluggedColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartUnpluggedColorKey]]];
		[self setChargingColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartChargingColorKey]]];
		[self setGridColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartGridColorKey]]];
		[self setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartBackgroundColorKey]]];
		[self setAmperageColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartAmperageColorKey]]];
		[self setVoltageColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartVoltageColorKey]]];
		[self setShouldDrawBubbles:[[defaults objectForKey:MBLChartShouldDrawBubblesKey] boolValue]];
		[self setDrawAmperageGraph:[[defaults objectForKey:MBLChartDrawAmperageGraphKey] boolValue]];
		[self setDrawVoltageGraph:[[defaults objectForKey:MBLChartDrawVoltageGraphKey] boolValue]];
		
		useFancyScaleColors = [[defaults objectForKey:MBLFancyScaleColorsKey] boolValue];
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//[events release];
	[pluggedColor release];
	[unpluggedColor release];
	[chargingColor release];
	[gridColor release];
	[backgroundColor release];
	[amperageColor release];
	[voltageColor release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
	int i;
	NSImage *bubbleCanvas;
	NSSize gridSize = NSMakeSize(rect.size.width - 2 * hPad,
								 rect.size.height - 2 * vPad);
	gridRect = NSMakeRect(hPad - 0.5 * graphLineWidth,
						  vPad - 0.5 * graphLineWidth,
						  gridSize.width + graphLineWidth,
						  gridSize.height + graphLineWidth);
	
	if (shouldDrawBubbles)
	{
		bubbleCanvas = [[NSImage alloc] initWithSize:rect.size];
	}
	
	// Scale the graph to completely fill the view rect
	NSAffineTransform *scaling = [NSAffineTransform transform];
	
	[scaling translateXBy:gridSize.width * (1 + hOffset) + hPad
					  yBy:vPad];
	[scaling scaleXBy:(gridSize.width / hScale)
				  yBy:(gridSize.height / VSCALE)];
	
	// Fill background with backgroundColor
    [backgroundColor set];
	[NSBezierPath fillRect:rect];
	
	// Trace the axis
	[NSBezierPath setDefaultLineWidth:0.5];

	NSPoint start, end;
	float d_x, d_y;
	
	NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
	[fontAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											  size:8.0]
					   forKey:NSFontAttributeName];
	if (useFancyScaleColors)
	{
		[fontAttributes setObject:pluggedColor
						   forKey:NSForegroundColorAttributeName];
	}
	else
	{
		[fontAttributes setObject:gridColor
						   forKey:NSForegroundColorAttributeName];
	}
	
	// Horizontal grid
	for (i = 0; i <= GRID_VSPACING; i ++)
	{
		d_y = round(i * gridSize.height * 100 / (VSCALE * GRID_VSPACING));
		start = NSMakePoint(rect.origin.x + hPad,
							rect.origin.y + d_y + vPad + 0.5);
		end = NSMakePoint(rect.origin.x + gridSize.width + hPad,
						  rect.origin.y + d_y + vPad + 0.5);
		[gridColor set];
		[NSBezierPath strokeLineFromPoint:start
								  toPoint:end];
		if (drawScales)
		{
			NSString *label = [[[NSNumber numberWithInt:(i * 100 / GRID_VSPACING)] stringValue] stringByAppendingString:@"% "];
			NSSize labelSize = [label sizeWithAttributes:fontAttributes];
			[label drawAtPoint:NSMakePoint(start.x - labelSize.width,
										   start.y - 0.5 * labelSize.height)
				withAttributes:fontAttributes];
		}
	}
	
	// Vertical grid
	[fontAttributes setObject:gridColor
					   forKey:NSForegroundColorAttributeName];	
	for (i = 0; i <= GRID_HSPACING; i ++)
	{
		d_x = round(i * gridSize.width / GRID_HSPACING);
		start = NSMakePoint(rect.origin.x + d_x + hPad + 0.5,
							rect.origin.y + vPad);
		end = NSMakePoint(rect.origin.x + d_x + hPad + 0.5,
						  rect.origin.y + gridSize.height + vPad + 0.5);
		[gridColor set];
		[NSBezierPath strokeLineFromPoint:start
								  toPoint:end];
		
		if (drawScales)
		{
			int seconds = (int)round(hScale * ((1 - (float)i / GRID_HSPACING) + hOffset));
			int hours = seconds / 3600;
			int minutes = (seconds % 3600) / 60;
			
			NSString *label = [NSString stringWithFormat:NSLocalizedString(@"%dh:%.2dm", @"%dh:%.2dm"), hours, minutes];
			NSSize labelSize = [label sizeWithAttributes:fontAttributes];
			[label drawAtPoint:NSMakePoint(start.x - 0.5 * labelSize.width,
										   start.y - 1.5 * labelSize.height)
				withAttributes:fontAttributes];
		}
	}
	
	// From here on we need events to plot
	// If there are no events, return
	//NSLog(@"%@ %d", events, [events count]);
	int count = [events count];
	if (count < 1)
	{
		[fontAttributes release];
		return;
	}
	
	NSDate *endDate = [[events objectAtIndex:([events count] - 1)] date];
	int maxAmperage;
	if (drawAmperageGraph)
	{
		BatteryEvent *evt;
		evt = (BatteryEvent *)[events objectAtIndex:0];
		
		// Set up initial values
		maxAmperage = 1.1 * maxAmperageValue;
		
		/* Bug #3: amperage graph goes beyond view limits */
		// maxAmperage = 0.5 * [evt maxCapacity];
		
		if (useFancyScaleColors)
		{
			[fontAttributes setObject:amperageColor
							   forKey:NSForegroundColorAttributeName];
		}
		else
		{
			[fontAttributes setObject:gridColor
							   forKey:NSForegroundColorAttributeName];
		}

		if (drawScales)
		{
			// Amperage gauge
			for (i = 0; i <= GRID_VSPACING; i ++)
			{
				NSPoint lblPt = NSMakePoint(rect.origin.x + gridSize.width + hPad + 0.5,
											rect.origin.y + vPad + (i * gridSize.height / GRID_VSPACING) + 0.5);
				NSString *label = [NSString stringWithFormat:@" %.1fA", ((2.0 * i - GRID_VSPACING) * maxAmperage / (1000.0 * GRID_VSPACING))];
				NSSize labelSize = [label sizeWithAttributes:fontAttributes];
				[label drawAtPoint:NSMakePoint(lblPt.x,
											   lblPt.y - 0.5 * labelSize.height)
					withAttributes:fontAttributes];
			}
		}
	}			
	
	// Float array for dashed lines
	float dashedline[2];
	dashedline[0] = 6.0; //segment painted with stroke color
	dashedline[1] = 4.0; //segment not painted with a color
					
	[NSGraphicsContext saveGraphicsState]; {
		[NSBezierPath clipRect:gridRect];
		
		// Amperage graph
		if (drawAmperageGraph)
		{
			NSPoint pt1, pt2;
			int amperage, previousAmperage, scaled_amperage, previous_scaled_amperage;
			BatteryEvent *evt;
			evt = (BatteryEvent *)[events objectAtIndex:0];
			
			// Set up initial values
			amperage = previousAmperage = [evt amperage];
			scaled_amperage = previous_scaled_amperage = 100.0 * (amperage + maxAmperage) / (2 * maxAmperage);
						
			NSBezierPath *amperageGraph = [[NSBezierPath alloc] init];
			[amperageGraph setLineWidth:graphLineWidth];
			[amperageGraph setLineCapStyle:NSRoundLineCapStyle];
			[amperageGraph setLineJoinStyle:NSRoundLineJoinStyle];

			// Creating and draw first point
			pt1 = [self pointFor:scaled_amperage
								  date:[evt date]
								offset:endDate];
			if (shouldDrawBubbles)
			{
				NSPoint ipt = [scaling transformPoint:pt1];
				ipt.y -= 1;
				if (NSPointInRect(ipt, gridRect))
				{
					[bubbleCanvas lockFocus]; {
						[self drawImage:[NSImage imageNamed:@"amp_start"]
								atPoint:ipt];
					} [bubbleCanvas unlockFocus];
				}
			}
			[amperageGraph moveToPoint:pt1];
			[amperageGraph lineToPoint:pt1];
			
			for (i = 1; i < count; i++)
			{
				evt = (BatteryEvent *)[events objectAtIndex:i];
				
				if ([[evt type] isEqual:MBLSleepEventType])
				{
					pt2 = [self pointFor:previous_scaled_amperage
										  date:[evt date]
										offset:endDate];
					
					// Draw and flush previous path
					[amperageGraph lineToPoint:pt2];
					[amperageColor set];
					[amperageGraph transformUsingAffineTransform:scaling];
					[amperageGraph stroke];
					[amperageGraph release];
					
					if (shouldDrawBubbles)
					{
						NSPoint ipt = [scaling transformPoint:pt2];
						ipt.y -= 1;
						if (NSPointInRect(ipt, gridRect))
						{
							[bubbleCanvas lockFocus]; {
								[self drawImage:[NSImage imageNamed:@"sleep"]
										atPoint:ipt];
							} [bubbleCanvas unlockFocus];
						}
					}
					
					// Allocate a new path
					amperageGraph = [[NSBezierPath alloc] init];
					[amperageGraph setLineWidth:graphLineWidth];
					[amperageGraph setLineCapStyle:NSButtLineCapStyle];
					[amperageGraph setLineDash:dashedline count: 2 phase: 0.0];
					[amperageGraph moveToPoint:pt2];
				}
				else if ([[evt type] isEqual:MBLWakeUpEventType])
				{
					pt2 = [self pointFor:previous_scaled_amperage
										  date:[evt date]
										offset:endDate];
					
					// Draw and flush previous path
					[amperageGraph lineToPoint:pt2];
					[[NSColor grayColor] set];
					[amperageGraph transformUsingAffineTransform:scaling];
					[amperageGraph stroke];
					[amperageGraph release];
					
					if (shouldDrawBubbles)
					{
						NSPoint ipt = [scaling transformPoint:pt2];
						ipt.y -= 1;
						if (NSPointInRect(ipt, gridRect))
						{
							[bubbleCanvas lockFocus]; {
								[self drawImage:[NSImage imageNamed:@"amp_start"]
										atPoint:ipt];
							} [bubbleCanvas unlockFocus];
						}
					}
					
					// Allocate a new path
					amperageGraph = [[NSBezierPath alloc] init];
					[amperageGraph setLineWidth:graphLineWidth];
					[amperageGraph setLineCapStyle:NSRoundLineCapStyle];
					[amperageGraph setLineJoinStyle:NSRoundLineJoinStyle];
					[amperageGraph moveToPoint:pt2];			
				}
				else
				{
					amperage = [evt amperage];
					int abs_amperage = abs(amperage);
					scaled_amperage = 100.0 * (amperage + maxAmperage) / (2 * maxAmperage);
					if (amperage == previousAmperage &&
						amperage != 0 && // Always draw when amperage is zero
						i < count - 1) // Always draw last point
					{
						continue;
					}
					// Vai! Grafico adattivo! ;)
					if (abs_amperage > maxAmperageValue)
					{
						[self setMaxAmperageValue:abs_amperage];
					}
					pt2 = [self pointFor:scaled_amperage
										  date:[evt date]
										offset:endDate];
					
					
					previousAmperage = amperage;
					previous_scaled_amperage = scaled_amperage;
				}
				[amperageGraph lineToPoint:pt2];
				pt1 = pt2;
			}
			[amperageColor set];
			[amperageGraph transformUsingAffineTransform:scaling];
			[amperageGraph stroke];
			[amperageGraph release];
		}

		// Voltage graph
		if (drawVoltageGraph)
		{
			NSPoint pt1, pt2;
			int voltage, previousVoltage;
			BatteryEvent *evt;
			evt = (BatteryEvent *)[events objectAtIndex:0];
			
			// Set up initial values
			voltage = previousVoltage = 100 * [evt voltage] / maxVoltageValue;
			
			NSBezierPath *voltageGraph = [[NSBezierPath alloc] init];
			[voltageGraph setLineWidth:graphLineWidth];
			[voltageGraph setLineCapStyle:NSRoundLineCapStyle];
			[voltageGraph setLineJoinStyle:NSRoundLineJoinStyle];
			
			// Creating and draw first point
			pt1 = [self pointFor:previousVoltage
							date:[evt date]
						  offset:endDate];
			if (shouldDrawBubbles)
			{
				NSPoint ipt = [scaling transformPoint:pt1];
				ipt.y -= 1;
				if (NSPointInRect(ipt, gridRect))
				{
					[bubbleCanvas lockFocus]; {
						[self drawImage:[NSImage imageNamed:@"volt_start"]
								atPoint:ipt];
					} [bubbleCanvas unlockFocus];
				}
			}
			[voltageGraph moveToPoint:pt1];
			[voltageGraph lineToPoint:pt1];
			
			for (i = 1; i < count; i++)
			{
				evt = (BatteryEvent *)[events objectAtIndex:i];
				
				if ([[evt type] isEqual:MBLSleepEventType])
				{
					pt2 = [self pointFor:voltage
									date:[evt date]
								  offset:endDate];
					
					// Draw and flush previous path
					[voltageGraph lineToPoint:pt2];
					[voltageColor set];
					[voltageGraph transformUsingAffineTransform:scaling];
					[voltageGraph stroke];
					[voltageGraph release];
					
					if (shouldDrawBubbles)
					{
						NSPoint ipt = [scaling transformPoint:pt2];
						ipt.y -= 1;
						if (NSPointInRect(ipt, gridRect))
						{
							[bubbleCanvas lockFocus]; {
								[self drawImage:[NSImage imageNamed:@"sleep"]
										atPoint:ipt];
							} [bubbleCanvas unlockFocus];
						}
					}
					
					// Allocate a new path
					voltageGraph = [[NSBezierPath alloc] init];
					[voltageGraph setLineWidth:graphLineWidth];
					[voltageGraph setLineCapStyle:NSButtLineCapStyle];
					[voltageGraph setLineDash:dashedline count: 2 phase: 0.0];
					[voltageGraph moveToPoint:pt2];
				}
				else if ([[evt type] isEqual:MBLWakeUpEventType])
				{
					pt2 = [self pointFor:voltage
									date:[evt date]
								  offset:endDate];
					
					// Draw and flush previous path
					[voltageGraph lineToPoint:pt2];
					[[NSColor grayColor] set];
					[voltageGraph transformUsingAffineTransform:scaling];
					[voltageGraph stroke];
					[voltageGraph release];
					
					if (shouldDrawBubbles)
					{
						NSPoint ipt = [scaling transformPoint:pt2];
						ipt.y -= 1;
						if (NSPointInRect(ipt, gridRect))
						{
							[bubbleCanvas lockFocus]; {
								[self drawImage:[NSImage imageNamed:@"volt_start"]
										atPoint:ipt];
							} [bubbleCanvas unlockFocus];
						}
					}
					
					// Allocate a new path
					voltageGraph = [[NSBezierPath alloc] init];
					[voltageGraph setLineWidth:graphLineWidth];
					[voltageGraph setLineCapStyle:NSRoundLineCapStyle];
					[voltageGraph setLineJoinStyle:NSRoundLineJoinStyle];
					[voltageGraph moveToPoint:pt2];			
				}
				else
				{
					int voltage = 100.0 * [evt voltage] / maxVoltageValue;
					if (voltage == previousVoltage &&
						i < count - 1) // Always draw last point
					{
						continue;
					}					
					// Vai! Grafico adattivo! ;)
					if ([evt voltage] > maxVoltageValue)
					{
						[self setMaxVoltageValue:[evt voltage]];
					}
					
					pt2 = [self pointFor:voltage
									date:[evt date]
								  offset:endDate];
					
					previousVoltage = voltage;
				}
				[voltageGraph lineToPoint:pt2];
				pt1 = pt2;
			}
			[voltageColor set];
			[voltageGraph transformUsingAffineTransform:scaling];
			[voltageGraph stroke];
			[voltageGraph release];
		}
		
		// Charge graph
		BOOL isCharging, wasCharging, isPlugged, wasPlugged;
		int charge, previousCharge;
		NSBezierPath *graph = [[NSBezierPath alloc] init];
		[graph setLineWidth:graphLineWidth];
		[graph setLineCapStyle:NSRoundLineCapStyle];
		[graph setLineJoinStyle:NSRoundLineJoinStyle];
		NSPoint pt1, pt2;
		pt1 = NSZeroPoint;
		BatteryEvent *evt;
		evt = (BatteryEvent *)[events objectAtIndex:0];
		
		// Set up initial values
		isCharging = wasCharging = [evt isCharging];
		isPlugged = wasPlugged = [evt isPlugged];
		charge = previousCharge = [evt charge];
		
		// Creating and draw first point
		pt1 = [self pointFor:previousCharge
						date:[evt date]
					  offset:endDate];
		if (shouldDrawBubbles)
		{
			NSPoint ipt = [scaling transformPoint:pt1];
			ipt.y -= 1;
			if (NSPointInRect(ipt, gridRect))
			{
				[bubbleCanvas lockFocus]; {
					[self drawImage:[NSImage imageNamed:@"start"]
							atPoint:ipt];
				} [bubbleCanvas unlockFocus];
			}
		}
		[graph moveToPoint:pt1];
		[graph lineToPoint:pt1];
		
		for (i = 1; i < count; i++)
		{
			evt = (BatteryEvent *)[events objectAtIndex:i];
			
			if ([[evt type] isEqual:MBLSleepEventType])
			{
				pt2 = [self pointFor:charge
								date:[evt date]
							  offset:endDate];
				
				// Draw and flush previous path
				[graph lineToPoint:pt2];
				[wasPlugged ? wasCharging ? chargingColor : pluggedColor : unpluggedColor set];
				[graph transformUsingAffineTransform:scaling];
				[graph stroke];
				[graph release];
				
				if (shouldDrawBubbles)
				{
					NSPoint ipt = [scaling transformPoint:pt2];
					ipt.y -= 1;
					if (NSPointInRect(ipt, gridRect))
					{
						[bubbleCanvas lockFocus]; {
							[self drawImage:[NSImage imageNamed:@"sleep"]
									atPoint:ipt];
						} [bubbleCanvas unlockFocus];
					}
				}
				
				// Allocate a new path
				graph = [[NSBezierPath alloc] init];
				[graph setLineWidth:graphLineWidth];
				[graph setLineCapStyle:NSButtLineCapStyle];
				[graph setLineDash:dashedline count: 2 phase: 0.0];
				[graph moveToPoint:pt2];
				
			}
			else if ([[evt type] isEqual:MBLWakeUpEventType])
			{
				pt2 = [self pointFor:charge
								date:[evt date]
							  offset:endDate];
				
				// Draw and flush previous path
				[graph lineToPoint:pt2];
				[[NSColor grayColor] set];
				[graph transformUsingAffineTransform:scaling];
				[graph stroke];
				[graph release];
				
				if (shouldDrawBubbles)
				{
					NSPoint ipt = [scaling transformPoint:pt2];
					ipt.y -= 1;
					if (NSPointInRect(ipt, gridRect))
					{
						[bubbleCanvas lockFocus]; {
							[self drawImage:[NSImage imageNamed:@"start"]
									atPoint:ipt];
						} [bubbleCanvas unlockFocus];
					}
				}
				
				// Allocate a new path
				graph = [[NSBezierPath alloc] init];
				[graph setLineWidth:graphLineWidth];
				[graph setLineCapStyle:NSRoundLineCapStyle];
				[graph setLineJoinStyle:NSRoundLineJoinStyle];
				[graph moveToPoint:pt2];			
			}
			else // if ([[evt type] isEqual:MBLBatteryEventType]) */
			{
				charge = [evt charge];
				isCharging = [evt isCharging];
				isPlugged = [evt isPlugged];
				
				// Skip if nothing changed from previous point
				if (charge == previousCharge &&
					!(isCharging ^ wasCharging) &&
					!(isPlugged ^ wasPlugged) &&
					i < count - 1) // Always draw last point
				{
					// skip
					continue;
				}
				
				pt2 = [self pointFor:charge
								date:[evt date]
							  offset:endDate];
				
				if ((isPlugged ^ wasPlugged) ||
					(isCharging ^ wasCharging))
				{
					// Draw and flush previous path
					[graph lineToPoint:pt2];
					[wasPlugged ? wasCharging ? chargingColor : pluggedColor : unpluggedColor set];
					[graph transformUsingAffineTransform:scaling];
					[graph stroke];
					[graph release];
					
					if (shouldDrawBubbles)
					{
						NSPoint ipt = [scaling transformPoint:pt2];
						ipt.y -= 1;
						if (NSPointInRect(ipt, gridRect))
						{
							NSImage *mark;
							if (isPlugged ^ wasPlugged)
							{
								mark = isPlugged ? [NSImage imageNamed:@"plug"] : [NSImage imageNamed:@"unplug"];
							}
							else
							{
								mark = isCharging ? [NSImage imageNamed:@"charge"] : [NSImage imageNamed:@"chargeover"];
							}
							[bubbleCanvas lockFocus]; {
								[self drawImage:mark
										atPoint:ipt];
							} [bubbleCanvas unlockFocus];
						}
					}
					
					// Allocate a new path
					graph = [[NSBezierPath alloc] init];
					[graph setLineWidth:graphLineWidth];
					[graph setLineCapStyle:NSRoundLineCapStyle];
					[graph setLineJoinStyle:NSRoundLineJoinStyle];
					[graph moveToPoint:pt2];
				}
				wasCharging = isCharging;
				wasPlugged = isPlugged;
				previousCharge = charge;
			}
			[graph lineToPoint:pt2];
			pt1 = pt2;
		}
		[wasPlugged ? wasCharging ? chargingColor : pluggedColor : unpluggedColor set];
		[graph transformUsingAffineTransform:scaling];
		[graph stroke];
		[graph release];
		
	} [NSGraphicsContext restoreGraphicsState];

	// Draw the bubble canvas
	if (shouldDrawBubbles)
	{
		[bubbleCanvas drawAtPoint:NSZeroPoint
						 fromRect:rect
						operation:NSCompositeSourceOver
						 fraction:1.0];
		[bubbleCanvas release];
	}

	if (selectedEventIndex != MBLNoSelectedEvent)
	{
		// Draw bullets for selected event
		BatteryEvent *selectedEvent = [events objectAtIndex:selectedEventIndex];
		NSPoint selPt = [scaling transformPoint:[self pointFor:[selectedEvent charge]
														  date:[selectedEvent date]
														offset:endDate]];
		NSBezierPath *selectionBullet = [NSBezierPath bezierPath];
		[selectionBullet setLineWidth:graphLineWidth];
		NSRect selectionBulletRect = NSMakeRect(selPt.x - 4,
												selPt.y - 4,
												 8,
												 8);
		[selectionBullet appendBezierPathWithOvalInRect:selectionBulletRect];
		[backgroundColor set];
		[selectionBullet fill];
		[[NSColor blackColor] set];
		[selectionBullet stroke];	

		if (drawAmperageGraph)
		{
			int amperage = 100.0 * ([selectedEvent amperage] + maxAmperage) / (2 * maxAmperage);		
			selPt = [scaling transformPoint:[self pointFor:amperage
													  date:[selectedEvent date]
													offset:endDate]];
			selectionBullet = [NSBezierPath bezierPath];
			[selectionBullet setLineWidth:graphLineWidth];
			selectionBulletRect = NSMakeRect(selPt.x - 4,
													selPt.y - 4,
													8,
													8);
			[selectionBullet appendBezierPathWithOvalInRect:selectionBulletRect];
			[backgroundColor set];
			[selectionBullet fill];
			[[NSColor blackColor] set];
			[selectionBullet stroke];	
		}
		
		if (drawVoltageGraph)
		{
			int voltage = 100.0 * [selectedEvent voltage] / maxVoltageValue;		
			selPt = [scaling transformPoint:[self pointFor:voltage
													  date:[selectedEvent date]
													offset:endDate]];
			selectionBullet = [NSBezierPath bezierPath];
			[selectionBullet setLineWidth:graphLineWidth];
			selectionBulletRect = NSMakeRect(selPt.x - 4,
											 selPt.y - 4,
											 8,
											 8);
			[selectionBullet appendBezierPathWithOvalInRect:selectionBulletRect];
			[backgroundColor set];
			[selectionBullet fill];
			[[NSColor blackColor] set];
			[selectionBullet stroke];	
		}
	}
	
	// Update the direct and inverse transforms
	[self setDirectTransform:scaling];
	
	// Clean up
	[fontAttributes release];
}

#pragma mark === Actions ===

- (IBAction)zoomIn:(id)sender
{
	if ([self canZoomIn])
	{
		hScale /= 2.0;
		hOffset *= 2;
		[self setNeedsDisplay:YES];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)zoomOut:(id)sender
{
	if ([self canZoomOut])
	{
		hScale *= 2.0;
		hOffset /= 2;
		[self setNeedsDisplay:YES];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)zoomToFit:(id)sender
{
#pragma unused (sender)
	/**
	 *	This method calculates the duration of the monitoring
	 *	and scales the chart to accommodate all of its length
	 */
	if ([events count] < 1)
	{
		return;
	}
	NSTimeInterval start, end;
	start = [[[events objectAtIndex:0] date] timeIntervalSinceReferenceDate];
	end = [[[events objectAtIndex:[events count] - 1] date] timeIntervalSinceReferenceDate];

	int duration = end - start;
	if (duration == 0)
	{
		// Just one event
		hScale = HSCALE_DEFAULT;
	}	
	else if (duration >= hScale)
	{
		// Enlarge till the chart is large enough
		while (hScale < MIN(duration, HSCALE_MAX))
		{
			hScale *= 2;
		}
	}
	else if (duration < hScale / 2)
	{
		// Resize to fit the chart
		while (hScale > 2 * MAX(duration, HSCALE_MIN))
		{
			hScale /= 2;
		}
	}
	// Bring to rightmost side
	hOffset = 0;
	[self setNeedsDisplay:YES];
}

- (IBAction)shiftLeft:(id)sender
{
	if ([self canShiftLeft])
	{
		hOffset++;
		[self setNeedsDisplay:YES];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)shiftRight:(id)sender
{
	if ([self canShiftRight])
	{
		hOffset--;
		[self setNeedsDisplay:YES];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)forceSelection:(id)sender
{
#pragma unused (sender)
	if (selectedEventIndex == MBLNoSelectedEvent)
	{
		[self selectEventAtIndex:0];
	}
}

- (IBAction)toggleSelectionTracksLastPoint:(id)sender
{
#pragma unused (sender)
	selectionTracksLastPoint = !selectionTracksLastPoint;
}

- (IBAction)copy:(id)sender
{
	[self copyChartToPasteboard:[NSPasteboard generalPasteboard]];
}

#pragma mark === Accessors ===

- (BOOL)canZoomIn
{
	return hScale > HSCALE_MIN;
}

- (BOOL)canZoomOut
{
	return hScale < HSCALE_MAX;
}

- (BOOL)canShiftLeft
{
	return (hOffset < (HSCALE_MAX / hScale) - 1);
}

- (BOOL)canShiftRight
{
	return hOffset > 0;
}

- (int)maxAmperageValue
{
	return maxAmperageValue;
}

- (void)setMaxAmperageValue:(int)newVal
{
	if (newVal > 0)
	{
		maxAmperageValue = newVal;
	}
}

- (int)maxVoltageValue
{
	return maxVoltageValue;
}

- (void)setMaxVoltageValue:(int)newVal
{
	if (newVal > 0)
	{
		maxVoltageValue = newVal;
	}
}

- (NSColor *)pluggedColor
{
	return pluggedColor;
}
- (void)setPluggedColor:(NSColor *)aColor
{
	[aColor retain];
	[pluggedColor release];
	pluggedColor = aColor;
}

- (NSColor *)unpluggedColor
{
	return unpluggedColor;
}

- (void)setUnpluggedColor:(NSColor *)aColor
{
	[aColor retain];
	[unpluggedColor release];
	unpluggedColor = aColor;
}

- (NSColor *)chargingColor
{
	return chargingColor;
}
- (void)setChargingColor:(NSColor *)aColor
{
	[aColor retain];
	[chargingColor release];
	chargingColor = aColor;
}

- (NSColor *)gridColor
{
	return gridColor;
}
- (void)setGridColor:(NSColor *)aColor
{
	[aColor retain];
	[gridColor release];
	gridColor = aColor;
}


- (NSColor *)backgroundColor
{
	return backgroundColor;
}
- (void)setBackgroundColor:(NSColor *)aColor
{
	[aColor retain];
	[backgroundColor release];
	backgroundColor = aColor;
}

- (NSColor *)amperageColor
{
	return amperageColor;
}
- (void)setAmperageColor:(NSColor *)aColor
{
	[aColor retain];
	[amperageColor release];
	amperageColor = aColor;
}

- (NSColor *)voltageColor
{
	return voltageColor;
}
- (void)setVoltageColor:(NSColor *)aColor
{
	[aColor retain];
	[voltageColor release];
	voltageColor = aColor;
}

- (BOOL)shouldDrawBubbles
{
	return shouldDrawBubbles;
}
- (void)setShouldDrawBubbles:(BOOL)draw
{
	shouldDrawBubbles = draw;
}

- (BOOL)drawAmperageGraph
{
	return drawAmperageGraph;
}
- (void)setDrawAmperageGraph:(BOOL)draw
{
	drawAmperageGraph = draw;
}

- (BOOL)drawVoltageGraph
{
	return drawVoltageGraph;
}
- (void)setDrawVoltageGraph:(BOOL)draw
{
	drawVoltageGraph = draw;
}

- (NSAffineTransform *)directTransform
{
	return directTransform;
}
- (NSAffineTransform *)inverseTransform
{
	return inverseTransform;
}
- (void)setDirectTransform:(NSAffineTransform *)transf
{
	// Store direct transform
	[transf retain];
	[directTransform release];
	directTransform = transf;
	// Store inverse transform
	[inverseTransform release];
	inverseTransform = [directTransform copy];	
	[inverseTransform invert];
}


- (NSMutableArray *)events
{
	return events;
}
- (void)setEvents:(NSMutableArray *)arr
{
	[arr retain];
	[events release];
	events = arr;
	
	// Set eventController's content to the first event in session
	if ([events count] > 0)
	{
		[eventController setContent:nil];
		selectedEventIndex = MBLNoSelectedEvent;
	}

	/**
	 *	2006-12-23 Fixed bug "deleting a session won't cause the chart view to update the graph"
	 */
	// Zoom to fit & force redraw
	[self zoomToFit:nil];
}

- (MonitoringSession *)currentSession
{
	return currentSession;
}
- (void)setCurrentSession:(MonitoringSession *)session
{
	[self setEvents:[session events]];
	[session retain];
	[currentSession release];
	currentSession = session;
	
	// Set eventController's content to the first event in session
	if ([events count] > 0)
	{
		[eventController setContent:nil];
		selectedEventIndex = MBLNoSelectedEvent;
	}
}

#pragma mark === NSResponder event handlers ===

- (void)mouseDown:(NSEvent *)event
{
	unsigned int flags = [event modifierFlags];
	
	if (flags & NSAlternateKeyMask)
	{
		NSPasteboard *pb;
		// Get the drag pasteboard
		pb = [NSPasteboard pasteboardWithName:NSDragPboard];

		[self copyChartToPasteboard:pb];

		NSImage *anImage, *canvas;
		NSSize s;
		NSPoint p;
		NSRect imageBounds;
		
		// Get the size of the view
		s = [self bounds].size;
		
		// Create an image
		anImage = [[NSImage alloc] initWithSize:s];

		canvas = [self drawToImage];
		
		// Create a rect to write into
		imageBounds.origin = NSZeroPoint;
		imageBounds.size = s;
		
		// Draw to image with transparency
		[anImage lockFocus]; {
			[canvas drawAtPoint:NSZeroPoint
					   fromRect:imageBounds
					  operation:NSCompositeSourceOver
					   fraction:0.5];
		} [anImage unlockFocus];
		
		// Location of the drag event
		p = [self convertPoint:[event locationInWindow] fromView:nil];
		
		// Adjust to the center of the image
		p.x -= s.width / 2;
		p.y -= s.height / 2;

		[self copyChartToPasteboard:pb];
		
		// Start the drag
		[self dragImage:anImage
					 at:p
				 offset:NSZeroSize
				  event:event
			 pasteboard:pb
				 source:self
			  slideBack:YES];
		
		// Cleanup
		[anImage release];
	}
	else
	{	
		if ([event clickCount] == 2)
		{
			// Show event inspector
			if (![balloon isVisible])
			{
				[balloon orderFront:nil];
			}
		}
		else
		{		
			BOOL keepOn = YES;
			NSPoint startPoint;
			NSPoint currentPoint;
			NSEvent *theEvent;
			
			startPoint = [self convertPoint:[event locationInWindow] fromView:nil];
			[self trackPoint:startPoint];
			
			while (keepOn) {
				theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
					NSLeftMouseDraggedMask];
				currentPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				switch ([theEvent type]) {
					case NSLeftMouseDragged:
					{
						if (startPoint.x != currentPoint.x)
						{
							[self trackPoint:currentPoint];
						}
						break;
					}
					case NSLeftMouseUp:
						keepOn = NO;
						break;
					default:
						/* Ignore any other kind of event. */
						break;
				}
				
			};
		}
	}
}

- (void)rightMouseDown:(NSEvent *)event
{
}

- (void)otherMouseDown:(NSEvent *)event
{
}

- (void)mouseUp:(NSEvent *)event
{
}

- (void)rightMouseUp:(NSEvent *)event
{
}

- (void)otherMouseUp:(NSEvent *)event
{
}

- (void)mouseDragged:(NSEvent *)event
{
}

- (void)rightMouseDragged:(NSEvent *)event
{
}

- (void)otherMouseDragged:(NSEvent *)event
{
}

- (void)scrollWheel:(NSEvent *)event
{
	unsigned int flags = [event modifierFlags];
	if (flags & NSShiftKeyMask)
	{
		// Horizontal scrolling
		if ([event deltaX] > 0.0)
		{
			// Scroll left
			[self shiftLeft:nil];
		}
		else
		{
			// Scroll right
			[self shiftRight:nil];
		}
	}
	else
	{
		// Vertical scrolling
		if ([event deltaY] > 0.0)
		{
			// Scroll up
			[self zoomOut:nil];
		}
		else
		{
			// Scroll down
			[self zoomIn:nil];
		}
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

@end

@implementation CPChartView (Private)

- (NSImage *)drawToImage
{
	NSImage *canvas;
	NSSize s;

	NSRect imageBounds;
	
	// Get the size of the view
	s = [self bounds].size;
	
	// Create an image
	canvas = [[NSImage alloc] initWithSize:s];
	
	// Create a rect to write into
	imageBounds.origin = NSZeroPoint;
	imageBounds.size = s;
	
	// Draw to the canvas
	[canvas lockFocus]; {
		[self drawRect:imageBounds];
	} [canvas unlockFocus];
	
	return [canvas autorelease];	
}

- (void) copyChartToPasteboard:(NSPasteboard *)pb
{
	NSImage *anImage;

	anImage = [self drawToImage];
	
	// Put the image to the pasteboard
	[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];
	[pb setData:[anImage TIFFRepresentation] forType:NSTIFFPboardType];
}

- (void)handleInspectorScreenChange:(NSNotification *)notif
{
	//NSLog(@"%@", [notif object]);
}

- (void)drawImage:(NSImage *)img atPoint:(NSPoint)pt
{
	float w = [img size].width;
	float h = [img size].height;
	NSPoint destPoint = NSMakePoint((int)(pt.x - 0.5 * w),
									(int)(pt.y - 0.5 * graphLineWidth));
	[img drawAtPoint:destPoint
			fromRect:NSMakeRect(0,
								0,
								w,
								h)
		   operation:NSCompositeSourceOver
			fraction:1.0];		
}

- (void)handlePropertyChange:(NSNotification *)note
{
	id sender = [note object];
	NSString *name = [note name];
	if ([name isEqual:MBLChartGridColorChangedNotification])
	{
		[self setGridColor:[sender gridColor]];
	}
	else if ([name isEqual:MBLChartAmperageColorChangedNotification])
	{
		[self setAmperageColor:[sender amperageColor]];
	}
	else if ([name isEqual:MBLChartVoltageColorChangedNotification])
	{
		[self setVoltageColor:[sender voltageColor]];
	}
	else if ([name isEqual:MBLChartBackgroundColorChangedNotification])
	{
		[self setBackgroundColor:[sender backgroundColor]];
	}
	else if ([name isEqual:MBLChartPluggedColorChangedNotification])
	{
		[self setPluggedColor:[sender pluggedColor]];
	}
	else if ([name isEqual:MBLChartUnpluggedColorChangedNotification])
	{
		[self setUnpluggedColor:[sender unpluggedColor]];
	}
	else if ([name isEqual:MBLChartChargingColorChangedNotification])
	{
		[self setChargingColor:[sender chargingColor]];
	}
	else if ([name isEqual:MBLChartShouldDrawBubblesChangedNotification])
	{
		[self setShouldDrawBubbles:[sender shouldDrawBubbles]];
	}
	else if ([name isEqual:MBLChartDrawAmperageGraphChangedNotification])
	{
		[self setDrawAmperageGraph:[sender drawAmperageGraph]];
	}
	else if ([name isEqual:MBLChartDrawVoltageGraphChangedNotification])
	{
		[self setDrawVoltageGraph:[sender drawVoltageGraph]];
	}
	[self setNeedsDisplay:YES];
}

- (void)updateChartProperties
{
}

- (void)selectEventMatchingTimeInterval:(NSTimeInterval)interval
{
	int len = [events count] - 1;
	NSDate *endDate = [[events objectAtIndex:len] date],
		*startDate = [[events objectAtIndex:0] date];
	if ([startDate timeIntervalSinceDate:endDate] > interval)
	{
		[self selectEventAtIndex:MBLNoSelectedEvent];
	}
	else
	{
		int i = len;
		while (i >= 0)
		{
			if ([[[events objectAtIndex:i] date] timeIntervalSinceDate:endDate] <= interval &&
				[[events objectAtIndex:i] type] != MBLSleepEventType && 
				[[events objectAtIndex:i] type] != MBLWakeUpEventType)
			{
				[self selectEventAtIndex:i];
				return;
			}
			i--;
		}
	}
}

- (void) selectEventAtIndex:(int)index
{
	if (index >= 0 &&
		index < [events count])
	{
		[eventController setContent:[events objectAtIndex:index]];
		selectedEventIndex = index;
	}
	else if (index == MBLNoSelectedEvent)
	{
		[eventController setContent:nil];
		selectedEventIndex = MBLNoSelectedEvent;
	}
}

- (NSPoint)pointFor:(int)qty date:(NSDate *)date offset:(NSDate *)startDate;
{
	NSPoint pt = NSMakePoint([date timeIntervalSinceDate:startDate],
							 qty);
	return pt;
}

- (void)trackPoint:(NSPoint)pt
{
	if (NSPointInRect(pt, gridRect))
	{
		NSPoint convertedPt = [inverseTransform transformPoint:pt];
		[self selectEventMatchingTimeInterval:(int)round(convertedPt.x)];
		[self setNeedsDisplay:YES];
	}
	else
	{
		[self selectEventAtIndex:MBLNoSelectedEvent];
		[self setNeedsDisplay:YES];
	}
}

@end

@implementation CPChartView (NSMenuValidation)

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	if ([menuItem action] == @selector(shiftLeft:))
	{
		return ([self canShiftLeft]);
	}
	else if ([menuItem action] == @selector(shiftRight:))
	{
		return ([self canShiftRight]);
	}
	else if ([menuItem action] == @selector(zoomOut:))
	{
		return ([self canZoomOut]);
	}
	else if ([menuItem action] == @selector(zoomIn:))
	{
		return ([self canZoomIn]);
	}
	return YES;
}

@end

@implementation CPChartView (NSDraggingSource)

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
#pragma unused (isLocal)
	return NSDragOperationCopy;
}

@end
