//
//  MBLAction.h
//  MiniBatteryLogger
//
//  Created by delphine on 22-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class MBLAction
 @abstract Objects of class <tt>MBLAction</tt> represent an abstract action to be performed
 when certain power conditions are met.
 */
@interface MBLAction : NSObject <NSCoding> {
	/*!
	 @var _params
	 @abstract Parameters defining the behavior of the action.
	 */
	NSMutableDictionary *_params;
}

/*!
 @method isApplicable
 @abstract Checks if the action is applicable.
 @result Returns <tt>YES</tt> if the action is applicable.
 */
- (BOOL)isApplicable;

/*!
 @method perform
 @abstract Requests the action to be performed.
 */
- (void)perform;

/*!
 @method performIfApplicable
 @abstract Requests the action to be performed only if applicable.
 @result Returns <tt>YES</tt> if the action has been performed.
 */
- (BOOL)performIfApplicable;

/*!
 @method setParams:
 @abstract Sets the parameters defining the action.
 @params A dictionary of parameters.
 */
- (void)setParams:(NSDictionary *)params;

/*!
 @method params
 @abstract Returns the parameters defining the action.
 @result The parameters defining the action.
 */
- (NSDictionary *)params;

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4

/*!
 @method setPredicate
 @abstract Sets a predicate that determines if the action should be performed.
 @param predicate A predicate that evaluates to <tt>YES</tt> in order to perform the action.
 */
- (void)setPredicate:(NSPredicate *)predicate;

/*!
 @method predicate
 @abstract Returns a predicate that determines if the action should be performed.
 @result A predicate that determines if the action should be performed.
 */
- (NSPredicate *)predicate;

#endif

@end
