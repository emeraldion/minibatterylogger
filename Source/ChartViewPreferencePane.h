//
//  ChartViewPreferencePane.h
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLPreferencePane.h"

extern NSString *MBLChartBackgroundColorKey;
extern NSString *MBLChartChargingColorKey;
extern NSString *MBLChartPluggedColorKey;
extern NSString *MBLChartUnpluggedColorKey;
extern NSString *MBLChartAmperageColorKey;
extern NSString *MBLChartVoltageColorKey;
extern NSString *MBLChartGridColorKey;

extern NSString *MBLChartShouldDrawBubblesKey;
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
extern NSString *MBLChartDrawAmperageGraphChangedNotification;
extern NSString *MBLChartDrawVoltageGraphChangedNotification;

@interface ChartViewPreferencePane : MBLPreferencePane {

	IBOutlet NSColorWell *backgroundColorWell;
	IBOutlet NSColorWell *gridColorWell;
	IBOutlet NSColorWell *pluggedColorWell;
	IBOutlet NSColorWell *unpluggedColorWell;
	IBOutlet NSColorWell *chargingColorWell;
	IBOutlet NSColorWell *amperageColorWell;
	IBOutlet NSColorWell *voltageColorWell;

	IBOutlet NSButton *drawBubbles;
	IBOutlet NSButton *drawAmperageGraph;
	IBOutlet NSButton *drawVoltageGraph;
}

- (NSColor *)backgroundColor;
- (NSColor *)gridColor;
- (NSColor *)pluggedColor;
- (NSColor *)unpluggedColor;
- (NSColor *)chargingColor;
- (NSColor *)amperageColor;
- (NSColor *)voltageColor;

- (BOOL)shouldDrawBubbles;
- (BOOL)drawAmperageGraph;
- (BOOL)drawVoltageGraph;

- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeGridColor:(id)sender;
- (IBAction)changePluggedColor:(id)sender;
- (IBAction)changeUnpluggedColor:(id)sender;
- (IBAction)changeChargingColor:(id)sender;
- (IBAction)changeAmperageColor:(id)sender;
- (IBAction)changeVoltageColor:(id)sender;

- (IBAction)changeDrawBubbles:(id)sender;
- (IBAction)changeDrawAmperageGraph:(id)sender;
- (IBAction)changeDrawVoltageGraph:(id)sender;

- (NSColor *)colorForKey:(NSString *)key;
- (void)changeColor:(id)sender forKey:(NSString *)key notification:(NSString *)notif;

@end
