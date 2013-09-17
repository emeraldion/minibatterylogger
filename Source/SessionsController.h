//
//  SessionsController.h
//  MiniBatteryLogger
//
//  Created by delphine on 6-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class SessionsController
 @abstract <tt>NSArrayController</tt> subclass that manages an array of <tt>MonitoringSession</tt> objects.
 */
@interface SessionsController : NSArrayController {

}

/*!
 @method canRemoveArrangedObjectAtIndex:
 @abstract Checks if the receiver can remove the arranged object at the desired position.
 @discussion This is an extension to <tt>-(BOOL)canRemove</tt> in order to query
 directly if an item can be removed
 @param index The position of the item to remove.
 @result <tt>YES</tt> if the item can be removed, <tt>NO</tt> otherwise.
 */
- (BOOL)canRemoveArrangedObjectAtIndex:(int)index;

/*!
 @method canRemoveAll
 @abstract Checks if the receiver can remove all the arranged objects.
 @discussion This method returns <tt>YES</tt> only if the array controller contains
 at lease one sessions that is not active.
 @result <tt>YES</tt> if all the items can be removed, <tt>NO</tt> otherwise.
 */
- (BOOL)canRemoveAll;

@end
