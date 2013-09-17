//
//  Battery+XML.h
//  MiniBatteryLogger
//
//  Created by delphine on 14-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"

/*!
 @category XML
 @abstract Adds XML manipulation and exporting capabilities to class Battery.
 */
@interface Battery (XML)

/*!
 @method xmlDescription
 @abstract Returns an XML description of the receiver.
 */
- (NSString *)xmlDescription;

@end
