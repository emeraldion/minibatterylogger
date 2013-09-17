//
//  MBLLaunchApplicationAction.h
//  MiniBatteryLogger
//
//  Created by delphine on 22-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLAction.h"

/*!
@class MBLLaunchApplicationAction
@abstract Action that launches an application.
*/
@interface MBLLaunchApplicationAction : MBLAction {

}

/*!
 @method setApplication:
 @abstract Sets the application that will be launched.
 @param appName The name of the application.
 */
- (void)setApplication:(NSString *)appName;

/*!
 @method application
 @abstract Returns the application that will be launched.
 @result The application that will be launched.
 */
- (NSString *)application;

@end
