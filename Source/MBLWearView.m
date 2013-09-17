//
//  MBLWearView.m
//  MiniBatteryLogger
//
//  Created by delphine on 3-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//	Go, Marin K-12, go!
//

#import "MBLWearView.h"

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

#define VSCALE 100.0

#define GRID_HSPACING 6
#define GRID_VSPACING 10

// Time intervals
#define A_DAY 86400.0
#define A_WEEK 604800.0
#define A_MONTH 2592000.0
#define A_YEAR 31536000.0

@interface MBLWearView (Private)

- (void)handlePropertyChange:(NSNotification *)note;
- (void)updateRegressionGraph;
- (void)updateChartProperties;
- (void)drawNoDataWarning:(NSRect)rect;
- (void) copyChartToPasteboard:(NSPasteboard *)pb;
- (NSImage *)drawToImage;

@end

@implementation MBLWearView

- (BOOL)acceptsFirstResponder
{
	return YES;
}

+ (void)initialize
{
	[self exposeBinding:@"snapshots"];
	[self exposeBinding:@"selectedSnapshot"];
	
	/* Registering Standard User Defaults */
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor lightGrayColor]] forKey:MBLChartGridColorKey];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MBLChartBackgroundColorKey];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:defaultValues];
	[defaults synchronize];	
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[gridColor release];
	[backgroundColor release];
	[snapshots release];
	[cycleCountGraph release];
	[maxCapacityGraph release];
	[maxCapacityRegressionGraph release];
	[deathOfBattery release];
	
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartGridColorChangedNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePropertyChange:)
													 name:MBLChartBackgroundColorChangedNotification
												   object:nil];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[self setGridColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartGridColorKey]]];
		[self setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:MBLChartBackgroundColorKey]]];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	int i;
	NSSize gridSize = NSMakeSize(rect.size.width - 2*HPAD,
								 rect.size.height - 2*VPAD);
	NSRect gridClipRect = NSMakeRect(HPAD - 0.5 * GRAPH_LINE_WIDTH,
									 VPAD - 0.5 * GRAPH_LINE_WIDTH,
									 gridSize.width + GRAPH_LINE_WIDTH,
									 gridSize.height + GRAPH_LINE_WIDTH);
	
	// Fill background with backgroundColor
    [backgroundColor set];
	[NSBezierPath fillRect:rect];
	
	if (snapshots == nil ||
		snapshots == [NSNull null] ||
		[snapshots count] == 0)
	{
		// Draw some "No snapshots!" alert string, then return
		[self drawNoDataWarning:NSMakeRect(HPAD, VPAD, gridSize.width, gridSize.height)];
		return;
	}
	
	BatterySnapshot *first, *last;
	NSArray *sorted;
	NSCalendarDate *startDate, *endDate;
	int snapshotsCount;//, snapshotSelection;
	NSImage *cycleCountBulletCanvas,
		*maxCapacityBulletCanvas;
	
	sorted = snapshots;
	snapshotsCount = [snapshots count];

	if (selectedSnapshot != nil)
	{
		cycleCountBulletCanvas = [[NSImage alloc] initWithSize:rect.size];
		maxCapacityBulletCanvas = [[NSImage alloc] initWithSize:rect.size];
	}
	
	first = [sorted objectAtIndex:0];
	startDate = [first date];
	
	last = [sorted objectAtIndex:(snapshotsCount - 1)];
	endDate = [last date];
	
	NSTimeInterval timeInterval = (false && deathOfBattery) ?
		[deathOfBattery timeIntervalSinceDate:startDate] :
		[endDate timeIntervalSinceDate:startDate];
	
	// Trace the axis

	// Set line width for grid
	[NSBezierPath setDefaultLineWidth:0.5];
	// Set the grid color
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
	int hGridSlope = MAX(1, MAX((maxMaxCapacity - minMaxCapacity), (maxCycleCount - minCycleCount)));
	int hGridTicks = MIN(10, hGridSlope);
	
	NSString *label;
	NSSize labelSize, cycBoxSize;

	label = [NSString stringWithFormat:@" %d", maxCycleCount];
	cycBoxSize = [label sizeWithAttributes:fontAttributes];
	int cap, cyc, prevCap, prevCyc;
	for (i = 0; i <= hGridTicks; i++)
	{
		d_y = round(i * gridSize.height / hGridTicks);
		start = NSMakePoint(rect.origin.x + HPAD,
							rect.origin.y + d_y + VPAD + 0.5);
		end = NSMakePoint(rect.origin.x + gridSize.width + HPAD,
						  rect.origin.y + d_y + VPAD + 0.5);
		[NSBezierPath strokeLineFromPoint:start
								  toPoint:end];

		// Vertical gauge marks
		cap = (int)(minMaxCapacity + (1.0 * i / hGridTicks) * (maxMaxCapacity - minMaxCapacity) + 0.5);
		if (cap != prevCap)
		{
			label = [NSString stringWithFormat:@"%4d ", cap];
			labelSize = [label sizeWithAttributes:fontAttributes];
			[label drawAtPoint:NSMakePoint(start.x - labelSize.width,
										   start.y - 0.5 * labelSize.height)
				withAttributes:fontAttributes];
			prevCap = cap;
		}
		
		cyc = (int)(minCycleCount + (1.0 * i / hGridTicks) * (maxCycleCount - minCycleCount) + 0.5);
		if (cyc != prevCyc)
		{
			label = [NSString stringWithFormat:@"%d", cyc];
			labelSize = [label sizeWithAttributes:fontAttributes];
			[label drawAtPoint:NSMakePoint(start.x + gridSize.width + cycBoxSize.width - labelSize.width + 0.5,
										   start.y - 0.5 * labelSize.height)
				withAttributes:fontAttributes];
			prevCyc = cyc;
		}
	}
	
	// Vertical grid
	float timeLeap;
	// Set the time interval between two vertical lines
	// as the time interval immediately smaller
	if (timeInterval <= A_WEEK)
	{
		timeLeap = A_DAY;
	}
	else if (timeInterval <= A_MONTH)
	{
		timeLeap = A_WEEK;
	}
	else if (timeInterval <= A_YEAR)
	{
		timeLeap = A_MONTH;
	}
	else
	{
		timeLeap = A_YEAR;
	}
	int timeSlices = MAX(1, (timeInterval / timeLeap));
	for (i = 0; i <= timeSlices; i++)
	{
		d_x = round((1 - timeLeap * i / MAX(1, timeInterval)) * gridSize.width);
		start = NSMakePoint(rect.origin.x + d_x + HPAD + 0.5,
							rect.origin.y + VPAD);
		end = NSMakePoint(rect.origin.x + d_x + HPAD + 0.5,
						  rect.origin.y + gridSize.height + VPAD + 0.5);
		[NSBezierPath strokeLineFromPoint:start
								  toPoint:end];		
		
		NSCalendarDate *labelDate;
		labelDate = [[NSCalendarDate alloc] initWithTimeInterval:(-i * timeLeap) sinceDate:endDate];
		label = [labelDate descriptionWithCalendarFormat:@"%e/%m"];
		labelSize = [label sizeWithAttributes:fontAttributes];
		[label drawAtPoint:NSMakePoint(rect.origin.x + HPAD + d_x - 0.5 * labelSize.width + 0.5,
									   rect.origin.y + VPAD - 1.5 * labelSize.height)
			withAttributes:fontAttributes];	
		[labelDate release];
	}
	// Draw left border
	start = NSMakePoint(rect.origin.x + HPAD + 0.5,
						rect.origin.y + VPAD);
	end = NSMakePoint(rect.origin.x + HPAD + 0.5,
					  rect.origin.y + gridSize.height + VPAD + 0.5);
	[NSBezierPath strokeLineFromPoint:start
							  toPoint:end];		
	
	
	
	NSAffineTransform *cycleCountTransform = [NSAffineTransform transform],
		*maxCapacityTransform = [NSAffineTransform transform];
	
	[cycleCountTransform translateXBy:HPAD
								  yBy:VPAD];
	[cycleCountTransform scaleXBy:(1.0 * gridSize.width / MAX(1, timeInterval))
							  yBy:(1.0 * gridSize.height / MAX(1, (maxCycleCount - minCycleCount)))];
	
	[maxCapacityTransform translateXBy:HPAD
								   yBy:VPAD];
	[maxCapacityTransform scaleXBy:(1.0 * gridSize.width / MAX(1, timeInterval))
							   yBy:(1.0 * gridSize.height / MAX(1, (maxMaxCapacity - minMaxCapacity)))];	
	
	NSPoint selectionCycleCountPoint,
		selectionMaxCapacityPoint;
	// Add other points (if present)
	Battery *selectedBattery;
	NSTimeInterval selectedDate;
	if (selectedSnapshot != nil)
	{
		selectedBattery = [selectedSnapshot battery];
		selectedDate = [[selectedSnapshot date] timeIntervalSinceDate:[[sorted objectAtIndex:0] date]];
		
		selectionCycleCountPoint = [cycleCountTransform transformPoint:NSMakePoint(selectedDate, [selectedBattery cycleCount] - minCycleCount)];
		selectionMaxCapacityPoint = [maxCapacityTransform transformPoint:NSMakePoint(selectedDate, [selectedBattery maxCapacity] - minMaxCapacity)];
		
		// Draw bullet for selected Cycle Count
		NSBezierPath *cycleCountBullet = [NSBezierPath bezierPath];
		[cycleCountBullet setLineWidth:GRAPH_LINE_WIDTH];
		NSRect cycleCountBulletRect = NSMakeRect(selectionCycleCountPoint.x - 4,
												 selectionCycleCountPoint.y - 4,
												 8,
												 8);
		[cycleCountBullet appendBezierPathWithOvalInRect:cycleCountBulletRect];
		[cycleCountBulletCanvas lockFocus]; {
			[backgroundColor set];
			[cycleCountBullet fill];
			[[NSColor blueColor] set];
			[cycleCountBullet stroke];
		} [cycleCountBulletCanvas unlockFocus];
		
		// Draw bullet for selected Max Capacity
		NSBezierPath *maxCapacityBullet = [NSBezierPath bezierPath];
		[maxCapacityBullet setLineWidth:GRAPH_LINE_WIDTH];
		NSRect maxCapacityBulletRect = NSMakeRect(selectionMaxCapacityPoint.x - 4,
												  selectionMaxCapacityPoint.y - 4,
												  8,
												  8);
		[maxCapacityBullet appendBezierPathWithOvalInRect:maxCapacityBulletRect];
		[maxCapacityBulletCanvas lockFocus]; {
			[backgroundColor set];
			[maxCapacityBullet fill];
			[[NSColor redColor] set];
			[maxCapacityBullet stroke];
		} [maxCapacityBulletCanvas unlockFocus];			
	}
	
	// Stroke graphs

	// Restrain drawing to the grid area
	[NSGraphicsContext saveGraphicsState]; {
		[NSBezierPath clipRect:gridClipRect];
		
		// Allocate temp paths for transforms
		NSBezierPath *capGraph, *cycGraph, *regGraph;
		
		// A nice blue for the Cycle Count
		[[NSColor blueColor] set];
		cycGraph = [cycleCountGraph copy];
		[cycGraph transformUsingAffineTransform:cycleCountTransform];
		[cycGraph stroke];
		[cycGraph release];
		
		// Capacity regression line
		[[NSColor orangeColor] set];
		regGraph = [maxCapacityRegressionGraph copy];
		[regGraph transformUsingAffineTransform:maxCapacityTransform];
		[regGraph stroke];
		[regGraph release];

		// A brilliant red for the Capacity
		[[NSColor redColor] set];
		capGraph = [maxCapacityGraph copy];
		[capGraph transformUsingAffineTransform:maxCapacityTransform];
		[capGraph stroke];
		[capGraph release];		
	
	} [NSGraphicsContext restoreGraphicsState];
	
	if (selectedSnapshot != nil)
	{
		// Draw cycle count canvas with bullet
		[cycleCountBulletCanvas drawAtPoint:NSZeroPoint
								   fromRect:NSMakeRect(0,
													   0,
													   [cycleCountBulletCanvas size].width, 
													   [cycleCountBulletCanvas size].height)
								  operation:NSCompositeSourceOver
								   fraction:1.0];
		[cycleCountBulletCanvas release];
		
		// Draw max capacity canvas with bullet
		[maxCapacityBulletCanvas drawAtPoint:NSZeroPoint
									fromRect:NSMakeRect(0,
														0,
														[maxCapacityBulletCanvas size].width, 
														[maxCapacityBulletCanvas size].height)
								   operation:NSCompositeSourceOver
									fraction:1.0];
		[maxCapacityBulletCanvas release];		
	}
	[fontAttributes release];
}

#pragma mark === Accessors ===

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

- (NSBezierPath *)maxCapacityGraph
{
	return maxCapacityGraph;
}
- (void)setMaxCapacityGraph:(NSBezierPath *)graph
{
	[graph retain];
	[maxCapacityGraph release];
	maxCapacityGraph = graph;
}
- (NSBezierPath *)cycleCountGraph
{
	return cycleCountGraph;
}
- (void)setCycleCountGraph:(NSBezierPath *)graph
{
	[graph retain];
	[cycleCountGraph release];
	cycleCountGraph = graph;
}

- (NSBezierPath *)maxCapacityRegressionGraph
{
	return maxCapacityRegressionGraph;
}
- (void)setMaxCapacityRegressionGraph:(NSBezierPath *)graph
{
	[graph retain];
	[maxCapacityRegressionGraph release];
	maxCapacityRegressionGraph = graph;	
}

- (NSCalendarDate *)deathOfBattery
{
	return deathOfBattery;
}
- (void)setDeathOfBattery:(NSCalendarDate *)dateOfDeath
{
	[dateOfDeath retain];
	[deathOfBattery release];
	deathOfBattery = dateOfDeath;
}

- (NSArray *)snapshots
{
	return snapshots;
}

- (void)setSnapshots:(NSArray *)shots
{
#pragma unused (shots)

	// Here we are interested in the actual content of snapshotsController
	NSArray *_shots = [snapshotsController content];

	[_shots retain];
	[snapshots release];
	snapshots = _shots;
	
	if (snapshots &&
		[snapshots count] > 0)
	{
		// Update chart properties
		[self updateChartProperties];
		
		// Update regression graph
		[self updateRegressionGraph];
		
	}
	// Invoke redrawing
	[self setNeedsDisplay:YES];
}

- (id)selectedSnapshot
{
	return selectedSnapshot;
}
- (void)setSelectedSnapshot:(id)sel
{
	[sel retain];
	[selectedSnapshot release];
	selectedSnapshot = sel;
	

	// Update chart properties
	[self updateChartProperties];
	
	// Update regression graph
	[self updateRegressionGraph];

	// Invoke redrawing
	[self setNeedsDisplay:YES];
}

- (IBAction)copy:(id)sender
{
	[self copyChartToPasteboard:[NSPasteboard generalPasteboard]];
}

@end

@implementation MBLWearView (Private)

- (void) copyChartToPasteboard:(NSPasteboard *)pb
{
	NSImage *anImage;
	
	anImage = [self drawToImage];
	
	// Put the image to the pasteboard
	[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];
	[pb setData:[anImage TIFFRepresentation] forType:NSTIFFPboardType];
}

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

- (void)handlePropertyChange:(NSNotification *)note
{
	id sender = [note object];
	NSString *name = [note name];
	if ([name isEqual:MBLChartGridColorChangedNotification])
	{
		[self setGridColor:[sender gridColor]];
	}
	else if ([name isEqual:MBLChartBackgroundColorChangedNotification])
	{
		[self setBackgroundColor:[sender backgroundColor]];
	}
	[self setNeedsDisplay:YES];
}

- (void)updateRegressionGraph
{
	NSMutableArray *times, *capacities;	
	BatterySnapshot *snapshot;
	NSCalendar *startDate;
	NSArray *sorted;
	int i, len;
	
	len = [snapshots count];
	if (len < 1)
	{
		return;
	}
	sorted = [snapshots sortedArrayUsingSelector:@selector(compareSnapshotDateAscending:)];
	times = [NSMutableArray arrayWithCapacity:len];
	capacities = [NSMutableArray arrayWithCapacity:len];
	startDate = [[sorted objectAtIndex:0] date];
	for (i = 0; i < len; i++)
	{
		snapshot = [sorted objectAtIndex:i];
		[capacities insertObject:[NSNumber numberWithInt:[[snapshot battery] maxCapacity]]
						 atIndex:i];
		[times insertObject:[NSNumber numberWithInt:[[snapshot date] timeIntervalSinceDate:startDate]]
					atIndex:i];
	}
	
	double variance, covariance, xMean, yMean;
	xMean = [times meanValue];
	yMean = [capacities meanValue];
	variance = [times variance];
	covariance = [times covariance:capacities];

	double b = covariance / variance;
	double a = yMean - xMean * b;

	// Estimate the date of the death of the battery (maxCapacity == 0)
	NSCalendarDate *death;
	death = (b < 0) ? [[[NSCalendarDate alloc] initWithTimeInterval:(-a / b) sinceDate:startDate] autorelease] : nil;
	[self setDeathOfBattery:death];
	
	NSBezierPath *regressionGraph = [NSBezierPath bezierPath];
	
	BatterySnapshot *first, *last;
	NSTimeInterval lastDate;
	
	first = [sorted objectAtIndex:0];
	last = [sorted objectAtIndex:len - 1];

	lastDate = (false && deathOfBattery != nil) ?
		[deathOfBattery timeIntervalSinceDate:startDate] :
		[[last date] timeIntervalSinceDate:startDate];
	
	[regressionGraph moveToPoint:NSMakePoint(0, (a - minMaxCapacity))];
	[regressionGraph lineToPoint:NSMakePoint(lastDate, ((a + b * lastDate) - minMaxCapacity))];

	// Float array for dashed lines
	float dashedline[2];
	dashedline[0] = 6.0; //segment painted with stroke color
	dashedline[1] = 4.0; //segment not painted with a color
	
	[regressionGraph setLineDash:dashedline count: 2 phase: 0.0];
	[regressionGraph setLineWidth:GRAPH_LINE_WIDTH];
	[regressionGraph setLineCapStyle:NSButtLineCapStyle];

	[self setMaxCapacityRegressionGraph:regressionGraph];
}

- (void)updateChartProperties
{
	int snapshotsCount, i;
	NSArray *sorted;
	
	snapshotsCount = [snapshots count];
	if (!snapshotsCount)
	{
		return;
	}
	
	// Get the four extremes sorting convenience copies of the snapshots array
	sorted = [snapshots sortedArrayUsingSelector:@selector(compareSnapshotCycleCountAscending:)];
	minCycleCount = [[[sorted objectAtIndex:0] battery] cycleCount];
		
	sorted = [snapshots sortedArrayUsingSelector:@selector(compareSnapshotCycleCountDescending:)];
	maxCycleCount = [[[sorted objectAtIndex:0] battery] cycleCount];
	
	sorted = [snapshots sortedArrayUsingSelector:@selector(compareSnapshotMaxCapacityAscending:)];
	minMaxCapacity = [[[sorted objectAtIndex:0] battery] maxCapacity];
	
	sorted = [snapshots sortedArrayUsingSelector:@selector(compareSnapshotMaxCapacityDescending:)];
	maxMaxCapacity = [[[sorted objectAtIndex:0] battery] maxCapacity];
	
	NSBezierPath *cycGraph,
		*capGraph;
	
	// Create autoreleased objects
	cycGraph = [NSBezierPath bezierPath];
	capGraph = [NSBezierPath bezierPath];
	
	// Set path properties
	[cycGraph setLineWidth:GRAPH_LINE_WIDTH];
	[cycGraph setLineCapStyle:NSRoundLineCapStyle];
	[cycGraph setLineJoinStyle:NSRoundLineJoinStyle];
	
	[capGraph setLineWidth:GRAPH_LINE_WIDTH];
	[capGraph setLineCapStyle:NSRoundLineCapStyle];
	[capGraph setLineJoinStyle:NSRoundLineJoinStyle];
	
	// Add points
	BatterySnapshot *current;
	NSCalendarDate *startDate;
	NSTimeInterval currDate;
	
	sorted = [snapshots sortedArrayUsingSelector:@selector(compareSnapshotDateAscending:)];
	startDate = [[sorted objectAtIndex:0] date];
	for (i = 0; i < snapshotsCount; i++)
	{
		current = [sorted objectAtIndex:i];
		if (i == 0)
		{
			[cycGraph moveToPoint:NSMakePoint(0, ([[current battery] cycleCount] - minCycleCount))];
			[capGraph moveToPoint:NSMakePoint(0, ([[current battery] maxCapacity] - minMaxCapacity))];
		}
		else
		{
			currDate = [[current date] timeIntervalSinceDate:startDate];
			[cycGraph lineToPoint:NSMakePoint(currDate, ([[current battery] cycleCount] - minCycleCount))];
			[capGraph lineToPoint:NSMakePoint(currDate, ([[current battery] maxCapacity] - minMaxCapacity))];
		}
	}
	if (snapshotsCount == 1)
	{
		[cycGraph lineToPoint:NSZeroPoint];
		[capGraph lineToPoint:NSZeroPoint];
	}

	// Store graphs
	[self setMaxCapacityGraph:capGraph];
	[self setCycleCountGraph:cycGraph];
}

- (void)drawNoDataWarning:(NSRect)rect
{
	NSString *warningLabel;
	NSSize warningLabelSize;
	
	NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
	[fontAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											  size:24.0]
					   forKey:NSFontAttributeName];
	[fontAttributes setObject:gridColor
					   forKey:NSForegroundColorAttributeName];
	
	warningLabel = NSLocalizedString(@"No Snapshots", @"No Snapshots");
	warningLabelSize = [warningLabel sizeWithAttributes:fontAttributes];
	
	[warningLabel drawAtPoint:NSMakePoint(NSMidX(rect) - 0.5 * warningLabelSize.width,
								   NSMidY(rect) - 0.5 * warningLabelSize.height)
		withAttributes:fontAttributes];
	
	[fontAttributes release];
}

- (void)mouseDown:(NSEvent *)event
{
	BOOL keepOn = YES;
	NSEvent *theEvent;
	
	while (keepOn) {
		theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
			NSLeftMouseDraggedMask];
		switch ([theEvent type]) {
			case NSLeftMouseDragged:
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
				p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				
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
				keepOn = NO;
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

@end

@implementation MBLWearView (NSDraggingSource)

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
#pragma unused (isLocal)
	return NSDragOperationCopy;
}

/*
- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
	NSLog(@"draggedImage:movedTo: (%f,%f)", screenPoint.x, screenPoint.y);
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	NSLog(@"draggedImage:endedAt:operation: (%f,%f)", aPoint.x, aPoint.y);
}
*/

@end

@implementation MBLWearView (NSNibAwaking)

- (void)awakeFromNib
{
	[self bind:@"snapshots"
	  toObject:snapshotsController
   withKeyPath:@"arrangedObjects"
	   options:nil];

	[self bind:@"selectedSnapshot"
	  toObject:snapshotsController
   withKeyPath:@"selection.self" // The heck of a hack??
	   options:nil];
}

@end