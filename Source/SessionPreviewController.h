//
//  SessionPreviewController.h
//  MiniBatteryLogger
//
//  Created by delphine on 11-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MiniChartView.h"

@interface SessionPreviewWindow : NSWindow {
	float opacity;
}

@end

@interface SessionPreviewController : NSWindowController {
@private
	BOOL dismissing;
	IBOutlet MiniChartView *chartView;
	/* weak reference */
	NSArrayController *sessionsController;
}

- (void)setSessionsController:(NSArrayController *)controller;

/*!
 @method dismissWindow:
 @abstract Requests that the window of the controller be dismissed gradually reducing its opacity.
 */
- (IBAction)dismissWindow:(id)sender;

@end

@interface SessionPreviewContentView : NSView {
@private
	BOOL positionInitialized;
	NSPoint mostRecentPoint;
	NSRect theScreen;	
}

@end