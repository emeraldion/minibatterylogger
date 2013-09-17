//
//  MBLMainChartView.m
//  MiniBatteryLogger
//
//  Created by delphine on 14-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "MBLMainChartView.h"

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

#define VSCALE 100.0

#define GRID_HSPACING 6
#define GRID_VSPACING 10

NSString *MBLChartBackgroundColorKey = @"Chart Background Color";
NSString *MBLChartChargingColorKey = @"Chart Charging Color";
NSString *MBLChartPluggedColorKey = @"Chart Plugged Color";
NSString *MBLChartUnpluggedColorKey = @"Chart Unplugged Color";
NSString *MBLChartGridColorKey = @"Chart Grid Color";
NSString *MBLChartAmperageColorKey = @"Chart Amperage Color";
NSString *MBLChartShouldDrawBubblesKey = @"Draw Bubbles";
NSString *MBLChartDrawAmperageGraphKey = @"Draw Amperage Graph";

NSString *MBLChartBackgroundColorChangedNotification = @"Chart Background Color Changed";
NSString *MBLChartChargingColorChangedNotification = @"Chart Charging Color Changed";
NSString *MBLChartPluggedColorChangedNotification = @"Chart Plugged Color Changed";
NSString *MBLChartUnpluggedColorChangedNotification = @"Chart Unplugged Color Changed";
NSString *MBLChartGridColorChangedNotification = @"Chart Grid Color Changed";
NSString *MBLChartAmperageColorChangedNotification = @"Chart Amperage Color Changed";
NSString *MBLChartShouldDrawBubblesChangedNotification = @"Draw Bubbles Changed";
NSString *MBLChartDrawAmperageGraphChangedNotification = @"Draw Amperage Graph Changed";

@class PreferenceController;

@interface MBLMainChartView (Private)

- (void)drawImage:(NSImage *)img atPoint:(NSPoint)pt;
- (void)handlePropertyChange:(NSNotification *)note;
- (void)updateChartProperties;

@end

@implementation MBLMainChartView

+ (void)initialize
{
	/* Expose binding */
	[self exposeBinding:@"events"];
	
	/* Registering Standard User Defaults */
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:MBLChartUnpluggedColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]] forKey:MBLChartPluggedColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor orangeColor]] forKey:MBLChartChargingColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor lightGrayColor]] forKey:MBLChartGridColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MBLChartBackgroundColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor magentaColor]] forKey:MBLChartAmperageColorKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MBLChartShouldDrawBubblesKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MBLChartDrawAmperageGraphKey];
	
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
		
		//points = [[NSMutableArray alloc] init];
		
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
													 name:MBLChartShouldDrawBubblesChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartDrawAmperageGraphChangedNotification
												   object:nil];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[self setPluggedColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartPluggedColorKey]]];
		[self setUnpluggedColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartUnpluggedColorKey]]];
		[self setChargingColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartChargingColorKey]]];
		[self setGridColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartGridColorKey]]];
		[self setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartBackgroundColorKey]]];
		[self setAmperageColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartAmperageColorKey]]];
		[self setShouldDrawBubbles:[[defaults objectForKey:MBLChartShouldDrawBubblesKey] boolValue]];
		[self setDrawAmperageGraph:[[defaults objectForKey:MBLChartDrawAmperageGraphKey] boolValue]];
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//[points release];
	[pluggedColor release];
	[unpluggedColor release];
	[chargingColor release];
	[gridColor release];
	[backgroundColor release];
	[amperageColor release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
	int i;
	NSImage *bubbleCanvas;
	NSSize gridSize = NSMakeSize(rect.size.width - 2*HPAD,
								 rect.size.height - 2*VPAD);
	
	// Update events to reflect current selection
	// FIXME: reimplement this using KVO
	/*
	 if ([eventsController selection] != nil)
	 {
		 // Retain to prevent deallocation during draw
		 [self setEvents:[eventsController content]];
	 }
	 */
	
	if (shouldDrawBubbles)
	{
		bubbleCanvas = [[NSImage alloc] initWithSize:rect.size];
	}
	
	// Scale the graph to completely fill the view rect
	NSAffineTransform *scaling = [NSAffineTransform transform];
	
	[scaling translateXBy:gridSize.width * (1 + hOffset) + HPAD
					  yBy:VPAD];
	[scaling scaleXBy:(gridSize.width / hScale)
				  yBy:(gridSize.height / VSCALE)];
	
	// Fill background with backgroundColor
    [backgroundColor set];
	[NSBezierPath fillRect:rect];
	
	// Trace the axis
	[gridColor set];
	NSPoint start, end;
	float d_x, d_y;
	
	NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
	[fontAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											  size:8.0]
					   forKey:NSFontAttributeName];
	[fontAttributes setObject:gridColor
					   forKey:NSForegroundColorAttributeName];
	
	// Horizontal grid
	for (i = 0; i <= GRID_VSPACING; i ++)
	{
		d_y = round(i * gridSize.height * 100 / (VSCALE * GRID_VSPACING));
		start = NSMakePoint(rect.origin.x + HPAD,
							rect.origin.y + d_y + VPAD + 0.5);
		end = NSMakePoint(rect.origin.x + gridSize.width + HPAD,
						  rect.origin.y + d_y + VPAD + 0.5);
		[NSBezierPath setDefaultLineWidth:0.5];
		[NSBezierPath strokeLineFromPoint:start
								  toPoint:end];
		NSString *label = [[[NSNumber numberWithInt:(i * 100 / GRID_VSPACING)] stringValue] stringByAppendingString:@"% "];
		NSSize labelSize = [label sizeWithAttributes:fontAttributes];
		if (false)
		{
			[label drawRoundedLabelAtPoint:NSMakePoint(start.x - labelSize.width,
													   start.y - 0.5 * labelSize.height)
							withAttributes:fontAttributes
						   backgroundColor:pluggedColor];
		}
		else
		{
			[label drawAtPoint:NSMakePoint(start.x - labelSize.width,
										   start.y - 0.5 * labelSize.height)
				withAttributes:fontAttributes];
		}
	}
	
	// Vertical grid
	for (i = 0; i <= GRID_HSPACING; i ++)
	{
		d_x = round(i * gridSize.width / GRID_HSPACING);
		start = NSMakePoint(rect.origin.x + d_x + HPAD + 0.5,
							rect.origin.y + VPAD);
		end = NSMakePoint(rect.origin.x + d_x + HPAD + 0.5,
						  rect.origin.y + gridSize.height + VPAD + 0.5);
		[NSBezierPath setDefaultLineWidth:0.5];
		[NSBezierPath strokeLineFromPoint:start
								  toPoint:end];
		int seconds = (int)round(hScale * ((1 - (float)i / GRID_HSPACING) + hOffset));
		int hours = seconds / 3600;
		int minutes = (seconds % 3600) / 60;
		
		NSString *label = [NSString stringWithFormat:@"%dh:%.2dm", hours, minutes];
		NSSize labelSize = [label sizeWithAttributes:fontAttributes];
		[label drawAtPoint:NSMakePoint(start.x - 0.5 * labelSize.width,
									   start.y - 1.5 * labelSize.height)
			withAttributes:fontAttributes];
	}
	
	// From here on we need points to plot
	// If there are no points, return
	int count = [points count];
	if (count < 1)
	{
		return;
	}
	
	NSDate *endDate = [[points objectAtIndex:([points count] - 1)] date];
	int maxAmperage;
	if (drawAmperageGraph)
	{
		BatteryEvent *evt;
		evt = (BatteryEvent *)[points objectAtIndex:0];
		
		// Set up initial values
		maxAmperage = 1.1 * maxAmperageValue;
		
		/* Bug #3: amperage graph goes beyond view limits */
		// maxAmperage = 0.5 * [evt maxCapacity];
		
		// Amperage gauge
		for (i = 0; i <= GRID_VSPACING; i ++)
		{
			NSPoint lblPt = NSMakePoint(rect.origin.x + gridSize.width + HPAD + 0.5,
										rect.origin.y + VPAD + (i * gridSize.height / GRID_VSPACING) + 0.5);
			NSString *label = [NSString stringWithFormat:@" %.1fA", ((2.0 * i - GRID_VSPACING) * maxAmperage / (1000.0 * GRID_VSPACING))];
			NSSize labelSize = [label sizeWithAttributes:fontAttributes];
			if (false)
			{
				[label drawRoundedLabelAtPoint:NSMakePoint(lblPt.x,
														   lblPt.y - 0.5 * labelSize.height)
								withAttributes:fontAttributes
							   backgroundColor:amperageColor];
			}
			else
			{
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
				
	// Charge graph
	
	BOOL isCharging, wasCharging, isPlugged, wasPlugged;
	int charge, previousCharge;
	NSBezierPath *graph = [[NSBezierPath alloc] init];
	[graph setLineWidth:GRAPH_LINE_WIDTH];
	[graph setLineCapStyle:NSRoundLineCapStyle];
	NSPoint pt1, pt2;
	pt1 = NSZeroPoint;
	BatteryEvent *evt;
	evt = (BatteryEvent *)[points objectAtIndex:0];
	
	// Set up initial values
	isCharging = wasCharging = [evt isCharging];
	isPlugged = wasPlugged = [evt isPlugged];
	charge = previousCharge = [evt charge];
	
	// Creating and draw first point
	pt1 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
					  (int)(previousCharge + 0.5));
	if (shouldDrawBubbles)
	{
		NSPoint ipt = [scaling transformPoint:pt1];
		ipt.y -= 1;
		[bubbleCanvas lockFocus];
		[self drawImage:[NSImage imageNamed:@"start"]
				atPoint:ipt];
		[bubbleCanvas unlockFocus];
	}
	[graph moveToPoint:pt1];
	[graph lineToPoint:pt1];
	
	for (i = 1; i < count; i++)
	{
		evt = (BatteryEvent *)[points objectAtIndex:i];
		
		if ([[evt type] isEqual:MBLSleepEventType])
		{
			pt2 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
							  (int)(charge + 0.5));
			
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
				[bubbleCanvas lockFocus];
				[self drawImage:[NSImage imageNamed:@"sleep"]
						atPoint:ipt];
				[bubbleCanvas unlockFocus];
			}
			
			// Allocate a new path
			graph = [[NSBezierPath alloc] init];
			[graph setLineWidth:GRAPH_LINE_WIDTH];
			[graph setLineCapStyle:NSButtLineCapStyle];
			[graph setLineDash:dashedline count: 2 phase: 0.0];
			[graph moveToPoint:pt2];
			
		}
		else if ([[evt type] isEqual:MBLWakeUpEventType])
		{
			pt2 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
							  (int)(charge + 0.5));
			
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
				[bubbleCanvas lockFocus];
				[self drawImage:[NSImage imageNamed:@"start"]
						atPoint:ipt];
				[bubbleCanvas unlockFocus];
			}
			
			// Allocate a new path
			graph = [[NSBezierPath alloc] init];
			[graph setLineWidth:GRAPH_LINE_WIDTH];
			[graph setLineCapStyle:NSRoundLineCapStyle];
			[graph moveToPoint:pt2];			
		}
		else // if ([[evt type] isEqual:MBLBatteryEventType]) */
			{
				charge = [evt charge];
				isCharging = [evt isCharging];
				isPlugged = [evt isPlugged];
				
				// Skip if nothing changed from previous point
				if ([evt charge] == previousCharge &&
					!(isCharging ^ wasCharging) &&
					!(isPlugged ^ wasPlugged) &&
					i < count - 1) // Always draw last point
				{
					// skip
					continue;
				}
				
				pt2 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
								  (int)(charge + 0.5));
				
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
						NSImage *mark;
						if (isPlugged ^ wasPlugged)
						{
							mark = isPlugged ? [NSImage imageNamed:@"plug"] : [NSImage imageNamed:@"unplug"];
						}
						else
						{
							mark = isCharging ? [NSImage imageNamed:@"charge"] : [NSImage imageNamed:@"chargeover"];
						}
						[bubbleCanvas lockFocus];
						[self drawImage:mark
								atPoint:ipt];
						[bubbleCanvas unlockFocus];
					}
					
					// Allocate a new path
					graph = [[NSBezierPath alloc] init];
					[graph setLineWidth:GRAPH_LINE_WIDTH];
					[graph setLineCapStyle:NSRoundLineCapStyle];
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
	
	// Amperage graph
	if (drawAmperageGraph)
	{
		NSPoint pt1, pt2;
		int amperage, previousAmperage;
		BatteryEvent *evt;
		evt = (BatteryEvent *)[points objectAtIndex:0];
		
		// Set up initial values
		amperage = previousAmperage = 100.0 * ([evt amperage] + maxAmperage) / (2 * maxAmperage);
		
		[NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
		
		NSBezierPath *amperageGraph = [[NSBezierPath alloc] init];
		[amperageGraph setLineWidth:GRAPH_LINE_WIDTH];
		[amperageGraph setLineCapStyle:NSRoundLineCapStyle];
		
		// Creating and draw first point
		pt1 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
						  (int)(previousAmperage + 0.5));
		if (shouldDrawBubbles)
		{
			NSPoint ipt = [scaling transformPoint:pt1];
			ipt.y -= 1;
			[bubbleCanvas lockFocus];
			[self drawImage:[NSImage imageNamed:@"amp_start"]
					atPoint:ipt];
			[bubbleCanvas unlockFocus];
		}
		[amperageGraph moveToPoint:pt1];
		[amperageGraph lineToPoint:pt1];
		
		for (i = 1; i < count; i++)
		{
			evt = (BatteryEvent *)[points objectAtIndex:i];
			
			if ([[evt type] isEqual:MBLSleepEventType])
			{
				pt2 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
								  (int)(amperage + 0.5));
				
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
					[bubbleCanvas lockFocus];
					[self drawImage:[NSImage imageNamed:@"sleep"]
							atPoint:ipt];
					[bubbleCanvas unlockFocus];
				}
				
				// Allocate a new path
				amperageGraph = [[NSBezierPath alloc] init];
				[amperageGraph setLineWidth:GRAPH_LINE_WIDTH];
				[amperageGraph setLineCapStyle:NSButtLineCapStyle];
				[amperageGraph setLineDash:dashedline count: 2 phase: 0.0];
				[amperageGraph moveToPoint:pt2];
			}
			else if ([[evt type] isEqual:MBLWakeUpEventType])
			{
				pt2 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
								  (int)(amperage + 0.5));
				
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
					[bubbleCanvas lockFocus];
					[self drawImage:[NSImage imageNamed:@"amp_start"]
							atPoint:ipt];
					[bubbleCanvas unlockFocus];
				}
				
				// Allocate a new path
				amperageGraph = [[NSBezierPath alloc] init];
				[amperageGraph setLineWidth:GRAPH_LINE_WIDTH];
				[amperageGraph setLineCapStyle:NSRoundLineCapStyle];
				[amperageGraph moveToPoint:pt2];			
			}
			else
			{
				int amp = [evt amperage];
				int abs_amp = abs(amp);
				amperage = 100.0 * (amp + maxAmperage) / (2 * maxAmperage);
				// Vai! Grafico adattivo! ;)
				if (abs_amp > maxAmperageValue)
				{
					[self setMaxAmperageValue:abs_amp];
				}
				
				/* Bug #2: wrong amperage graph
					// Skip if nothing changed from previous point
					if (amperage == previousAmperage &&
						i < count - 1) // Always draw last point
				{
						// skip
						continue;
				}
				*/
				pt2 = NSMakePoint((int)([[evt date] timeIntervalSinceDate:endDate] + 0.5),
								  (int)(amperage + 0.5));
				
				
				previousAmperage = amperage;
			}
			[amperageGraph lineToPoint:pt2];
			pt1 = pt2;
		}
		[amperageColor set];
		[amperageGraph transformUsingAffineTransform:scaling];
		[amperageGraph stroke];
		[amperageGraph release];
	}
	
	if (shouldDrawBubbles)
	{
		[bubbleCanvas drawAtPoint:NSZeroPoint
						 fromRect:rect
						operation:NSCompositeSourceOver
						 fraction:1.0];
		[bubbleCanvas release];	
	}
	
	// Release points when done
	//[points release];
}

// Currently unused
- (void)push:(id)event
{
	NSMutableArray *events = [currentSession events];
	// Add current measure
	[events addObject:event];
	// Remove measures older than HSCALE_MAX seconds
	int i = 0;
	int len = [events count];
	NSDate *endDate = [[events objectAtIndex:([events count] - 1)] date];
	float distance;
	do		
	{
		distance = fabs([[[events objectAtIndex:i] date] timeIntervalSinceDate:endDate]);
		if (distance > HSCALE_MAX)
		{
			[events removeObjectAtIndex:0];
		}
	} while (distance > HSCALE_MAX &&
			 ++i < len);
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

- (NSBezierPath *)amperageGraph
{
	return amperageGraph;
}
- (void)setAmperageGraph:(NSBezierPath *)graph
{
	[graph retain];
	[amperageGraph release];
	amperageGraph = graph;	
}

- (NSBezierPath *)voltageGraph
{
	return voltageGraph;
}
- (void)setVoltageGraph:(NSBezierPath *)graph
{
	[graph retain];
	[voltageGraph release];
	voltageGraph = graph;	
}

- (NSBezierPath *)chargeGraph
{
	return chargeGraph;
}
- (void)setChargeGraph:(NSBezierPath *)graph
{
	[graph retain];
	[chargeGraph release];
	chargeGraph = graph;
}

- (NSMutableArray *)events
{
	return points;
}
- (void)setEvents:(NSMutableArray *)arr
{
	[arr retain];
	[points release];
	points = arr;
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
}


@end

@implementation MBLMainChartView (Private)

- (void)drawImage:(NSImage *)img atPoint:(NSPoint)pt
{
	float w = [img size].width;
	float h = [img size].height;
	NSPoint destPoint = NSMakePoint((int)(pt.x - 0.5 * w),
									(int)(pt.y - 0.5 * GRAPH_LINE_WIDTH));
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
	[self setNeedsDisplay:YES];
}

- (void)updateChartProperties
{
}

@end

@implementation MBLMainChartView (NSMenuValidation)

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