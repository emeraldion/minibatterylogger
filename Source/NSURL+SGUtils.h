//
//  NSURL+SGUtils.h
//  Singular
//
//  Created by delphine on 19-02-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @category SGUtils
 @abstract Miscellaneous additions to the <tt>NSURL</tt> class.
 */
@interface NSURL (SGUtils)

/*!
 @method URLWithFormat:
 @abstract Returns a <tt>NSURL</tt> object with a formatted string.
 @param format A string format with a variable length list of replacements.
 @result An autoreleased <tt>NSURL</tt> object.
 */
+ (NSURL *)URLWithFormat:(NSString *)format, ...;

@end
