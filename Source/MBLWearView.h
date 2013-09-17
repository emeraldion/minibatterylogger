//
//  MBLWearView.h
//  MiniBatteryLogger
//
//  Created by delphine on 3-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//	Go, Marin K-12, go!
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"
#import "BatterySnapshot.h"
#import "NSArray+MBLUtils.h"

extern NSString *MBLChartBackgroundColorKey;
extern NSString *MBLChartGridColorKey;

extern NSString *MBLChartBackgroundColorChangedNotification;
extern NSString *MBLChartGridColorChangedNotification;

@interface MBLWearView : NSView {

	IBOutlet NSArrayController *snapshotsController;
	NSColor *gridColor;
	NSColor *backgroundColor;
	NSArray *snapshots;
	//int selectedSnapshot;
	id selectedSnapshot;
	int minCycleCount;
	int maxCycleCount;
	int minMaxCapacity;
	int maxMaxCapacity;
	NSBezierPath *maxCapacityGraph;
	NSBezierPath *cycleCountGraph;	
	NSBezierPath *maxCapacityRegressionGraph;
	NSCalendarDate *deathOfBattery;
}

- (IBAction)copy:(id)sender;

- (NSColor *)gridColor;
- (void)setGridColor:(NSColor *)aColor;
- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aColor;

- (NSBezierPath *)maxCapacityGraph;
- (void)setMaxCapacityGraph:(NSBezierPath *)graph;
- (NSBezierPath *)cycleCountGraph;
- (void)setCycleCountGraph:(NSBezierPath *)graph;
- (NSBezierPath *)maxCapacityRegressionGraph;
- (void)setMaxCapacityRegressionGraph:(NSBezierPath *)graph;
- (NSCalendarDate *)deathOfBattery;
- (void)setDeathOfBattery:(NSCalendarDate *)dateOfDeath;

- (NSArray *)snapshots;
- (void)setSnapshots:(NSArray *)shots;
- (id)selectedSnapshot;
- (void)setSelectedSnapshot:(id)sel;

@end
