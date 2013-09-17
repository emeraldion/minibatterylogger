//
//  ELSplitView.h
//  MiniBatteryLogger
//
//  Created by delphine on 08-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class ELSplitView
 @abstract Split view resembling the custom control of Apple Mail 2.
 */
@interface ELSplitView : NSSplitView
{
	/*!
	 @var grip
	 @abstract Image representing the central grip of the split separator.
	 */
	NSImage *grip;

	/*!
	 @var bar
	 @abstract Image representing the bar of the split separator.
	 */
	NSImage *bar;
}

@end
