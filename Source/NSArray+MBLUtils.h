//
//  NSArray+MBLUtils.h
//  MiniBatteryLogger
//
//  Created by delphine on 13-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLEvent.h"

/*!
 @category MBLUtils
 @abstract Useful additions to <tt>NSArray</tt> class.
 */
@interface NSArray (MBLUtils)

/*!
 @method meanValue
 @abstract Returns the mean value of the receiver's numeric elements.
 */
- (double)meanValue;

/*!
 @method variance
 @abstract Returns the stochastic variance of the receiver's numeric elements.
 @discussion The receiver must contain only numeric elements.
 */
- (double)variance;

/*!
 @method covariance:
 @abstract Returns the stochastic covariance of the receiver's numeric elements
 and the elements of the array <tt>other</tt>.
 @discussion The receiver and other must have the same size, and contain only
 numeric elements.
 @param other The other numeric array.
 */
- (double)covariance:(NSArray *)other;

/*!
 @method CSVString
 @abstract Returns the elements of the receiver as a CSV row.
 */
- (NSString *)CSVString;

/*!
 @method CSVStringMSExcel
 @abstract Returns the elements of the receiver as a CSV row for MS Excel.
 */
- (NSString *)CSVStringMSExcel;

/*!
 @method arrayDifference:
 @abstract Returns the elements of the receiver that are not contained in <tt>other</tt>.
 @param other The array to subtract.
 @result An array whose elements are the elements of the receiver that are not contained in <tt>other</tt>.
 */
- (NSArray *)arrayDifference:(NSArray *)other;

@end

/*!
 @category RemoveDuplicates
 @abstract Methods to manage duplicate elements in arrays.
 */
@interface NSArray (RemoveDuplicates)

/*!
 @method arrayByRemovingDuplicates
 @abstract Returns an autoreleased NSArray with unique elements from the receiver.
 @discussion Elements are compared using the isEqual: method.
 @result An autoreleased NSArray with unique elements from the receiver.
 */
- (NSArray *)arrayByRemovingDuplicates;

@end

/*!
 @category RemoveDuplicates
 @abstract Methods to manage duplicate elements in arrays.
 */
@interface NSMutableArray (RemoveDuplicates)

/*!
 @method removeDuplicates
 @abstract Removes duplicate elements from the receiver.
 @discussion Elements are compared using the isEqual: method.
 */
- (void)removeDuplicates;

@end
