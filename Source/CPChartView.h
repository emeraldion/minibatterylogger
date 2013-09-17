//
//  CPChartView.h
//  MiniBatteryLogger
//
//  Created by delphine on 26-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryEvent.h"
#import "SleepEvent.h"
#import "WakeUpEvent.h"
#import "NSString+MBLUtils.h"
#import "MonitoringSession.h"

extern NSString *MBLChartBackgroundColorKey;
extern NSString *MBLChartChargingColorKey;
extern NSString *MBLChartPluggedColorKey;
extern NSString *MBLChartUnpluggedColorKey;
extern NSString *MBLChartGridColorKey;
extern NSString *MBLChartAmperageColorKey;
extern NSString *MBLChartVoltageColorKey;

extern NSString *MBLChartShouldDrawBubblesKey;
extern NSString *MBLChartShouldDrawSleepKey;
extern NSString *MBLChartDrawAmperageGraphKey;
extern NSString *MBLChartDrawVoltageGraphKey;

extern NSString *MBLChartBackgroundColorChangedNotification;
extern NSString *MBLChartChargingColorChangedNotification;
extern NSString *MBLChartPluggedColorChangedNotification;
extern NSString *MBLChartUnpluggedColorChangedNotification;
extern NSString *MBLChartGridColorChangedNotification;
extern NSString *MBLChartAmperageColorChangedNotification;
extern NSString *MBLChartVoltageColorChangedNotification;

extern NSString *MBLChartShouldDrawBubblesChangedNotification;
extern NSString *MBLChartDrawAmperageGraphNotification;
extern NSString *MBLChartDrawVoltageGraphNotification;

enum {
	MBLNoSelectedEvent = -1
};

@interface CPChartView : NSView {
	
	IBOutlet NSObjectController *eventController;

	MonitoringSession *currentSession;
	NSMutableArray *events;
	NSColor *pluggedColor;
	NSColor *unpluggedColor;
	NSColor *chargingColor;
	NSColor *gridColor;
	NSColor *backgroundColor;
	NSColor *amperageColor;
	NSColor *voltageColor;
	BOOL shouldDrawBubbles;
	BOOL drawAmperageGraph;
	BOOL drawVoltageGraph;
	BOOL useFancyScaleColors;
	
	float hScale;
	int hOffset;
	int maxAmperageValue;
	int maxVoltageValue;
	int selectedEventIndex;
	BOOL selectionTracksLastPoint;
	
	float vPad;
	float hPad;
	float graphLineWidth;
	
	BOOL drawScales;

	NSRect gridRect;
	NSAffineTransform *directTransform;
	NSAffineTransform *inverseTransform;
	
	IBOutlet NSPanel *balloon;
}

- (BOOL)canZoomIn;
- (BOOL)canZoomOut;
- (BOOL)canShiftLeft;
- (BOOL)canShiftRight;

- (int)maxAmperageValue;
- (void)setMaxAmperageValue:(int)newVal;
- (int)maxVoltageValue;
- (void)setMaxVoltageValue:(int)newVal;

- (NSColor *)pluggedColor;
- (void)setPluggedColor:(NSColor *)aColor;
- (NSColor *)unpluggedColor;
- (void)setUnpluggedColor:(NSColor *)aColor;
- (NSColor *)chargingColor;
- (void)setChargingColor:(NSColor *)aColor;
- (NSColor *)gridColor;
- (void)setGridColor:(NSColor *)aColor;
- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aColor;
- (NSColor *)amperageColor;
- (void)setAmperageColor:(NSColor *)aColor;
- (NSColor *)voltageColor;
- (void)setVoltageColor:(NSColor *)aColor;

- (BOOL)shouldDrawBubbles;
- (void)setShouldDrawBubbles:(BOOL)draw;
- (BOOL)drawAmperageGraph;
- (void)setDrawAmperageGraph:(BOOL)draw;
- (BOOL)drawVoltageGraph;
- (void)setDrawVoltageGraph:(BOOL)draw;

- (NSAffineTransform *)directTransform;
- (NSAffineTransform *)inverseTransform;
- (void)setDirectTransform:(NSAffineTransform *)transf;

- (NSMutableArray *)events;
- (void)setEvents:(NSMutableArray *)arr;
- (MonitoringSession *)currentSession;
- (void)setCurrentSession:(MonitoringSession *)session;

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)zoomToFit:(id)sender;

- (IBAction)shiftLeft:(id)sender;
- (IBAction)shiftRight:(id)sender;

/* Causes a selection to be created regardlessly */
- (IBAction)forceSelection:(id)sender;
/* Toggles the "track last point" mode on/off */
- (IBAction)toggleSelectionTracksLastPoint:(id)sender;

- (IBAction)copy:(id)sender;

@end

@interface CPChartView (NSMenuValidation)

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;

@end