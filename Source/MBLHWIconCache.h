//
//  MBLHWIconCache.h
//  MiniBatteryLogger
//
//  Created by delphine on 18-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class MBLHWIconCache
 @abstract Cache for hardware icons.
 @discussion Objects of this class serve as a cache for images, representing hardware models,
 that are frequently accessed, according to an internal hardware to image translation dictionary.
 */
@interface MBLHWIconCache : NSObject {

}

/*!
 @method imageForModel:
 @abstract Returns an image representing the desired hardware model.
 @param model The desired hardware model.
 @result An image representing the desired hardware model.
 */
+ (NSImage *)imageForModel:(NSString *)model;

@end
