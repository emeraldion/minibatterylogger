//
//  MBLMainChartView.h
//  MiniBatteryLogger
//
//  Created by delphine on 14-10-2006.
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
extern NSString *MBLChartShouldDrawBubblesKey;
extern NSString *MBLChartDrawAmperageGraphKey;

extern NSString *MBLChartBackgroundColorChangedNotification;
extern NSString *MBLChartChargingColorChangedNotification;
extern NSString *MBLChartPluggedColorChangedNotification;
extern NSString *MBLChartUnpluggedColorChangedNotification;
extern NSString *MBLChartGridColorChangedNotification;
extern NSString *MBLChartAmperageColorChangedNotification;
extern NSString *MBLChartShouldDrawBubblesChangedNotification;
extern NSString *MBLChartDrawAmperageGraphNotification;

@interface MBLMainChartView : NSView {
	
	IBOutlet NSArrayController *eventsController;
	
	MonitoringSession *currentSession;
	NSMutableArray *points;
	NSColor *pluggedColor;
	NSColor *unpluggedColor;
	NSColor *chargingColor;
	NSColor *gridColor;
	NSColor *backgroundColor;
	NSColor *amperageColor;
	BOOL shouldDrawBubbles;
	BOOL drawAmperageGraph;
	
	float hScale;
	int hOffset;
	int maxAmperageValue;
	
	NSBezierPath *amperageGraph;
	NSBezierPath *voltageGraph;
	NSBezierPath *chargeGraph;
}

- (void)push:(id)value;

- (BOOL)canZoomIn;
- (BOOL)canZoomOut;
- (BOOL)canShiftLeft;
- (BOOL)canShiftRight;

- (int)maxAmperageValue;
- (void)setMaxAmperageValue:(int)newVal;

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
- (BOOL)shouldDrawBubbles;
- (void)setShouldDrawBubbles:(BOOL)draw;
- (BOOL)drawAmperageGraph;
- (void)setDrawAmperageGraph:(BOOL)draw;

- (NSBezierPath *)amperageGraph;
- (void)setAmperageGraph:(NSBezierPath *)graph;
- (NSBezierPath *)voltageGraph;
- (void)setVoltageGraph:(NSBezierPath *)graph;
- (NSBezierPath *)chargeGraph;
- (void)setChargeGraph:(NSBezierPath *)graph;

- (NSMutableArray *)events;
- (void)setEvents:(NSMutableArray *)arr;
- (MonitoringSession *)currentSession;
- (void)setCurrentSession:(MonitoringSession *)session;

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

- (IBAction)shiftLeft:(id)sender;
- (IBAction)shiftRight:(id)sender;

@end

@interface MBLMainChartView (NSMenuValidation)

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;

@end