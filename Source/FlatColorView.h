//
//  FlatColorView.h
//  MiniBatteryLogger
//
//  Created by delphine on 3-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class FlatColorView
 @abstract Simple NSView subclass with a flat background color.
 */
@interface FlatColorView : NSView {

	/*!
	 @var bgcolor
	 @abstract The background color for the view.
	 */
	NSColor *bgcolor;
}

@end
