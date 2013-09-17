//
//  DesktopBatteryController.h
//  MiniBatteryLogger
//
//  Created by delphine on 18-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"

@interface DesktopBatteryWindow : NSWindow {
}

@end

@interface DesktopBatteryContentView : NSImageView {
	
	Battery *_battery;
	
	BOOL positionInitialized;
	NSPoint mostRecentPoint;
	NSRect theScreen;	
}

@end

@interface DesktopBatteryController : NSWindowController {

	IBOutlet DesktopBatteryContentView *batteryImage;
	//IBOutlet NSTextField *captionText;
	NSObjectController *_controller;
}

- (id)initWithController:(NSObjectController *)controller;
- (void)setBatteryController:(NSObjectController *)batteryController;

@end

@interface ShadowedTextFieldCell : NSTextFieldCell {
	/*
	float blurRadius;
	NSSize shadowOffset;
	NSColor *shadowColor;
	 */
}

@end